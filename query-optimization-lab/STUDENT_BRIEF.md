# SQL and Query Optimization — Student Lab

## Data model and rules

Tables:
- `customers(customer_id, full_name, city)`
- `orders(order_id, customer_id, order_date, status)`
- `order_items(order_id, line_no, product_name, category, quantity, unit_price, discount_pct)`

All questions refer to the attached course PDF, **questions 1–15, in the original order**. Use completed orders only unless stated otherwise. Cancelled and returned orders do **not** contribute to revenue. Returned orders represent full returns. `discount_pct` values are percentages 0–100 (NULL = no discount):

```sql
quantity * unit_price * (1 - COALESCE(discount_pct, 0) / 100.0)
```

## Deliverables

- `sql/student_answers.sql` with SQL for questions 1–15 (Q12 requires two distinct solutions).
- Q6: identify and explain three logical errors in the supplied query.
- Q7: explain the effect of NULL in the NOT IN subquery and correct it.
- Q15: predict values for orders of customer 1 on 2026-02-05 and explain ROWS vs RANGE.
- Run `EXPLAIN (ANALYZE, BUFFERS)` on two of your solutions, report observed plan and one plausible optimization. Do not claim an index must be faster.

## Checklist

Check that outer joins keep customers without orders, that completed orders with zero revenue count, and that duplicate order item rows never inflate order counts. Be explicit about grouping grain (order, customer, city). Use deterministic ORDER BY where needed.

**The source PDF is the authoritative problem statement.** The database is a reproducible synthetic sample constructed for classroom practice.
