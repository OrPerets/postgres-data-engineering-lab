-- INSTRUCTOR ONLY. PostgreSQL 16. Run after schema + seed. Queries Q1–Q15.
-- Monetary amounts: quantity * unit_price * (1 - discount_pct/100).
-- Common helper: revenue by completed order; empty order has zero revenue.
CREATE OR REPLACE TEMP VIEW instructor_order_revenue AS
SELECT o.order_id,o.customer_id,o.order_date,
       coalesce(sum(i.quantity*i.unit_price*(1-coalesce(i.discount_pct,0)/100.0)),0)::numeric AS revenue
FROM orders o LEFT JOIN order_items i ON i.order_id=o.order_id
WHERE o.status='completed'
GROUP BY o.order_id,o.customer_id,o.order_date;

-- Q1 January restriction applies to both branches.
SELECT o.* FROM orders o JOIN customers c USING(customer_id)
WHERE o.order_date>=DATE '2026-01-01' AND o.order_date<DATE '2026-02-01'
 AND ((o.status='completed' AND c.city='Haifa') OR o.status='cancelled')
ORDER BY o.order_id LIMIT 5;

-- Q2 include customers without any completed orders.
SELECT c.customer_id,c.full_name,count(r.order_id) AS completed_orders,
 coalesce(sum(r.revenue),0) AS total_revenue,avg(r.revenue) AS avg_order_revenue,
 max(r.order_date) AS last_completed_date
FROM customers c LEFT JOIN instructor_order_revenue r USING(customer_id)
GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;

-- Q3 both categories and never a returned order.
SELECT c.customer_id,c.full_name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o JOIN order_items i USING(order_id)
              WHERE o.customer_id=c.customer_id AND o.status='completed' AND i.category='books')
 AND EXISTS (SELECT 1 FROM orders o JOIN order_items i USING(order_id)
              WHERE o.customer_id=c.customer_id AND o.status='completed' AND i.category='electronics')
 AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='returned')
ORDER BY c.customer_id;

-- Q4 mean of OTHER completed orders.
WITH w AS (
SELECT r.*,count(*) OVER(PARTITION BY customer_id) n,
 sum(revenue) OVER(PARTITION BY customer_id) AS customer_total
FROM instructor_order_revenue r)
SELECT order_id,customer_id,revenue,
 (customer_total-revenue)/(n-1) AS avg_other_orders
FROM w WHERE n>1 AND revenue>(customer_total-revenue)/(n-1) ORDER BY customer_id,order_id;

-- Q5 per-city, include no-order customers.
SELECT coalesce(c.city,'Unknown') city, count(DISTINCT c.customer_id) customers,
 count(o.order_id) total_orders,
 count(o.order_id) FILTER (WHERE o.status='completed') completed,
 count(o.order_id) FILTER (WHERE o.status='cancelled') cancelled,
 count(o.order_id) FILTER (WHERE o.status='returned') returned,
 count(o.order_id) FILTER (WHERE o.status='pending') pending,
 100.0*count(o.order_id) FILTER (WHERE o.status='completed')/nullif(count(o.order_id),0) completed_pct
FROM customers c LEFT JOIN orders o USING(customer_id)
GROUP BY coalesce(c.city,'Unknown') ORDER BY city;

-- Q6 fix WHERE collapsing outer join, count(*), and line-level AVG.
SELECT c.customer_id,count(r.order_id) completed_orders,
 coalesce(sum(r.revenue),0) total_revenue,avg(r.revenue) avg_order_revenue
FROM customers c LEFT JOIN instructor_order_revenue r USING(customer_id)
GROUP BY c.customer_id
HAVING count(r.order_id)>=2 AND coalesce(sum(r.revenue),0)>=500 ORDER BY c.customer_id;

-- Q7 NOT IN with NULL in subquery yields UNKNOWN; use correlated NOT EXISTS.
SELECT c.customer_id,c.full_name,c.city FROM customers c
WHERE c.city IS NOT NULL AND NOT EXISTS (
SELECT 1 FROM customers bad JOIN orders o ON o.customer_id=bad.customer_id
WHERE bad.city=c.city AND o.status='returned')
ORDER BY c.customer_id;

-- Q8 two highest DISTINCT revenue levels per city, ties preserved.
WITH totals AS (
 SELECT c.customer_id,c.full_name,coalesce(c.city,'Unknown') city,sum(r.revenue) revenue
 FROM customers c JOIN instructor_order_revenue r USING(customer_id)
 GROUP BY c.customer_id,c.full_name,coalesce(c.city,'Unknown')
), ranks AS (
 SELECT *,
 row_number() OVER(PARTITION BY city ORDER BY revenue DESC,customer_id) row_number,
 rank() OVER(PARTITION BY city ORDER BY revenue DESC) rank,
 dense_rank() OVER(PARTITION BY city ORDER BY revenue DESC) dense_rank
 FROM totals)
SELECT * FROM ranks WHERE dense_rank<=2 ORDER BY city,dense_rank,customer_id;

-- Q9 previous, change percent, running total and last-3 moving average.
WITH w AS (
 SELECT r.*,
 lag(revenue) OVER(PARTITION BY customer_id ORDER BY order_date,order_id) previous_revenue,
 sum(revenue) OVER(PARTITION BY customer_id ORDER BY order_date,order_id ROWS UNBOUNDED PRECEDING) running_revenue,
 avg(revenue) OVER(PARTITION BY customer_id ORDER BY order_date,order_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) moving_avg_3
 FROM instructor_order_revenue r)
SELECT *,100*(revenue-previous_revenue)/nullif(previous_revenue,0) percent_change
FROM w ORDER BY customer_id,order_date,order_id;

-- Q10 one top category/customer, zero denominator -> NULL.
WITH categories AS (
SELECT o.customer_id,i.category,
 sum(i.quantity*i.unit_price*(1-coalesce(i.discount_pct,0)/100.0)) revenue
FROM orders o JOIN order_items i USING(order_id)
WHERE o.status='completed' GROUP BY o.customer_id,i.category
), w AS (
SELECT *,sum(revenue) OVER(PARTITION BY customer_id) customer_revenue,
 row_number() OVER(PARTITION BY customer_id ORDER BY revenue DESC,category) rn FROM categories)
SELECT customer_id,category,revenue,100*revenue/nullif(customer_revenue,0) pct_customer
FROM w WHERE rn=1 ORDER BY customer_id;

-- Q11 calendar spine x customers, including months with zero revenue.
WITH months AS (
SELECT generate_series(DATE '2026-01-01',DATE '2026-03-01',interval '1 month')::date month_start
), monthly AS (
SELECT customer_id,date_trunc('month',order_date)::date month_start,sum(revenue) revenue
FROM instructor_order_revenue GROUP BY 1,2
), spine AS (
SELECT c.customer_id,m.month_start,coalesce(r.revenue,0) revenue
FROM customers c CROSS JOIN months m LEFT JOIN monthly r USING(customer_id,month_start)
), w AS (
SELECT *,lag(revenue) OVER(PARTITION BY customer_id ORDER BY month_start) previous_revenue FROM spine)
SELECT *,100*(revenue-previous_revenue)/nullif(previous_revenue,0) pct_change FROM w
ORDER BY customer_id,month_start;

-- Q12a relational division by double NOT EXISTS, nonempty category set.
SELECT c.customer_id FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o JOIN order_items i USING(order_id) WHERE o.status='completed')
AND NOT EXISTS (
 SELECT 1 FROM (SELECT DISTINCT i.category FROM orders o JOIN order_items i USING(order_id)
                WHERE o.status='completed') needed
 WHERE NOT EXISTS (SELECT 1 FROM orders o JOIN order_items i USING(order_id)
                   WHERE o.customer_id=c.customer_id AND o.status='completed' AND i.category=needed.category))
ORDER BY c.customer_id;
-- Q12b aggregate distinct categories; a 100% discount still qualifies.
WITH required AS (
 SELECT count(DISTINCT i.category) n FROM orders o JOIN order_items i USING(order_id) WHERE o.status='completed'
), purchased AS (
SELECT o.customer_id,count(DISTINCT i.category) n FROM orders o JOIN order_items i USING(order_id)
WHERE o.status='completed' GROUP BY o.customer_id)
SELECT p.customer_id FROM purchased p CROSS JOIN required r WHERE r.n>0 AND p.n=r.n ORDER BY p.customer_id;

-- Q13 deduplicate (order, product) first.
WITH product_order AS (
 SELECT DISTINCT o.order_id,i.product_name FROM orders o JOIN order_items i USING(order_id)
 WHERE o.status='completed')
SELECT a.product_name product_a,b.product_name product_b,count(*) orders_together
FROM product_order a JOIN product_order b ON a.order_id=b.order_id AND a.product_name<b.product_name
GROUP BY 1,2 HAVING count(*)>=2 ORDER BY orders_together DESC,1,2;

-- Q14 first threshold crossing.
WITH w AS (
 SELECT r.*,sum(revenue) OVER(PARTITION BY customer_id ORDER BY order_date,order_id ROWS UNBOUNDED PRECEDING) cumulative,
 row_number() OVER(PARTITION BY customer_id ORDER BY order_date,order_id) rn
 FROM instructor_order_revenue r
), crossing AS (
 SELECT *,row_number() OVER(PARTITION BY customer_id ORDER BY rn) first_crossing
 FROM w WHERE cumulative>=500)
SELECT customer_id,order_id,order_date,revenue,cumulative FROM crossing WHERE first_crossing=1 ORDER BY customer_id;

-- Q15 ROWS differentiates same-date orders; RANGE includes all peers on that date.
SELECT order_id,order_date,revenue,
 sum(revenue) OVER(ORDER BY order_date,order_id ROWS UNBOUNDED PRECEDING) rows_total,
 sum(revenue) OVER(ORDER BY order_date RANGE UNBOUNDED PRECEDING) range_total
FROM instructor_order_revenue WHERE customer_id=1 ORDER BY order_date,order_id;
