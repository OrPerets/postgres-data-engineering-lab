# Lab 06 — Regex & TF-IDF

**Goal:** Transform raw text into structured features, then compute term importance locally and through MapReduce-style aggregation.

## Start
```bash
make lab-tfidf
```

[Student code](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/06-tfidf/student_tasks.py) · [Assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/06-tfidf/STUDENT_ASSIGNMENT.md)

## From messy text to tokens
Given `Printer JAM!!! Ticket=TKT-1042`, extract the ticket identifier, normalize text and inspect tokens.

**Predict:** Should `TKT-12` match a ticket ID requiring 4–6 digits?

## Four computation stages
1. Count `(term, document)` occurrences.
2. Calculate document length and normalized term frequency.
3. Count the distinct documents that contain each term.
4. Compute TF-IDF.

This lab uses **natural log** smoothing:

```text
TF = term_count / document_length
IDF = ln((N+1) / (df+1))
TF-IDF = TF * IDF
```

The lecture also shows a base-2 log example, which gives different numerical scores. Do not mix conventions.

## Practice
Complete the functions in `student_tasks.py`; run:

```bash
cd labs/06-tfidf
python -m unittest discover -s tests -v
```

## SQL comparison
Use PostgreSQL `sql/02_reference_query.sql` to calculate the same formula with `ln(...)`. Compare to Python.

## Performance
Try:

```bash
python benchmark.py --documents 100 1000 --workers 2 4 --trials 3
```

Global document frequency remains centrally aggregated in the multi-process demo, illustrating a scaling bottleneck. [Performance assignment](https://github.com/OrPerets/postgres-data-engineering-lab/blob/main/labs/06-tfidf/PERFORMANCE_ASSIGNMENT.md).
