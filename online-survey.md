# Online cross-check and revision rationale

This is a targeted literature and teaching-material check for `treewidth-bt-note.typ`, not a comprehensive survey of current treewidth algorithms. Search summaries were used to locate sources; the mathematical changes below were checked against fetched full texts.

## Sources actually consulted

### 1. Fomin, Kratsch, Todinca, Villanger (2008)

*Exact Algorithms for Treewidth and Minimum Fill-In*, SIAM J. Comput. 38(3), 1058–1079.

- DOI: https://doi.org/10.1137/050643350
- Fetched full text: https://fedorvf.github.io/articles/2008/2008b.pdf
- Saved as `ref/fomin-et-al-2008.pdf`.
- **Theorem 2.4:** the PMC test requires no full outside component and completion of all component neighborhoods into a clique on the candidate. It also establishes that those neighborhoods are minimal separators.
- **Theorem 3.3:** the full-block recurrence minimizes over original-graph PMCs with strict boundary inclusion and combines the bag width with the child-realization widths by a maximum.
- **Theorem 3.4, exact passage:** “given a graph G together with the list of its minimal separators ... and the list of its potential maximal cliques ... computes the treewidth ... in O(n³ |Π_G|) time.”
- The proof precomputes compatible block–PMC triples; this bound does not apply automatically to naive nested scans and does not include generating the input lists.

### 2. Hisao Tamaki (2019), arXiv v2

*A heuristic use of dynamic programming to upperbound treewidth*.

- https://arxiv.org/abs/1909.07647
- Fetched https://arxiv.org/pdf/1909.07647; saved as `ref/tamaki-2019.pdf` (v2, 24 October 2019).
- **Abstract, exact passage:** the algorithm “can readily be applied to an arbitrary non-empty subset Π of Π(G) and computes tw(G, Π), or reports that it is undefined”.
- **Proposition 3.7 and Section 4.1:** all PMCs suffice for the exact optimum; restricting the family gives the optimum among decompositions using that family. Section 4.1 explicitly orders component states by cardinality.
- Important notation difference: Tamaki uses a lexicographic pair consisting of usual width and the number of largest bags. The note uses only scalar treewidth and the corresponding min–max recurrence; it does not copy Tamaki’s pair-valued addition as scalar addition.

### 3. CMU 10-708 (2019), Lecture 4: Exact Inference

- https://www.cs.cmu.edu/~epxing/Class/10708-19/notes/lecture-04/
- Full HTML fetched and read, especially “Variable Elimination” and “Graph Elimination”.
- **Exact passage:** “At each step before we remove a node ... connecting all neighbors ... created a clique”.
- Used for the explanation that variable elimination creates intermediate factors on remaining neighbors. The independent-set contribution example in the note is our own elementary illustration, not a quotation from the lecture.
- This is teaching material, not evidence for the BT structural theorem or its complexity.

### 4. MIT 6.854, Lecture 15: Treewidth

- https://courses.csail.mit.edu/6.854/18/Scribe/s25-online/s25-online.html
- The page itself identifies the lecture as 29 October 2004, Professor David Karger, scribe John Provine; 2018 is the hosting archive, not the lecture date.
- Full HTML fetched; used the opening “Review” for decomposition, elimination, and tree/cycle examples.
- **Exact passage:** “The treewidth of G is then the minimum induced treewidth over all possible elimination orderings.”
- Did not rely on its later SAT truth-table derivation or online-algorithm material.

### Existing primary sources retained

- Bouchitté–Todinca (2001), `ref/s0097539799359683.pdf`, DOI https://doi.org/10.1137/S0097539799359683: Theorem 3.15, Theorem 4.7, Corollary 4.8, Theorem 4.9. The newer full-text sources independently confirm the relevant characterization and recurrence.
- Cygan et al., *Parameterized Algorithms*, Chapter 7, `ref/parameterized-algorithms.pdf`, remains the general textbook reference; this revision is not a full audit of that chapter.

The dedicated fetch tool encountered fake-IP DNS restrictions. The online full texts above were successfully retrieved with HTTPS `curl`; the revision does not rely on failed fetches or only on search snippets.

## Changes to the teaching logic

1. **Separator before terminology:** explain what a computation must remember about the rest of the graph. Qualify the separation argument to vertex/edge-local constraints.
2. **Connectedness by counterexample:** the path `{a,b}—{b,c}—{a,c}` covers the triangle's edges but violates connected occurrences. A vertex need not appear in every descendant bag.
3. **Small separators alone are insufficient:** retaining all vertices in the root bag already fixes a large width.
4. **Fill has a computational meaning:** eliminating a vertex can create a joint function of its neighbors. A star shows why ordering matters. Fill is not a new independent-set constraint.
5. **State semantics before formula:** define the optimum with a bag containing the whole boundary, then prove that completing the boundary is equivalent. A new CeTZ figure contrasts an unconstrained path (width 1) with its boundary-constrained realization (width 2).
6. **Derive min–max in two steps:** first score a fixed candidate, then minimize over candidates. A threshold formulation explains the existential choice and universal child requirements.
7. **State the real theorem dependency:** the ability to restrict attachment bags to original-graph PMCs is a BT theorem, not something that follows merely from splitting components.
8. **Separate guarantees:** original versus later DP bounds; enumeration versus combination costs; exact search versus restricted-family upper bounds.

## Checks

- `typst compile treewidth-bt-note.typ treewidth-bt-note.pdf` succeeds; ten pages, seven CeTZ figures. Rendered pages were visually checked for layout and legibility.
- `python3 tests/verify_bt.py`: the scalar PMC/full-block recurrence agrees with exhaustive elimination on every labeled graph with 1–5 vertices (1,099 graphs), the six-cycle, and 60 seeded random graphs with 6–7 vertices.
- These finite checks are regression evidence, not a proof. Exactness rests on the cited structural theorems and the decomposition gluing argument.
