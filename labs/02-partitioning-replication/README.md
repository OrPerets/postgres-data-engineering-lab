# Lab 02 — PostgreSQL Partitioning, Replication & Window Functions

A complete browser-based PostgreSQL 16 lab running inside GitHub Codespaces. The folder contains a Primary, a physical Streaming Replica, SQL partitioning exercises, Python data load and student SQL tasks.

## Start in Codespaces

From the repository root:

```bash
cd labs/02-partitioning-replication
docker compose up -d
docker compose ps
docker compose exec -T primary psql -U lab -d engineering < sql/01_schema.sql
python scripts/generate_sales.py --rows 200000
python scripts/benchmark.py
docker compose exec -T primary psql -U lab -d engineering < sql/02_partition_experiments.sql
```

## Verify replica

```bash
docker compose exec primary psql -U lab -d engineering -c "SELECT pg_is_in_recovery();"
docker compose exec replica psql -U lab -d engineering -c "SELECT pg_is_in_recovery();"
docker compose exec primary psql -U lab -d engineering -c "SELECT application_name,state FROM pg_stat_replication;"
docker compose exec primary psql -U lab -d engineering -c "INSERT INTO sales_regular VALUES (99999999,'2026-10-26',100,500);"
docker compose exec replica psql -U lab -d engineering -c "SELECT * FROM sales_regular WHERE sale_id=99999999;"
```

Replication is asynchronous; a committed row can take a moment to appear. Standby rejects writes. This is **not an automatic-failover cluster** and **not a backup**.

## Assignments

- [Extended assignment](assignments/STUDENT_ASSIGNMENT_V2.md)
- [Student SQL worksheet](sql/student_exercises.sql)
- [Original assignment](assignments/STUDENT_ASSIGNMENT.md)
- [Instructor notes in Hebrew (no answers)](assignments/INSTRUCTOR_NOTES_V2_HE.md)
- [Instructor guide](assignments/INSTRUCTOR_GUIDE_HE.md)

Optional after generating data: `docker compose exec -T primary psql -U lab -d engineering < sql/04_lab_extensions.sql`.

All passwords and network permissions are for classroom demonstration. Reset (**deletes data**) with `docker compose down -v`.
