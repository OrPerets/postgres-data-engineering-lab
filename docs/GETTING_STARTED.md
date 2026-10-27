# Getting started — 6 labs, one workflow

Open GitHub Codespaces for this repository. In the terminal run:

```bash
git pull origin main
make help
make health LAB=04-mapreduce
make setup LAB=01-relational-sql
make demo LAB=01-relational-sql
```

The same interface works for all labs: `make setup`, `make demo`, `make test`, `make health`, and (where supported) `make benchmark`. Always specify `LAB=...`. Run one PostgreSQL lab at a time to avoid resource pressure.

**Caution:** `make setup` recreates the exercise tables in Labs 01 and 02. It can erase your earlier results. Do not rerun after doing work unless you have saved your answers. `make reset` requires explicit `CONFIRM_RESET=YES` and deletes database volumes. Make backups of your edits.

**Student tests:** In Labs 04–06, `make test` includes deliberate `NotImplementedError` failures in student templates. This is expected before implementing functions and is not necessarily an environment problem.

**Health checks:** `make health` checks Python plus Docker container state when relevant. It does not prove every query or feature is correct. If Codespaces starts in recovery mode, inspect creation logs; Docker may not be available.

| Lab | Folder | Type |
|---|---|---|
| 01 | `labs/01-relational-sql` | PostgreSQL |
| 02 | `labs/02-partitioning-replication` | PostgreSQL Primary + Replica |
| 03 | `labs/03-dwh-etl` | PostgreSQL |
| 04 | `labs/04-mapreduce` | Python |
| 05 | `labs/05-pagerank` | Python |
| 06 | `labs/06-tfidf` | Python + optional PostgreSQL |

**Note:** These commands are a unified starter interface, not a full assignment autograder. Do not treat passing demo checks as confirmation that your own SQL answers are correct.

## Simplest way to start each lab

Run these from the **repository root** (not a lab subdirectory):

| Lab | One command |
|---|---|
| SQL | `make lab-sql` |
| Partitions and Replicas | `make lab-partitions` |
| DWH and ETL | `make lab-dwh` |
| MapReduce | `make lab-mapreduce` |
| PageRank | `make lab-pagerank` |
| TF-IDF | `make lab-tfidf` |

Initializers bring up Docker services where needed, wait for health, create missing data, and run basic checks. They **skip table creation if the key tables already exist**, so existing work is not intentionally overwritten. They do not repair partially initialized or modified schemas automatically. Python labs run their reference demo but do not complete student exercises. Full test suites may fail on deliberately blank student code.

To remove a lab's database state intentionally, use `CONFIRM_RESET=YES make reset LAB=01-relational-sql` and then `make lab-sql`. Reset is destructive. Run only one resource-heavy lab at a time.
