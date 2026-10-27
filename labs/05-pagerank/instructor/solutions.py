"""Instructor key for student_tasks.py."""
from collections import defaultdict
def out_degree(graph,page):
    return len(graph[page])
def contributions(graph,ranks):
    return [(dest,ranks[node]/len(links)) for node,links in graph.items() if links for dest in links]
def group_contributions(pairs):
    result=defaultdict(list)
    for key,value in pairs:
        result[key].append(value)
    return dict(result)
def dangling_mass(graph,ranks):
    return sum(ranks[node] for node,links in graph.items() if not links)
def pagerank_step(graph,ranks,damping=.85):
    if not graph: raise ValueError("empty graph")
    n=len(graph)
    grouped=group_contributions(contributions(graph,ranks))
    base=(1-damping)/n + damping*dangling_mass(graph,ranks)/n
    return {node:base+damping*sum(grouped.get(node,[])) for node in graph}
def pagerank_until_convergence(graph,damping=.85,tol=1e-10,max_iterations=1000):
    if not graph: raise ValueError("empty graph")
    scores={node:1/len(graph) for node in graph}
    for iteration in range(1,max_iterations+1):
        new=pagerank_step(graph,scores,damping)
        difference=sum(abs(new[node]-scores[node]) for node in graph)
        scores=new
        if difference<tol: return scores,iteration
    return scores,max_iterations
