"""Instructor key for student_tasks.py. Keep out of student releases."""
from collections import Counter
def word_mapper(line):
    return [(word.lower(), 1) for word in line.split()]
def filter_mapper(row, min_amount):
    return [(row["region"],row["amount"])] if row["status"]=="completed" and row["amount"]>=min_amount else []
def mean_mapper(numbers):
    values=list(numbers)
    return (sum(values),len(values))
def mean_combiner(a,b):
    return (a[0]+b[0],a[1]+b[1])
def mean_reducer(state):
    return state[0]/state[1] if state[1] else None
def variance_mapper(numbers):
    values=list(numbers)
    return (len(values),sum(values),sum(x*x for x in values))
def variance_combiner(a,b):
    return tuple(x+y for x,y in zip(a,b))
def variance_reducer(state):
    n,s,ss=state
    return max(0.0,ss/n-(s/n)**2) if n else None
