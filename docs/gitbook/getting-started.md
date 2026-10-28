# Getting started with GitHub Codespaces

**Goal:** Open a ready-to-use cloud development environment without installing PostgreSQL or Docker locally.

## Step 1 — Open the course code
Open [the course GitHub repository](https://github.com/OrPerets/postgres-data-engineering-lab). Select **Code → Codespaces → Create codespace on main**.

> Your instructor must grant access to the private repository. Codespaces availability and quotas depend on your GitHub account.

## Step 2 — Check your terminal
In the browser-based editor, open **Terminal**. Confirm you are at the repository root (the folder containing `Makefile`).

```bash
pwd
ls Makefile
make help
```

## Step 3 — Start a lab
Run one command from the root:

| Lab | Command |
|---|---|
| SQL | `make lab-sql` |
| Partitions / Replication | `make lab-partitions` |
| DWH & ETL | `make lab-dwh` |
| MapReduce | `make lab-mapreduce` |
| PageRank | `make lab-pagerank` |
| TF-IDF | `make lab-tfidf` |

The initializer starts services where needed and prepares the provided sample data. It tries to preserve existing tables, but **do not use initialization or reset as a substitute for saving your code**. 

## Step 4 — Write your answers
Open the student file referenced by your tutorial. Write your code there and follow the submission instructions your instructor provides.

## Step 5 — Check your work
For example, `make demo LAB=04-mapreduce` runs the demonstration and `make test LAB=04-mapreduce` runs the tests. For code tasks, some tests intentionally fail until you complete the functions.

**Never use `make reset` casually:** it deletes the database volume after explicit confirmation.

[Next: How to work through a lab](how-to-learn.md).
