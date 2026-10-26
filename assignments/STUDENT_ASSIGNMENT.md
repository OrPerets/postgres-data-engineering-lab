# Student assignment: PostgreSQL Partitioning & Replication

**Goal:** connect ETL, DWH physical design, and scalable analytical reads.

**Deliverables:** Short PDF or Markdown report, query plans, timings (7 runs/median), SQL and screenshots. Use only synthetic data.

## A. Partitioning (40%)
1. Confirm regular and partitioned tables contain equal counts and totals.
2. Run `sql/02_partition_experiments.sql`; compare EXPLAIN ANALYZE BUFFERS.
3. Disable partition pruning; explain which partitions are scanned.
4. Filter by `customer_id` (not the partition key). What changes?
5. Create a date index on both designs and repeat. Explain tradeoffs.

## B. Replication (35%)
1. Show `pg_is_in_recovery()` on Primary and Replica.
2. Insert on Primary, then SELECT on Replica. Capture evidence.
3. Attempt INSERT on Replica and explain the error.
4. Check `pg_stat_replication` and `pg_stat_wal_receiver`.
5. Stop and restart Replica; describe catching up.

## C. Architecture discussion (25%)
Write 200–300 words: route ETL writes and BI reads; discuss asynchronous consistency, standby delay, failures, failover vs promotion, and why replication is not backup.

**Bonus:** Monthly vs yearly partitions; measure reporting latency while ETL loads new rows.

**Safety:** Classroom credentials only, not for production. Destroying volumes removes data.
