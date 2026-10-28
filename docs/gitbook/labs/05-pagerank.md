# Lab 05 — PageRank

**Goal:** Model importance in a directed graph as rank flowing along edges, then connect that computation to MapReduce.

## Start
```bash
make lab-pagerank
```

[Student functions](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/05-pagerank/student_tasks.py) · [Assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/05-pagerank/STUDENT_ASSIGNMENT.md)

## Start with three pages
`A → B,C`; `B → C`; `C → A`. Start each page at rank `1/3`.

**Predict:** After one iteration without damping, which page has the highest rank?

## Add the real-world complications
Add node D with no outlinks; use damping `d=0.85`.

```text
new_rank(p) = (1-d)/N + d * (incoming_contributions + dangling_mass/N)
```

**Check:** Total rank should remain approximately 1.

## Implement
Complete the map contribution step, shuffle/grouping, dangling mass, damped rank update and convergence condition.

```bash
cd labs/05-pagerank
python -m unittest tests.test_demo -v
python -m unittest discover -s tests -v
```

## Performance challenge
Compare sequential and multi-process PageRank:

```bash
python benchmark.py --nodes 1000 10000 --workers 2 4 --iterations 12 --trials 3
```

Why can a multi-process implementation on one Codespace machine be **slower** on small graphs? Read [the performance assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/05-pagerank/PERFORMANCE_ASSIGNMENT.md).

This is not a multi-node distributed engine.
