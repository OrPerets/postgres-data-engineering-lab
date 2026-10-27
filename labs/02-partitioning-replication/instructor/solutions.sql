-- INSTRUCTOR ONLY. Run after setup; destructive DDL questions use dedicated tables.
-- A1 partition metadata:
SELECT c.relname AS child,pg_get_expr(c.relpartbound,c.oid) AS bounds
FROM pg_inherits i JOIN pg_class c ON c.oid=i.inhrelid
WHERE i.inhparent='sales_partitioned'::regclass ORDER BY child;
-- A2 year totals:
SELECT extract(year FROM sale_date)::int sale_year,count(*) transactions,sum(amount) revenue
FROM sales_partitioned GROUP BY 1 ORDER BY 1;
-- A3 compare:
EXPLAIN (ANALYZE,BUFFERS) SELECT sum(amount) FROM sales_regular WHERE sale_date>='2025-01-01' AND sale_date<'2025-04-01';
EXPLAIN (ANALYZE,BUFFERS) SELECT sum(amount) FROM sales_partitioned WHERE sale_date>='2025-01-01' AND sale_date<'2025-04-01';
-- A4 monthly partitions created by DO for 2025:
DROP TABLE IF EXISTS instructor_monthly CASCADE;
CREATE TABLE instructor_monthly (LIKE sales_regular) PARTITION BY RANGE(sale_date);
DO $$
DECLARE m int;
BEGIN FOR m IN 1..12 LOOP
 EXECUTE format('CREATE TABLE instructor_month_%s PARTITION OF instructor_monthly FOR VALUES FROM (%L) TO (%L)',
 to_char(make_date(2025,m,1),'YYYYMM'),
 make_date(2025,m,1), (make_date(2025,m,1)+interval '1 month')::date);
END LOOP; END $$;
INSERT INTO instructor_monthly SELECT * FROM sales_regular WHERE sale_date>='2025-01-01' AND sale_date<'2026-01-01';
SELECT (SELECT count(*) FROM instructor_monthly)=(SELECT count(*) FROM sales_regular WHERE sale_date>='2025-01-01' AND sale_date<'2026-01-01') valid;
-- A5:
EXPLAIN (ANALYZE,BUFFERS) SELECT sum(amount) FROM instructor_monthly WHERE sale_date>='2025-02-01' AND sale_date<'2025-03-01';
EXPLAIN (ANALYZE,BUFFERS) SELECT sum(amount) FROM instructor_monthly WHERE sale_date>='2025-01-01' AND sale_date<'2026-01-01';
-- A6 new 2027 partition. Run once after ensuring it does not exist:
CREATE TABLE IF NOT EXISTS sales_2027 PARTITION OF sales_partitioned FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
INSERT INTO sales_partitioned VALUES (99000001,'2027-01-05',1,50),(99000002,'2027-02-05',2,60),(99000003,'2027-03-05',3,70);
SELECT tableoid::regclass,sale_id FROM sales_partitioned WHERE sale_id BETWEEN 99000001 AND 99000003;
-- B1 PRIMARY and REPLICA:
SELECT pg_is_in_recovery();
-- B2 INSERT on PRIMARY ONLY:
INSERT INTO sales_regular VALUES (99010001,'2026-10-26',100,500);
-- Then SELECT on REPLICA:
SELECT * FROM sales_regular WHERE sale_id=99010001;
-- B3 PRIMARY:
SELECT application_name,state,sync_state,sent_lsn,replay_lsn,
       pg_wal_lsn_diff(sent_lsn,replay_lsn) replay_lag_bytes FROM pg_stat_replication;
-- B4 REPLICA:
SELECT status,received_lsn,latest_end_lsn FROM pg_stat_wal_receiver;
SELECT pg_last_xact_replay_timestamp();
-- B5 attempting INSERT on REPLICA raises read-only error; run separately.
-- C1 running amount:
SELECT sale_id,customer_id,sale_date,amount,
sum(amount) OVER(PARTITION BY customer_id ORDER BY sale_date,sale_id ROWS UNBOUNDED PRECEDING) running_amount
FROM sales_partitioned;
-- C2:
WITH ranked AS (SELECT *,row_number() OVER(PARTITION BY customer_id ORDER BY amount DESC,sale_id) rn FROM sales_partitioned)
SELECT * FROM ranked WHERE rn<=3;
-- C3+ C6 complete month spine:
WITH months AS (SELECT generate_series(DATE '2024-01-01',DATE '2026-12-01',interval '1 month')::date month_start),
totals AS (SELECT date_trunc('month',sale_date)::date month_start,sum(amount) revenue FROM sales_partitioned WHERE sale_date>='2024-01-01' AND sale_date<'2027-01-01' GROUP BY 1),
series AS (SELECT m.month_start,coalesce(t.revenue,0) revenue FROM months m LEFT JOIN totals t USING(month_start)),
w AS (SELECT *,lag(revenue) OVER(ORDER BY month_start) previous_month,
avg(revenue) OVER(ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) moving_average_3
FROM series)
SELECT *,revenue-previous_month change_absolute FROM w ORDER BY month_start;
-- C4 previous sale date:
SELECT customer_id,sale_id,sale_date,
sale_date-lag(sale_date) OVER(PARTITION BY customer_id ORDER BY sale_date,sale_id) days_since_previous
FROM sales_partitioned;
-- C5 monthly ranking including ties:
WITH monthly AS (SELECT date_trunc('month',sale_date)::date month_start,customer_id,sum(amount) revenue FROM sales_partitioned GROUP BY 1,2),
ranked AS (SELECT *,rank() OVER(PARTITION BY month_start ORDER BY revenue DESC) rnk FROM monthly)
SELECT * FROM ranked WHERE month_start='2025-01-01' AND rnk<=5 ORDER BY rnk,customer_id;
-- D1 date filter inside aggregation then window:
WITH monthly AS (SELECT customer_id,date_trunc('month',sale_date)::date m,sum(amount) revenue
 FROM sales_partitioned WHERE sale_date>='2025-01-01' AND sale_date<'2026-01-01' GROUP BY 1,2)
SELECT *,sum(revenue) OVER(PARTITION BY customer_id ORDER BY m ROWS UNBOUNDED PRECEDING) cumulative
FROM monthly ORDER BY customer_id,m;
-- D2 architecture: ETL writes to Primary, BI reads Replica. Replica may lag.
-- No automatic failover in sample, replication is not backup.
