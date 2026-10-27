# Lab 03 — Instructor solutions and expected observations

These questions are based on the supplied `STAGE.sql`, `DWH.sql` and original `practice4-formal-solution.sql`. The uploaded formal solution file was intentionally NOT committed to the student repo. The exercises here use these schemas as given.

## Source → staging
- **Raw source grain:** `(batch_id,row_no)`, five rows each from Snowflake and Dataiku.
- **STTM:** Snowflake `start_time` → `started_at` with `to_timestamp(...,'DD.MM.YYYY HH24:MI')`; Dataiku `event_time` → timestamp; source-specific user, model and cost values renamed to a common layout.
- **Missing cost:** `NULL` means unknown, not $0. The sample's Dataiku row 4 has missing numeric fields.
- **UNION ALL:** preserves all 10 source observations, with no artificial deduplication.
- **Quality:** `invalid_number`, `token_consistent` and `quality_flags`; absent tokens yield unknown token consistency rather than TRUE.
- **Source-specific meaning:** Snowflake 'reported' cost vs Dataiku 'estimated' cost, no success outcome and no evidence of complete ingest.

## DWH
- **Fact grain:** one ingested source observation identified by `(batch_id,row_no)`; it is not necessarily a unique real-world LLM call.
- **Dimensions:** source, date, user, entity and model. Natural identity includes `source_code` so different systems are not assumed to share entities. Surrogate keys are warehouse-generated.
- **Load dimensions before facts** to resolve surrogate keys.
- **Reruns:** fixed batch uses `ON CONFLICT DO NOTHING`. It prevents duplicate inserts but intentionally does not refresh modified facts. This is not CDC or an upsert.
- **Correctness limitation:** no successful-run percentage can be computed from these inputs.

## Engineering scenarios
- A raw source edit changes views when read again but not existing persisted facts.
- A truly update-aware pipeline needs event identity, source change version, update semantics and deletion policy; checksums and deduplication alone are insufficient.
- Use calendar spine for no-observation days. Do NOT label an unobserved day 'confirmed zero cost' unless completeness evidence exists.

See `solutions.sql` for runnable checks. The richer analytical views in `practice4-formal-solution.sql` were part of the instructor upload; preserve that original privately.
