"""Small-graph checks for the recurrence in treewidth-bt-note.typ (standard library only).

Enumerates PMC candidates using the characterization, evaluates full-block DP,
and compares with a separate exhaustive elimination-order calculation. This is
an exponential regression check, not an efficient solver or a correctness proof.
Run from the project root: python3 tests/verify_bt.py
"""

from itertools import combinations, permutations
from functools import lru_cache
import random


def solve(n, edges):
    V = frozenset(range(n))
    adj = [set() for _ in V]
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)

    def comps(U):
        unseen = set(U)
        out = []
        while unseen:
            c = {unseen.pop()}; todo = list(c)
            while todo:
                v = todo.pop()
                new = adj[v] & unseen
                unseen -= new; c |= new; todo.extend(new)
            out.append(frozenset(c))
        return out

    def boundary(C):
        return frozenset(set().union(*(adj[v] for v in C)) - C)

    subsets = [frozenset(v for v in V if mask >> v & 1) for mask in range(1 << n)]
    pmcs = []
    for O in subsets[1:]:
        ss = [boundary(c) for c in comps(V - O)]
        if any(s == O for s in ss):
            continue
        if all(v in adj[u] or any({u,v} <= s for s in ss) for u,v in combinations(O, 2)):
            pmcs.append(O)
    blocks = set()
    for S in subsets:
        full = [c for c in comps(V-S) if boundary(c) == S]
        if len(full) >= 2:
            blocks.update((S,c) for c in full)

    @lru_cache(None)
    def F(S,C):
        assert (S,C) in blocks
        scores = []
        for O in pmcs:
            if S < O <= S | C:
                children = comps(C-O)
                assert all(len(c) < len(C) for c in children)
                scores.append(max([len(O)-1] + [F(boundary(c),c) for c in children]))
        assert scores
        return min(scores)

    bt = min(max([len(O)-1] + [F(boundary(c),c) for c in comps(V-O)]) for O in pmcs)
    best = n-1
    for order in permutations(V):
        a = [s.copy() for s in adj]; live = set(V); w = 0
        for v in order:
            ns = a[v] & live
            w = max(w,len(ns))
            if w >= best:
                break
            for u in ns:
                a[u].update(ns-{u})
            live.remove(v)
        best = min(best,w)
    assert bt == best, (n, edges, bt, best)
    return bt

count = 0
for n in range(1,6):
    all_edges = list(combinations(range(n),2))
    for mask in range(1 << len(all_edges)):
        solve(n,[e for i,e in enumerate(all_edges) if mask >> i & 1])
        count += 1
assert solve(6,[(i,(i+1)%6) for i in range(6)]) == 2
rng = random.Random(2026)
for n in (6,7):
    for _ in range(30):
        solve(n,[e for e in combinations(range(n),2) if rng.random() < .4])
print(f'PASS: BT agrees with exhaustive elimination on all {count} labeled graphs with 1–5 vertices, the six-cycle, and 60 seeded random graphs with 6–7 vertices.')
