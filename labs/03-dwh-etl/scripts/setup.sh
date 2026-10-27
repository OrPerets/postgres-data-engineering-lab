#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose up -d --wait
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U student -d dwh_etl_lab < sql/01_stage.sql
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U student -d dwh_etl_lab < sql/02_dwh.sql
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U student -d dwh_etl_lab < sql/03_verify.sql
echo "Lab 03 ready."
