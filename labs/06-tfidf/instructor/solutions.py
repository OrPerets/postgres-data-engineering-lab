"""Instructor key for student_tasks.py. Natural log IDF, as in lecture p.26."""
import math
import re
from collections import Counter,defaultdict
def extract_ticket_id(text):
    match=re.search(r"\bTKT-[0-9]{4,6}\b",text)
    return match.group(0) if match else None
def extract_amount(text):
    match=re.search(r"\b(USD|EUR|ILS)\s?([0-9]+(?:\.[0-9]{1,2})?)\b",text)
    return match.groups() if match else None
def normalize_tokens(text):
    return re.findall(r"[a-z0-9]+",text.lower())
def count_terms(corpus):
    result={}
    for doc,text in corpus.items():
        for term,n in Counter(normalize_tokens(text)).items():
            result[(term,doc)]=n
    return result
def attach_doc_lengths(counts):
    lengths=defaultdict(int)
    for (term,doc),count in counts.items():
        lengths[doc]+=count
    return {(term,doc):(count,lengths[doc]) for (term,doc),count in counts.items()}
def document_frequencies(counts):
    by_term=defaultdict(set)
    for term,doc in counts:
        by_term[term].add(doc)
    return {term:len(docs) for term,docs in by_term.items()}
def tfidf_scores(counts,df,n_documents):
    return {(term,doc):(count/length)*math.log((n_documents+1)/(df[term]+1))
            for (term,doc),(count,length) in counts.items() if length>0}
