# Data Engineering Course — Hands-on Labs

Browser-based teaching labs built for GitHub Codespaces. Each module contains its own instructions and student exercises. Python labs need no database; SQL labs use isolated PostgreSQL 16 containers.

## Start here

Read the [student quick-start guide](docs/GETTING_STARTED.md). From the repository root:

```bash
make help
make health LAB=01-relational-sql
make setup LAB=01-relational-sql
```

**Warning:** Setup can recreate exercise tables and overwrite database work. Save answers first.

## Labs

| Lab | Topic | Student instructions |
|---|---|---|
| 01 | SQL, JOINs, windows, query optimization | [Lab 01](labs/01-relational-sql/README.md) |
| 02 | Partitioning, physical replication, windows | [Lab 02](labs/02-partitioning-replication/README.md) |
| 03 | ETL, staging, dimensions and facts | [Lab 03](labs/03-dwh-etl/README.md) |
| 04 | MapReduce and combiners | [Lab 04](labs/04-mapreduce/README.md) |
| 05 | PageRank and performance | [Lab 05](labs/05-pagerank/README.md) |
| 06 | Regex, TF-IDF and performance | [Lab 06](labs/06-tfidf/README.md) |

Each module has its own README. Use `make demo LAB=...`, `make test LAB=...`, and `make benchmark LAB=...` where supported. Labs 04–06 have student tests that intentionally fail before solutions are implemented.

## Adding future modules

Create `labs/07-topic-name/` with a README, exercise files and any necessary SQL, data, tests or scripts. Keep reusable course tooling at repository root. Avoid storing real personal data or production credentials.

## Access and safety

The sample passwords and configurations are for local classroom simulations only. Codespaces quotas and availability depend on each student's account. **Instructor solution files currently reside under each lab's `instructor/` directory; those directories are NOT access-controlled. Anyone who can read the repository can also read those solutions, including from Git history. Do not grant students repository access until solutions are relocated to an instructor-only repository and access is reviewed.**
