#!/usr/bin/env bash
set -euo pipefail
LAB="${1:?Provide lab name}"
ACTION="${2:?Provide action}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/labs/$LAB"
need() { command -v "$1" >/dev/null || { echo "Missing $1. See docs/GETTING_STARTED.md"; exit 1; }; }
psql_file() { docker compose exec -T "$1" psql -v ON_ERROR_STOP=1 -U "$2" -d "$3" < "$4"; }
case "$ACTION" in
 setup)
   if [[ "$LAB" == "01-relational-sql" ]]; then
     need docker; docker compose up -d --wait
     psql_file postgres student query_lab sql/01_schema.sql
     psql_file postgres student query_lab sql/02_seed.sql
   elif [[ "$LAB" == "02-partitioning-replication" ]]; then
     need docker; need python; docker compose up -d --wait
     psql_file primary lab engineering sql/01_schema.sql
     python scripts/generate_sales.py --rows 200000
   elif [[ "$LAB" == "03-dwh-etl" ]]; then
     need docker; bash scripts/setup.sh
   elif [[ "$LAB" == "06-tfidf" ]]; then
     need docker; docker compose up -d --wait
     psql_file postgres student tfidf_lab sql/01_setup.sql
   else
     need python; echo "Python lab: no setup required."
   fi ;;
 demo)
   case "$LAB" in
     01-relational-sql) need docker; docker compose exec -T postgres psql -U student -d query_lab < sql/03_check_data.sql;;
     02-partitioning-replication) need python; python scripts/benchmark.py;;
     03-dwh-etl) need docker; psql_file postgres student dwh_etl_lab sql/03_verify.sql;;
     04-mapreduce) python mapreduce_demo.py;;
     05-pagerank) python pagerank_demo.py;;
     06-tfidf) python tfidf_demo.py;;
   esac ;;
 test)
   case "$LAB" in
     01-relational-sql) need docker; psql_file postgres student query_lab sql/03_check_data.sql;;
     02-partitioning-replication) need docker; docker compose exec -T primary psql -U lab -d engineering -c "SELECT count(*) FROM sales_regular;"; docker compose exec -T replica psql -U lab -d engineering -c "SELECT pg_is_in_recovery();";;
     03-dwh-etl) need docker; psql_file postgres student dwh_etl_lab sql/03_verify.sql;;
     *) need python; python -m unittest discover -s tests -v;;
   esac ;;
 benchmark)
   case "$LAB" in
     02-partitioning-replication) python scripts/benchmark.py;;
     05-pagerank) python benchmark.py --nodes 1000 10000 --workers 2 --iterations 8 --trials 3;;
     06-tfidf) python benchmark.py --documents 100 1000 --workers 2 --trials 3;;
     *) echo "No benchmark configured for $LAB"; exit 2;;
   esac ;;
 health)
   echo "Lab: $LAB"; need python; python --version
   if [[ -f docker-compose.yml ]]; then need docker; docker compose ps; else echo "No Docker required."; fi ;;
 reset)
   echo "WARNING: reset deletes work and/or database state for $LAB."
   if [[ "${CONFIRM_RESET:-}" != "YES" ]]; then
     echo "To confirm: CONFIRM_RESET=YES make reset LAB=$LAB"; exit 2
   fi
   if [[ -f docker-compose.yml ]]; then need docker; docker compose down -v; else echo "No managed database to reset."; fi ;;
 *) echo "Unknown action: $ACTION"; exit 2 ;;
esac
