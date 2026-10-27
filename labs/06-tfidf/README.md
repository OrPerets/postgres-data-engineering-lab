# Lab 06 — Regex & TF-IDF (MapReduce + SQL)

This lab follows the 28-slide course lecture: **raw tickets/logs → regex extraction → normalized tokens → term counts → TF → DF/IDF → TF-IDF**. It builds on the MapReduce lab and can run entirely inside the existing GitHub Codespace.

## Quick start (Python only)
```bash
cd labs/06-tfidf
python tfidf_demo.py
python -m unittest tests.test_demo -v
python -m unittest discover -s tests -v
```
The student tests initially fail with `NotImplementedError` until you implement `student_tasks.py`. That failure is intentional.

## Optional SQL exercise (PostgreSQL)
This lab has its own database (port 55434), independent of other labs.
```bash
docker compose up -d --wait
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U student -d tfidf_lab < sql/01_setup.sql
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U student -d tfidf_lab < sql/02_reference_query.sql
docker compose exec postgres psql -U student -d tfidf_lab
```
Classroom credentials only: student / studentpass.

## Lecture's four-document corpus
- D1: `data science uses data.`
- D2: `data engineering builds pipelines.`
- D3: `science uses experiments.`
- D4: `engineering uses data pipelines.`

## Important: IDF logarithm convention
The lecture's page 16 table reports IDF values **0.321 / 0.736 / 1.321** for df=3 / 2 / 1, respectively. These values use **log base 2** of `(N+1)/(df+1)`. The later MapReduce calculation on page 26 uses **natural logarithm**, giving `ln(5/4)=0.2231` for data, and TF-IDF(D1,data)=0.1116.

Both conventions are mathematically valid, but the values differ. **This executable lab consistently uses natural log `ln((N+1)/(df+1))`**, as on lecture page 26; SQL `ln(...)` matches Python `math.log(...)`. Do not mix the numeric answer tables. This is not scikit-learn's default smoothed IDF (`1 + ln((N+1)/(df+1))`).

## Four logical MapReduce stages
1. Term counts: `((term,doc), 1)` → sum counts
2. Document length: group term counts by doc → `(count, doc_len)`
3. Document frequency: group by term → number of **distinct documents** containing the term
4. Score: TF × IDF and an identity reducer

The demo simulates this pipeline in one process. It does not run Hadoop or network shuffle.

## Exercises and safe data
See [STUDENT_ASSIGNMENT.md](STUDENT_ASSIGNMENT.md) and [student_tasks.py](student_tasks.py). Synthetic documents are provided in the source code and SQL. The lecture refers to `tf-idf.sql`, but that file was **not provided** with the lecture upload; `sql/02_reference_query.sql` is a new PostgreSQL implementation built for this lab, not the original lecture SQL.
