# Lab 04 — MapReduce

**Goal:** Understand Map → Shuffle → Reduce as a scalable way to process keyed data, and when a combiner is safe.

## Start
```bash
make lab-mapreduce
```

[Open student code](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/04-mapreduce/student_tasks.py) · [Assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/04-mapreduce/STUDENT_ASSIGNMENT.md)

## The five-minute example
Input: `ABR`, `CCR`, `ACB`.

1. **Map:** Emit `(character,1)` for every character.
2. **Shuffle:** Group equal keys together.
3. **Reduce:** Sum the ones.

**Predict:** What are the final counts for A, B, C and R?

## Implement
Write `word_mapper`, `filter_mapper`, mergeable mean and variance state operations in `student_tasks.py`.

## Validate
From `labs/04-mapreduce`:

```bash
python -m unittest tests.test_demo -v
python -m unittest discover -s tests -v
```

The demo should pass; the student test suite will fail until your functions are implemented.

## Think like a data engineer
Why can a combiner sum counts safely, but **averaging partial averages** can give the wrong answer? How does a hot key affect reducer balance?

This lab is a **single-process logical simulation**, not multi-node Hadoop.
