# Data Engineering Course — PostgreSQL Labs

A modular hands-on PostgreSQL teaching repository for GitHub Codespaces. Each lab has a **self-contained README and exercises**; database-based labs have separate Docker Compose setups, while algorithm labs run directly in Python. No Docker installation on students' laptops is required.

## Course labs

| Order | Module | Focus | Launch |
|---|---|---|---|
| 01 | [Relational SQL & Query Optimization](labs/01-relational-sql/README.md) | JOIN, GROUP BY, NULL, nested queries, ranking, analytical window functions — 15 exercises | `cd labs/01-relational-sql` |
| 02 | [Partitioning & Replication](labs/02-partitioning-replication/README.md) | ETL, partition pruning, PostgreSQL physical read replica, window functions | `cd labs/02-partitioning-replication` |
| 03 | [Data Warehouse & ETL](labs/03-dwh-etl/README.md) | Raw vs staging, STTM, star schema, dimensional ETL, quality checks, idempotency | `cd labs/03-dwh-etl` |
| 04 | [MapReduce](labs/04-mapreduce/README.md) | Map, shuffle, reduce, safe combiners, skew, distributed mean/variance | `cd labs/04-mapreduce` |
| 05 | [PageRank](labs/05-pagerank/README.md) | Directed graphs, iterative PageRank, damping, dangling nodes, MapReduce iterations | `cd labs/05-pagerank` |
| 06 | [Regex & TF-IDF](labs/06-tfidf/README.md) | Regex, tokenization, four MapReduce stages, TF-IDF and PostgreSQL SQL | `cd labs/06-tfidf` |

## Student quick start

Start with the [getting started guide](docs/GETTING_STARTED.md). From the repository root run:

```bash
make help
make health LAB=04-mapreduce
make demo LAB=04-mapreduce
```

Commands use a unified interface; setup may reset training data and should not be repeated after doing your assignment.

## Open in Codespaces

Choose **Code → Codespaces → Create codespace on main**. The devcontainer is shared by the course; each lab's Docker services are started only when needed.

Run one lab at a time to save Codespaces resources:

```bash
cd labs/01-relational-sql
docker compose up -d
docker compose exec -T postgres psql -U student -d query_lab < sql/01_schema.sql
docker compose exec -T postgres psql -U student -d query_lab < sql/02_seed.sql
```

Switch to the next lab from the repo root:

```bash
cd /workspaces/postgres-data-engineering-lab/labs/02-partitioning-replication
docker compose up -d
docker compose exec -T primary psql -U lab -d engineering < sql/01_schema.sql
python scripts/generate_sales.py --rows 200000
```

The PostgreSQL labs are isolated. Lab 01 uses localhost port **55432**, while lab 02 uses **5432** and **5433**. Only demo/test credentials are present; **never use this setup in production**.

## Adding future labs

Create `labs/07-topic-name/` with its own README, docker-compose.yml, sql/, optional scripts/ and assignments/. Keep common Codespaces configuration at the repository root. Do not commit personal data or production secrets.

## For instructors

Student exercise templates are provided inside each lab. Instructor-only solutions should remain **outside any repository accessible to students**. See each lab's student brief. Docker must be available inside the Codespace; if it launches in recovery mode, inspect Codespaces creation logs.
