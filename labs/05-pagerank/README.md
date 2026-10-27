# Lab 05 — PageRank after MapReduce

Hands-on Python standard-library lab grounded in the **PageRank Algorithm** lecture. No Docker or Hadoop installation is needed; run inside the existing GitHub Codespace.

## Quick start
```bash
cd labs/05-pagerank
python pagerank_demo.py
python -m unittest tests.test_demo -v
python -m unittest discover -s tests -v
```
The demo tests should pass; student tests intentionally raise `NotImplementedError` until the assignment is completed.

## Covered concepts
- Directed graph and inlinks/outlinks
- Simple update with initial rank 1/N
- Two manual iterations using A→B,C; B→C; C→A
- Damping, teleportation, dangling node D and total mass conservation
- Convergence via L1 rank change
- Map/shuffle/reduce contribution aggregation, structure preservation, combiner safety and hot-key skew

## Important formula
The correct mass-conserving update is:
```text
new_PR(p) = (1-d)/N + d*(sum_incoming_contributions(p) + dangling_mass/N)
```
The factor `d` applies to **both** linked contributions and redistributed dangling-node mass. The four-page slide's rounded first-iteration output (A=.3031, B=.1969, C=.4094, D=.0906) matches this formula. Some earlier rendering of the lecture's formula may visually place `dangling_mass/N` outside `d`; do not implement that interpretation, because it makes total rank exceed 1.

## Expectations
Three-page first iteration: A=1/3, B=1/6, C=1/2. Second: A=1/2, B=1/6, C=1/3.
Four-page first damped iteration: A=.303125, B=.196875, C=.409375, D=.090625, and sum=1.

This is a **deterministic single-process logical simulator**, not a distributed Hadoop implementation. Do not claim physical parallelism, network shuffle, recovery, or distributed benchmark results.

See [student assignment](STUDENT_ASSIGNMENT.md) and [student template](student_tasks.py).
