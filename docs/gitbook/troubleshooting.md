# Troubleshooting

## `docker: command not found`
You may be in a Codespaces recovery container, or Docker tooling is unavailable. Check Codespaces creation logs and the repository's `.devcontainer/devcontainer.json`. Rebuild or recreate the Codespace using the current configuration; don't install Docker on your laptop just to fix the cloud container.

## `service "postgres" is not running`
Run the initializer **from the repository root**:
```bash
make lab-sql
```
Or, inside `labs/01-relational-sql`, run `docker compose up -d --wait`. Check `docker compose ps -a` and `docker compose logs postgres` if it fails.

## `No rule to make target lab-sql`
You're likely not at repository root or your Codespace has an older checkout. Run `pwd`, `ls Makefile` and `git pull origin main` after saving local edits.

## Python tests fail with `NotImplementedError`
This is intentional in the **student** templates. Complete the indicated function. Run the separate `tests.test_demo` module to check the reference demonstration.

## My SQL results differ from examples
Check which database you're connected to, whether you ran the correct lab initializer, and whether an older exercise changed the data. Avoid resetting tables until you've backed up your work.

## `EXPLAIN ANALYZE` output is too long
For the SQL running-total benchmark, use `benchmarks/03_compact_report.sql`, which prints a compact table and checks output equivalence.

## Performance results differ between students
That's normal: Codespaces machines, workloads, caches, indexes and execution plans vary. Compare measurements on the **same machine and data**; don't treat an example speedup as a guarantee.
