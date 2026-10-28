# Lab 04 — MapReduce

> **Your mission:** Transform a large task into Map → Shuffle → Reduce operations and decide when local combination is safe.

**You will practice:** Key-value mapping, grouping, reducer partitioning, combiners, mean/variance aggregation and skew.

## 1. Get ready

From the repository root:

```bash
make lab-mapreduce
```

No PostgreSQL or Docker is required for this lab.

[Open student code](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/04-mapreduce/student_tasks.py) · [Full assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/04-mapreduce/STUDENT_ASSIGNMENT.md)

## 2. Predict the first output

Input records:

```text
ABR
CCR
ACB
```

**Question:** How many times does each character occur? Write your prediction before running the demo.

## 3. Understand the three stages

1. **Map:** Emit `(letter, 1)` for each occurrence.
2. **Shuffle:** Group all values belonging to the same letter.
3. **Reduce:** Sum each group into one count.

```bash
cd labs/04-mapreduce
python mapreduce_demo.py
```

**Checkpoint:** The counts should be A=2, B=2, C=3, R=2. Now change the number of reducers. Does the answer change?

## 4. Build your own functions

Open `student_tasks.py`. Implement a word mapper, a WHERE-like filter mapper, mergeable mean states and mergeable population-variance states.

### Mini challenge — Why not average averages?

Suppose one worker observes `[1]` and another observes `[3,5,7]`. Compare the naive average of worker averages to the actual mean of all four values.

**Hint:** A safe mean combiner merges `(sum, count)`, not just the average.

## 5. Validate your work

```bash
python -m unittest tests.test_demo -v
python -m unittest discover -s tests -v
```

**Expected:** Demo tests pass. Student tests initially raise `NotImplementedError`; they should pass after you implement the functions. Do not modify tests to hide errors.

## 6. Think like a distributed engineer

Why do hot keys create skew? What communication does Shuffle represent? Which combiners are unsafe, and why?

This exercise is a **single-process logical simulator**, not a real multi-machine Hadoop deployment.

**Next:** [Lab 05 — PageRank](05-pagerank.md).
