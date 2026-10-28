# Lab 03 — Data Warehouse & ETL

**Goal:** Trace data from two heterogeneous source systems through staging views into warehouse dimensions and facts.

## Start
```bash
make lab-dwh
```

[Open lab code](https://github.com/OrPerets/postgres-data-engineering-lab/tree/main/labs/03-dwh-etl) · [Assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/03-dwh-etl/STUDENT_ASSIGNMENT.md)

## The pipeline
`SRC_SCHEMA.snowflake_raw` + `SRC_SCHEMA.dataiku_raw` → source-specific clean views → `STAGE_SCHEMA.usage` → dimensions → `DWH_SCHEMA.fact_usage`.

### Understand
In SRC, timestamps and amounts arrive as text. In STAGE, queries cast and normalize them and attach data-quality flags. In DWH, source observations are stored as facts with foreign keys to dimensions.

> STAGE is built from **views**, not copied staging tables. Read the view to see transformed source data.

### Predict
- What happens to an empty cost? Does it become zero?
- Why is `UNION ALL` appropriate rather than `UNION`?
- Why do dimensions need to be loaded before facts?
- Does repeating `ON CONFLICT DO NOTHING` refresh modified source records?

### Investigate
Use the sample row `batch_id='dk-sample-v1'`, `row_no=4` and trace it through all layers. It has missing costs and tokens.

Write the SQL questions in `sql/student_exercises.sql`. The original sample has **five rows per source**, and it does **not** prove all business events were ingested.

### Extension
Design an update-aware ingestion policy for corrected and deleted source observations, explaining how it differs from the sample's conflict-skipping load.
