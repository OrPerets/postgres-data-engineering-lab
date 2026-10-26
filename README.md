# PostgreSQL Data Engineering Lab — Partitions & Replicas

A browser-based undergraduate data-engineering lab: **PostgreSQL 16, ETL loading, yearly partitions, and physical streaming replication**. Students can use **GitHub Codespaces**; no local Docker installation is required.

> **Classroom demo only:** Credentials are hard-coded, and replication access is deliberately permissive inside the container network. Do not deploy as a public or production database. Compose binds ports to loopback.

## Launch with Codespaces

1. Open the repository on GitHub and choose **Code → Codespaces → Create codespace on main**. Ensure you have Codespaces access (private repository permissions and available quota).
2. In the browser terminal run:

```bash
docker compose up -d
docker compose ps
```

3. Initialize and load data:

```bash
docker compose exec -T primary psql -U lab -d engineering < sql/01_schema.sql
python scripts/generate_sales.py --rows 200000
python scripts/benchmark.py
docker compose exec -T primary psql -U lab -d engineering < sql/02_partition_experiments.sql
```

The devcontainer installs Python and a Docker-in-Docker feature; Python dependencies install on creation. If using a local terminal instead of Codespaces, install Docker Engine/Compose and Python 3.10+, then `pip install -r requirements.txt`.

## Replication experiments

```bash
docker compose exec primary psql -U lab -d engineering -c "SELECT pg_is_in_recovery();"
docker compose exec replica psql -U lab -d engineering -c "SELECT pg_is_in_recovery();"
docker compose exec primary psql -U lab -d engineering -c "SELECT application_name,state,sync_state FROM pg_stat_replication;"
docker compose exec primary psql -U lab -d engineering -c "INSERT INTO sales_regular VALUES (99999999,'2026-10-26',100,500);"
docker compose exec replica psql -U lab -d engineering -c "SELECT * FROM sales_regular WHERE sale_id=99999999;"
```

Physical streaming replication is **asynchronous by default**; a fresh row may not be visible instantly. Try an INSERT on the replica; it should fail because the standby is read-only. Observe lag and catch-up by stopping and restarting the replica:

```bash
docker compose stop replica
docker compose start replica
```

For a full reset (**deletes all lab data**): `docker compose down -v && docker compose up -d`.

## Files

- `docker-compose.yml`: Primary and read-only replica.
- `.devcontainer/devcontainer.json`: browser Codespaces development environment.
- `docker/`: standby initialization with `pg_basebackup`.
- `sql/`: schema, partition-pruning queries, replication checks.
- `scripts/`: synthetic ETL load and benchmark.
- `assignments/`: student brief and Hebrew instructor guide.

## Learning questions

- Why can partition pruning help only when relevant partition keys are filtered?
- What happens when an index competes with partitioning?
- Why does a read replica help reporting isolation but not increase primary write capacity?
- Why is a replica **not a backup**? What is missing for automatic failover?

## Troubleshooting

- `docker compose ps` should show healthy Primary and Replica (first startup may take longer).
- `docker compose logs primary replica` helps diagnose replication.
- A volume from an older setup may prevent re-running init scripts; reset only if disposable.
- On small data, partitioned queries may not be faster; compare EXPLAIN buffers and repeated timings.
- In Codespaces, Docker-in-Docker can take a moment to initialize. If needed, rebuild the devcontainer.

PostgreSQL references: [partitioning](https://www.postgresql.org/docs/16/ddl-partitioning.html), [warm standby](https://www.postgresql.org/docs/16/warm-standby.html), [pg_basebackup](https://www.postgresql.org/docs/16/app-pgbasebackup.html).
