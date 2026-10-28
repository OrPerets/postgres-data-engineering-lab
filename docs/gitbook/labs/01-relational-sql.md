# Lab 01 — Relational SQL & Query Optimization

**Goal:** Write correct SQL with joins, aggregates, subqueries and window functions, then understand why two equivalent queries can run at very different speeds.

**You should know:** Basic `SELECT`, `WHERE`, `JOIN`, `GROUP BY`.

## Start
From the repository root in Codespaces:

```bash
make lab-sql
```

This prepares synthetic `customers`, `orders` and `order_items` tables.

[Open the Lab 01 code](https://github.com/OrPerets/postgres-data-engineering-lab/tree/main/labs/01-relational-sql) · [Student question sheet](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/01-relational-sql/sql/student_answers.sql)

## First experiment — Revenue
For a completed order, net line revenue is:

```sql
quantity * unit_price * (1 - COALESCE(discount_pct,0)/100.0)
```

**Predict:** Should a cancelled order count as revenue? What happens to an order with a 100% discount?

## Your tasks
Complete the **15 questions written directly in** `labs/01-relational-sql/sql/student_answers.sql`. They cover outer joins, subquery logic, `NULL`, rankings, running totals and `ROWS` versus `RANGE`.

## Performance mini-lab — Two ways to calculate running totals
The benchmark creates a separate `benchmark_sales` table and compares:
- a correlated subquery that repeatedly scans preceding transactions;
- `SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date,sale_id ROWS UNBOUNDED PRECEDING)`.

Run from `labs/01-relational-sql`:

```bash
docker compose exec -T postgres psql -U student -d query_lab < benchmarks/01_seed_running_total.sql
docker compose exec -T postgres psql -U student -d query_lab < benchmarks/03_compact_report.sql
```

**Look for:** scan executions, aggregation executions, shared buffer hits, execution time and the **MATCH** correctness summary.

**Explain:** Why is an ordered window often more efficient here? Could adding an index change the result? This is a deliberately favorable case for window functions—not a universal performance guarantee.

[Read benchmark instructions](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/01-relational-sql/benchmarks/README.md).

## Before leaving
Your SQL file should contain all requested answers, and you should be able to explain at least one execution plan and one correctness pitfall.
