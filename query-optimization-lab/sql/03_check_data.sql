-- Sanity checks: should return 15 customers, 34 orders, and 39 completed orders? 
-- Verify these counts from the data instead of assuming them.
SELECT 'customers' AS relation, count(*) AS records FROM customers
UNION ALL SELECT 'orders', count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items;
SELECT status, COUNT(*) FROM orders GROUP BY status ORDER BY status;
SELECT order_id, customer_id, order_date
FROM orders WHERE customer_id=1 AND order_date='2026-02-05' ORDER BY order_id;
SELECT customer_id, full_name FROM customers
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.customer_id=customers.customer_id)
ORDER BY customer_id;
