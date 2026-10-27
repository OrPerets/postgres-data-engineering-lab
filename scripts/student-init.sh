#!/usr/bin/env bash
set -euo pipefail
LAB="${1:?Lab ID required}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/labs/$LAB"
say() { printf '\n==> %s\n' "$*"; }
fail() { echo "ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || fail "Missing $1. In Codespaces, check the container creation log."; }
psqlq() { docker compose exec -T "$1" psql -X -qAt -v ON_ERROR_STOP=1 -U "$2" -d "$3" -c "$4"; }
loadsql() { docker compose exec -T "$1" psql -X -v ON_ERROR_STOP=1 -U "$2" -d "$3" < "$4"; }

say "Initializing $LAB (existing student database rows will be preserved)"
case "$LAB" in
  01-relational-sql)
    need docker
    docker compose up -d --wait
    if [[ "$(psqlq postgres student query_lab "SELECT to_regclass('public.customers') IS NOT NULL AND to_regclass('public.orders') IS NOT NULL AND to_regclass('public.order_items') IS NOT NULL")" == t ]]; then
      say "SQL tables already exist — skipping destructive schema/seed scripts."
    else
      say "Creating schema and sample orders"
      loadsql postgres student query_lab sql/01_schema.sql
      loadsql postgres student query_lab sql/02_seed.sql
    fi
    say "SQL lab verification"
    loadsql postgres student query_lab sql/03_check_data.sql
    echo "READY: SQL lab. Edit labs/01-relational-sql/sql/student_answers.sql"
    ;;
  02-partitioning-replication)
    need docker; need python
    python -c 'import psycopg' >/dev/null 2>&1 || { say "Installing Python requirements"; python -m pip install -r requirements.txt; }
    docker compose up -d --wait
    if [[ "$(psqlq primary lab engineering "SELECT to_regclass('public.sales_regular') IS NOT NULL AND to_regclass('public.sales_partitioned') IS NOT NULL")" == t ]]; then
      say "Sales tables exist — preserving previous data."
    else
      loadsql primary lab engineering sql/01_schema.sql
      python scripts/generate_sales.py --rows 200000
    fi
    [[ "$(psqlq replica lab engineering 'SELECT pg_is_in_recovery()')" == t ]] || fail "Replica is not in recovery mode"
    echo "READY: Partitioning and replication lab."
    ;;
  03-dwh-etl)
    need docker
    docker compose up -d --wait
    if [[ "$(psqlq postgres student dwh_etl_lab "SELECT to_regclass('src_schema.snowflake_raw') IS NOT NULL")" != t ]]; then
      loadsql postgres student dwh_etl_lab sql/01_stage.sql
    else
      say "Source tables exist — keeping existing source rows and staging views."
    fi
    if [[ "$(psqlq postgres student dwh_etl_lab "SELECT to_regclass('dwh_schema.fact_usage') IS NOT NULL")" != t ]]; then
      loadsql postgres student dwh_etl_lab sql/02_dwh.sql
    else
      say "Fact table exists — preserving the current warehouse state."
    fi
    loadsql postgres student dwh_etl_lab sql/03_verify.sql
    echo "READY: DWH and ETL lab."
    ;;
  04-mapreduce|05-pagerank|06-tfidf)
    need python
    if [[ "$LAB" == 06-tfidf ]]; then
      need docker
      docker compose up -d --wait
      if [[ "$(psqlq postgres student tfidf_lab "SELECT to_regclass('public.documents') IS NOT NULL")" != t ]]; then
        loadsql postgres student tfidf_lab sql/01_setup.sql
      else
        say "TF-IDF document table already exists — preserving data."
      fi
    fi
    demo=mapreduce_demo.py
    [[ "$LAB" == 05-pagerank ]] && demo=pagerank_demo.py
    [[ "$LAB" == 06-tfidf ]] && demo=tfidf_demo.py
    say "Running reference demo ($demo)"
    python "$demo"
    echo "READY: Python lab. Complete student_tasks.py and run the tests when ready."
    ;;
  *) fail "Unknown lab: $LAB" ;;
esac
