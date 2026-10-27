-- INSTRUCTOR ONLY. Run after sql/01_stage.sql then sql/02_dwh.sql.
-- A: source and stage counts (5 each, 10 total).
SELECT 'snowflake' source,count(*) FROM src_schema.snowflake_raw
UNION ALL SELECT 'dataiku',count(*) FROM src_schema.dataiku_raw;
SELECT source_code,count(*) FROM stage_schema.usage GROUP BY source_code ORDER BY source_code;
-- A3 Missing and invalid amounts.
SELECT source_code,batch_id,row_no,cost_usd,invalid_number,quality_flags
FROM stage_schema.usage WHERE cost_usd IS NULL OR invalid_number ORDER BY source_code,row_no;
-- A5 quality flags by type.
SELECT source_code,flag,count(*) FROM stage_schema.usage
CROSS JOIN LATERAL unnest(quality_flags) AS flag GROUP BY source_code,flag ORDER BY source_code,flag;
-- B: fact to dimensions for source row 4:
SELECT f.batch_id,f.row_no,s.source_code,u.user_nk,e.entity_nk,m.model_name,f.cost_usd
FROM dwh_schema.fact_usage f
JOIN dwh_schema.dim_source s USING(source_id)
JOIN dwh_schema.dim_user u USING(user_key)
JOIN dwh_schema.dim_entity e USING(entity_key)
JOIN dwh_schema.dim_model m USING(model_key)
WHERE f.batch_id='dk-sample-v1' AND f.row_no=4;
-- B rerun proof: execute sql/02_dwh.sql again then compare; should remain 10.
SELECT count(*) fact_rows,count(DISTINCT (batch_id,row_no)) unique_source_rows FROM dwh_schema.fact_usage;
-- C11 monthly known cost and missing cost coverage:
SELECT s.source_code,date_trunc('month',f.started_at)::date month_start,
count(*) observed_records,count(f.cost_usd) priced_records,
sum(f.cost_usd) known_cost_usd
FROM dwh_schema.fact_usage f JOIN dwh_schema.dim_source s USING(source_id)
GROUP BY 1,2 ORDER BY 1,2;
-- C12 top three users per source:
WITH totals AS (
SELECT s.source_code,u.user_nk,sum(f.cost_usd) known_cost
FROM dwh_schema.fact_usage f
JOIN dwh_schema.dim_source s USING(source_id)
JOIN dwh_schema.dim_user u USING(user_key)
GROUP BY 1,2
), ranked AS (
SELECT *,row_number() OVER(PARTITION BY source_code ORDER BY known_cost DESC NULLS LAST,user_nk) rn
FROM totals)
SELECT * FROM ranked WHERE rn<=3 ORDER BY source_code,rn;
-- C13 matched populations only:
SELECT s.source_code,1000*sum(f.cost_usd) FILTER(WHERE f.cost_usd IS NOT NULL AND f.total_tokens>0)
 /nullif(sum(f.total_tokens) FILTER(WHERE f.cost_usd IS NOT NULL AND f.total_tokens>0),0)
 AS cost_per_1000_matched_tokens
FROM dwh_schema.fact_usage f JOIN dwh_schema.dim_source s USING(source_id)
GROUP BY 1 ORDER BY 1;
-- C14 dates without records are not certified zero.
SELECT s.source_code,d.calendar_date,count(f.batch_id) observed_rows,sum(f.cost_usd) known_cost
FROM dwh_schema.dim_source s
JOIN dwh_schema.reporting_scope scope USING(source_code)
JOIN dwh_schema.dim_date d ON d.calendar_date BETWEEN scope.report_start AND scope.report_end
LEFT JOIN dwh_schema.fact_usage f ON f.source_id=s.source_id AND f.date_key=d.date_key
GROUP BY s.source_code,d.calendar_date ORDER BY 1,2;
-- C15 audit:
SELECT source_code,count(*) FILTER(WHERE cost_usd IS NULL) missing_cost,
 count(*) FILTER(WHERE invalid_number) invalid_numeric,
 count(*) FILTER(WHERE token_consistent IS FALSE) inconsistent_tokens
FROM stage_schema.usage GROUP BY source_code ORDER BY source_code;
