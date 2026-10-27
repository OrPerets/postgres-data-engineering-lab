SHELL := /bin/bash
.PHONY: help setup demo test benchmark health reset
LABS := 01-relational-sql 02-partitioning-replication 03-dwh-etl 04-mapreduce 05-pagerank 06-tfidf
LAB ?= 01-relational-sql
help:
	@echo "Usage: make setup|demo|test|benchmark|health|reset LAB=01-relational-sql"
	@echo "Available labs: $(LABS)"
setup demo test benchmark health reset:
	@case " $(LABS) " in *" $(LAB) "*) ;; *) echo "Unknown LAB=$(LAB)"; exit 2;; esac
	@bash scripts/lab.sh "$(LAB)" "$@"
