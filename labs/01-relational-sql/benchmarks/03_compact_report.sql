-- Compact benchmark report: one row per approach, columns for 4 key stages + total.
-- Execute AFTER benchmarks/01_seed_running_total.sql.
-- EXPLAIN (ANALYZE, FORMAT JSON) executes each query and returns plan metadata.
-- No full execution-plan dump. PostgreSQL 16 compatible.
DROP TABLE IF EXISTS pg_temp.benchmark_plan_results;
CREATE TEMP TABLE benchmark_plan_results (approach text, plan jsonb);

DO $$
DECLARE q text; j jsonb;
BEGIN
  q := $query$
    SELECT s.sale_id,s.customer_id,s.sale_date,s.amount,
      (SELECT SUM(s2.amount) FROM benchmark_sales s2
       WHERE s2.customer_id=s.customer_id
         AND (s2.sale_date,s2.sale_id)<=(s.sale_date,s.sale_id)) AS running_total
    FROM benchmark_sales s
  $query$;
  EXECUTE 'EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON) ' || q INTO j;
  INSERT INTO benchmark_plan_results VALUES ('Correlated Subquery', j);

  q := $query$
    SELECT s.sale_id,s.customer_id,s.sale_date,s.amount,
      SUM(s.amount) OVER (
        PARTITION BY s.customer_id
        ORDER BY s.sale_date,s.sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
    FROM benchmark_sales s
  $query$;
  EXECUTE 'EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON) ' || q INTO j;
  INSERT INTO benchmark_plan_results VALUES ('Window Function', j);
END $$;

WITH RECURSIVE plan_nodes AS (
  SELECT r.approach, r.plan->0->'Plan' AS node
  FROM benchmark_plan_results r
  UNION ALL
  SELECT p.approach, child.node
  FROM plan_nodes p
  CROSS JOIN LATERAL jsonb_array_elements(coalesce(p.node->'Plans','[]'::jsonb)) child(node)
), metrics AS (
  SELECT approach,
    coalesce(sum((node->>'Actual Loops')::bigint) FILTER (WHERE node->>'Node Type'='Seq Scan'),0) AS seq_scan_loops,
    coalesce(sum((node->>'Actual Loops')::bigint) FILTER (WHERE node->>'Node Type'='Aggregate'),0) AS aggregate_loops,
    coalesce(sum((node->>'Actual Loops')::bigint) FILTER (WHERE node->>'Node Type'='WindowAgg'),0) AS window_loops,
    coalesce(sum((node->>'Actual Loops')::bigint) FILTER (WHERE node->>'Node Type'='Sort'),0) AS sort_loops
  FROM plan_nodes GROUP BY approach
)
SELECT r.approach,
       m.seq_scan_loops AS "Seq scan executions",
       m.aggregate_loops+m.window_loops AS "Aggregate / Window executions",
       m.sort_loops AS "Sort executions",
       (r.plan->0->'Plan'->>'Shared Hit Blocks')::bigint AS "Shared buffer hits",
       round((r.plan->0->>'Execution Time')::numeric,3) AS "Total time (ms)"
FROM benchmark_plan_results r
JOIN metrics m USING (approach)
ORDER BY CASE WHEN r.approach='Correlated Subquery' THEN 0 ELSE 1 END;

-- Speedup (same execution that produced the table):
SELECT round(
  (max((plan->0->>'Execution Time')::numeric) FILTER (WHERE approach='Correlated Subquery'))
  / nullif(max((plan->0->>'Execution Time')::numeric) FILTER (WHERE approach='Window Function'),0),1
) AS "Window speedup (x)"
FROM benchmark_plan_results;
