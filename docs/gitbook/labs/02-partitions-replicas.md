# Lab 02 — PostgreSQL Partitions & Replicas

**Goal:** Understand the difference between *how data is stored* (table partitioning) and *where analytical queries run* (read replicas).

## Start
```bash
make lab-partitions
```

This starts PostgreSQL Primary and a physical streaming Replica, creates sales tables and loads synthetic data.

[Open code and exercises](https://github.com/OrPerets/postgres-data-engineering-lab/tree/main/labs/02-partitioning-replication) · [Full student assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/02-partitioning-replication/assignments/STUDENT_ASSIGNMENT.md)

## Part A — Partition pruning
Compare regular and yearly-partitioned `sales` tables.

**Predict:** If a query filters January–March 2025, which yearly partitions must be visited?

Run an `EXPLAIN (ANALYZE, BUFFERS)` comparison. Explain scanned relations; don't assume fewer partitions always means faster for small data.

## Part B — Replication
Connect separately to Primary and Replica:

```bash
cd labs/02-partitioning-replication
docker compose exec primary psql -U lab -d engineering
docker compose exec replica psql -U lab -d engineering
```

Try `SELECT pg_is_in_recovery();` on each server.

**Predict:** What happens when you attempt to insert on a read-only standby? Why might a recent Primary write take a moment to appear on the Replica?

## Part C — Analytical windows
Write customer running totals, monthly rankings, `LAG()` comparisons and moving averages using `sales_partitioned`.

**Key distinction:** SQL window `PARTITION BY` creates logical calculation groups; PostgreSQL table partitioning controls physical organization.

## Your work
Complete the questions in `sql/student_exercises.sql` and document plan differences and replica consistency behavior.

**Remember:** A replica is not a backup, and this demonstration does not perform automatic failover.
