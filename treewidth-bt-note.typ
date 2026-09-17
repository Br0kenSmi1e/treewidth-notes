#import "figures.typ": *

#set document(title: "Treewidth and the Bouchitté–Todinca algorithm", author: "Longli Zheng", description: "An illustrated introduction to separators, tree decompositions, and exact treewidth via potential maximal cliques.")
#set page(paper: "a4", margin: (x: 21mm, top: 19mm, bottom: 19mm), header: context {
  if counter(page).get().first() > 1 {
    text(size: 8pt, fill: muted, tracking: .7pt)[TREEWIDTH / AN ILLUSTRATED NOTE]
    line(length: 100%, stroke: .4pt + rgb("D7E0E9"))
  }
}, footer: context align(right, text(size: 9pt, fill: muted)[#counter(page).display("1") / #counter(page).final().first()]))
#set text(font: "Libertinus Serif", size: 11pt, fill: ink)
#set par(justify: true, leading: .65em)
#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 21pt, fill: blue, weight: "semibold")
#show heading.where(level: 2): set text(size: 13pt, fill: teal)
#set math.equation(numbering: none)
#set figure(gap: 8pt)
#show figure.caption: set text(size: 9pt, fill: muted)
#let tw = math.op("tw")
#let cc = math.op("cc")
#let note(title, body) = block(width: 100%, inset: 11pt, radius: 4pt, fill: pale)[
  #text(fill: teal, weight: "bold", title) #h(.3em) #body
]
#let kicker(body) = text(size: 9pt, fill: teal, tracking: 1.2pt, weight: "bold", body)

#kicker[GRAPH ALGORITHMS · INTUITION TO RECURRENCE]
#v(6pt)
#text(size: 32pt, weight: "bold", fill: ink)[Treewidth]
#v(1pt)
#text(size: 21pt, fill: blue)[and the Bouchitté–Todinca algorithm]
#v(6pt)
#text(size: 11pt, fill: muted)[An illustrated note · Longli Zheng]
#v(12pt)

When we solve a graph problem in parts, each part must remember how it interacts with the rest. For many problems, the difficult step is keeping track of the vertices involved in those interactions. *Treewidth measures how small we can keep the largest group of vertices handled together*, using a tree of overlapping groups called bags.

We first explain why these bags make computation easier. Then we ask how to find the best possible bags. The *Bouchitté–Todinca (BT) algorithm* searches over regions with prescribed boundaries. It tries one candidate bag, solves the regions left behind, and reuses the answers. The term *potential maximal clique* identifies which bags it needs to try.

= Start with a boundary
Let $G=(V,E)$ be a finite, simple, undirected graph. Split its vertices into disjoint sets $A,S,B$, with no edge from $A$ to $B$. We call $S$ a *separator* between the two sides. For a problem whose constraints involve only vertices and edges, fixing the choices on $S$ removes any direct interaction between $A$ and $B$.

#figure(separator-figure(), caption: [A separator controls interaction between the two sides. Shaded regions indicate vertex sets, not additional graph edges.])

For example, an *independent set* contains no pair joined by an edge. Suppose we fix its intersection $X$ with $S$. Vertices adjacent to $X$ cannot be selected, but after imposing that condition we may optimize the two sides separately.

#note[The source of tractability.][A boundary of $s$ vertices has at most $2^s$ in/out assignments. Small boundaries can make a large graph manageable. We need a decomposition that keeps this control throughout the whole computation, not just at the first split.]

#pagebreak()
= A tree of overlapping bags
A *tree decomposition* consists of a tree $T$ and a vertex set $B_t subset.eq V$, called a *bag*, at every tree node $t$. It must satisfy three rules:

+ *Cover vertices.* Every graph vertex occurs in at least one bag.
+ *Cover edges.* For every edge $u v in E$, some bag contains both $u$ and $v$.
+ *Keep occurrences connected.* For each vertex $v$, the tree nodes whose bags contain $v$ form a connected subtree of $T$.

The third rule lets adjacent bags coordinate all shared choices. A vertex cannot disappear and then reappear across a gap. It *may* stop appearing once we enter a branch that no longer needs it; it need not occur in every descendant bag.

#figure(decomposition-figure(), caption: [A width-2 decomposition of the six-cycle. The right-hand drawing is a path, hence a tree, even though the original graph has a cycle. Every cycle edge appears in a bag.])

*Why edge coverage is not enough.* The bag path $\{a,b\}$—$\{b,c\}$—$\{a,c\}$ covers every edge of a triangle, but is invalid: $a$ disappears in the middle. Without rule 3, it would falsely suggest that a triangle has width 1.

== Why the overlaps really separate
Delete a tree edge $t u$. Let $V_L$ and $V_R$ be the unions of bags in the two remaining tree components. The connected-occurrence rule gives
$ V_L inter V_R = B_t inter B_u. $
There is no graph edge between $V_L without V_R$ and $V_R without V_L$: an edge-covering bag would put both endpoints on the same side. Thus the overlap is a genuine separator.

== Width counts the largest bag
$ "width"(T,(B_t)) = max_(t in V(T)) |B_t| - 1, quad
  tw(G) = min_((T,(B_t))) "width"(T,(B_t)). $
The minus one makes a tree with at least one edge have treewidth 1: root it and use a bag $\{v,"parent"(v)\}$ for each nonroot vertex. An edgeless nonempty graph has treewidth 0. A complete graph on $r$ vertices has treewidth $r-1$; every clique must fit in some bag.

#note[A split is not yet a small-width decomposition.][Keeping the whole graph as a root bag already gives width $|V|-1$, however small the later separators are. We must build small bags throughout, while preserving their shared vertices.]

#pagebreak()
= From bags to chordal completions
The definition searches over trees of sets. A different description makes the search easier to organize: add edges until the graph becomes *chordal*. A graph is chordal if every cycle of length at least four has an edge joining two nonconsecutive cycle vertices, called a *chord*.

== Eliminate a vertex, retain its interactions
When we optimize over a vertex $v$, its contribution can become a joint function of its remaining neighbors. For example, when eliminating the first vertex of an unweighted independent-set problem, its best contribution is 1 if all its neighbors are unselected, and 0 otherwise. That function depends on the neighbors *together* [3].

Graph elimination records this dependence: join all remaining neighbors of $v$, then remove $v$. The new edges are *fill edges*. The set consisting of $v$ and those neighbors is its elimination bag.

#figure(elimination-figure(), caption: [Eliminating a corner of a four-cycle adds the dashed edge. Ignoring fill would underestimate the size of later elimination bags.])

For an ordering $pi$, let $N_pi^+(v)$ be the neighbors of $v$ still present when $v$ is removed, *including neighbors created by earlier fill*. The decomposition/elimination equivalence [2, 6] gives
$ tw(G) = min_pi max_(v in V) |N_pi^+(v)|. $
*Order matters:* a star with $r$ leaves has width 1 if we eliminate leaves first. Eliminating its center first makes a bag of size $r+1$ and gives width $r$. Width measures the best ordering, not an arbitrary one.

== The bridge used by BT
Retain all original and fill edges on the original vertex set: the result is chordal. Its *maximal cliques*—cliques not contained in larger ones—can be arranged as a tree decomposition, called a *clique tree*. Conversely, completing every bag of a decomposition gives a chordal supergraph. If $omega(H)$ is the largest clique size, then
$ tw(G) = min_(H " chordal", E(G) subset.eq E(H)) (omega(H)-1). $
Here and below all completions keep the vertex set fixed. A chordal completion is also called a *triangulation*, even when the graph is not planar.

#note[Minimal is not minimum.][A triangulation is *minimal* if no proper subset of its added edges still makes the graph chordal. It need not use the fewest fill edges, nor have the smallest largest clique. An optimal-width triangulation can always be reduced to a minimal one: deleting unnecessary fill cannot increase its largest clique.]

This last observation is what lets BT restrict its search: we only need bags that occur as maximal cliques in *some minimal triangulation*.

#pagebreak()
= Which bags are worth trying?
== Minimal separators and full components
For a vertex set $C$, let $N_G(C)$ be all vertices outside $C$ with a neighbor in $C$. Write $cc(H)$ for the vertex sets of the connected components of a graph $H$.

A set $S$ is a *minimal separator* if, for some two vertices outside $S$, it separates them and no proper subset does. “Minimal” refers to that pair, not to the smallest cardinality among all separators. A component $C in cc(G-S)$ is *full* for $S$ when $N_G(C)=S$.

A useful characterization is: *$S$ is a minimal separator if and only if $G-S$ has at least two full components.* Each full component touches every boundary vertex; leaving any one of those vertices undeleted reconnects the two full components through it.

== Potential maximal cliques: the BT candidate bags
A *potential maximal clique* (PMC) is a set $Omega$ that is a maximal clique in at least one minimal triangulation of $G$. Think of it as a *candidate bag with a structural guarantee*, not necessarily a clique already present in $G$. Write $Pi(G)$ for the family of all PMCs.

The definition mentions an unknown completion, but BT gives a test in the original graph. Compute $C_i in cc(G-Omega)$ and $S_i=N_G(C_i)$. Then $Omega$ is a PMC *exactly when* both conditions hold:

+ *No full outside component:* $S_i subset.neq Omega$ for every $i$.
+ *Every missing pair has a witness:* for every nonedge $u v$ within $Omega$, some $S_i$ contains both $u$ and $v$. Equivalently, completing all $S_i$ into cliques makes $Omega$ a clique.

#figure(pmc-figure(), caption: [On the six-cycle, the outside singleton components 2, 4, and 6 witness the three dashed edges of the valid PMC. The candidate on the right fails the first test, despite being a minimal separator.])

For the left candidate, vertex 2 witnesses the missing edge $13$, vertex 4 witnesses $35$, and vertex 6 witnesses $15$. On the right, the outside component $\{2\}$ touches *every* vertex of $\{1,3\}$, so the candidate is rejected.

The first test forbids an outside component from having the whole candidate as its boundary. The second ensures that component boundaries account for every missing edge inside it. Together they are necessary and sufficient; this is the BT characterization theorem [1, Theorem 3.15; 4, Theorem 2.4]. Individual PMCs are candidates, not bags that must all coexist in one optimal decomposition.

#pagebreak()
= Recursing on the remaining pieces
Section 4 tells us which bags to try: the PMCs. *After choosing one, repeat the bag choice inside each remaining connected piece.* The only extra requirement is that the next bag must contain the boundary shared with its parent.

On the six-cycle, suppose we chose the parent bag $\{1,5,6\}$. The remaining interior is $C=\{2,3,4\}$, with boundary $S=\{1,5\}$. Try $Omega=\{1,3,5\}$ next: it keeps that boundary and includes vertex 3. This leaves vertices 2 and 4 as separate child interiors.

#figure(block-step-figure(), caption: [One choice of next bag. Vertex 2 needs boundary 1, 3; vertex 4 needs boundary 3, 5. Vertex 6 is already on the parent side.])

Repeat for each child: vertex 2 needs bag $\{1,2,3\}$, and vertex 4 needs bag $\{3,4,5\}$. Nothing remains inside these children, so recursion stops. All three new bags have width 2; this choice therefore scores $max(2,2,2)=2$. Try other permitted next bags and keep the smallest score.

*This becomes dynamic programming by saving answers.* Write $F(S,C)$ for the best width of a decomposition of $S union C$ with an attachment bag containing $S$. Whenever another choice produces the same interior and boundary, reuse that answer. The recurrence is
$ F(S,C)=min_(Omega in Pi(G), S subset.neq Omega subset.eq S union C)
  max(|Omega|-1,F(S_1,C_1),dots,F(S_r,C_r)). $
Here $C_i$ are the remaining components inside $C$, and $S_i=N_G(C_i)$ their boundaries in the original graph. Requiring $S subset.neq Omega$ preserves the attachment and makes the interior smaller. BT’s theorem guarantees that these PMC choices suffice [1, Corollary 4.8]. With no children, the score is just $|Omega|-1$.

For the formal state description, completing $S$ into a clique enforces the attachment bag. Call this graph $R(S,C)$, the *realization*; then $F(S,C)=tw(R(S,C))$. The states are *full blocks*: $S$ is a minimal separator and $C$ a component of $G-S$ with $N_G(C)=S$. Each child is again a full block, so compute smaller interiors first.

#note[The whole idea.][Choose the next bag that makes the largest required piece as small as possible. *Minimize over alternative bags; take the maximum over all children of each choice.*]

At the global root there is no fixed boundary: try every PMC as the first bag and solve all components outside it. The next section shows this final step.

#pagebreak()
= A complete example: the six-cycle
Take the graph with cycle edges $12,23,34,45,56,61$. Choose the PMC $Omega=\{1,3,5\}$. Removing it leaves the three singleton components $\{2\}$, $\{4\}$, and $\{6\}$.

#figure(worked-figure(), caption: [The dashed edges complete the chosen root bag. Each outside vertex forms a leaf bag with its two neighbors. The result is a width-2 tree decomposition.])

#table(columns: (1fr, 1.2fr, 1.5fr, .8fr), inset: 8pt, stroke: (bottom: .5pt + rgb("D7E0E9")), fill: (x,y) => if y==0 {pale} else {none},
  [*Interior $C$*], [*Boundary $S$*], [*Realization $R(S,C)$*], [*$F(S,C)$*],
  [$\{2\}$], [$\{1,3\}$], [Triangle on 1, 2, 3], [$2$],
  [$\{4\}$], [$\{3,5\}$], [Triangle on 3, 4, 5], [$2$],
  [$\{6\}$], [$\{1,5\}$], [Triangle on 1, 5, 6], [$2$],
)

For the first state, the original induced graph on $\{1,2,3\}$ is only a path. But the realization *also contains the boundary edge $13$*, so its width is 2, not 1. Its only admissible candidate is $\{1,2,3\}$, with no children. The other two states follow by symmetry.

The chosen root therefore gives
$ max( |\{1,3,5\}|-1, 2, 2, 2 ) = 2. $
This proves an upper bound. To certify optimality, use the fact that graphs of treewidth at most 1 are exactly forests. The six-cycle is not a forest, so its treewidth is at least 2. Together, the bounds give $tw(G)=2$.

== Why one successful candidate is not the whole algorithm
In this example a known lower bound already proves optimality. In general BT must minimize over all admissible candidates. A poor choice of the root can force large child realizations, even when the root bag itself is small. *Choosing the smallest available bag greedily is not the recurrence.*

#note[Recovering the decomposition.][Store a minimizing candidate with each state. Recursively create a bag for that candidate, then attach each child’s root bag to it. The parent and child roots both contain $S_i$, so every shared vertex stays connected. The same construction at the global root yields an optimal decomposition.]

#pagebreak()
= Why it works, and what it costs
== Two directions establish exactness
*Every candidate gives a valid upper bound.* Make $Omega$ the root bag. Attach optimal decompositions of all child realizations at bags containing their clique boundaries $S_i$. All original edges are covered. Vertices outside $Omega$ belong to just one child region; vertices in $Omega$ remain connected through the root. The largest bag has exactly the cost used in the recurrence.

*Some candidate attains the optimum.* Take a minimal triangulation of optimal width. At the global root, any maximal clique is a PMC. Inside a full-block realization, BT proves that some maximal clique strictly contains $S$ and is a PMC of the original graph. The pieces beyond this clique are precisely smaller block realizations [1, Theorem 4.7]. Replacing each piece by its optimal solution cannot raise the width. Thus the minimum omits no optimal solution.

== An implementable outline
#block(fill: rgb("F2F5F9"), inset: 12pt, radius: 4pt)[
#text(font: "DejaVu Sans Mono", size: 9pt)[
1. Enumerate all PMCs Ω using the two tests on page 4.\
2. Enumerate minimal separators S and their full blocks.\
3. Precompute components of G − Ω and their neighborhoods.\
4. For (S,C) in increasing order of |C|:\
#h(1em) try every PMC with S ⊊ Ω ⊆ S ∪ C;\
#h(1em) keep the smallest max(bag width, child values).\
5. Try all root PMCs; store a minimizing root.\
6. Follow stored choices to output a tree decomposition.
]
]
For a simple exact implementation, test every nonempty vertex subset for being a PMC. Separately, test every subset $S$ for having at least two full components to enumerate minimal separators. This is sufficient to implement the recurrence; faster enumeration is a separate algorithmic improvement.

== Polynomial in the candidate families—not in general
Let $n=|V|$, $p=|Pi(G)|$, and $d$ be the number of minimal separators. The original BT algorithm has an $O(n^2 d p)$ bound once all PMCs are supplied [1, Theorem 4.9]. A later implementation achieves $O(n^3 p)$ when the PMC and minimal-separator lists are given [4, Theorem 3.4]. It precomputes compatible block–bag pairs rather than scanning every bag for every block.

These are *DP costs after enumeration*, not polynomial-time bounds in $n$ alone. Testing all subsets for PMCs takes $O(2^n n^3)$ with the elementary test; the candidate families can themselves be exponentially large. The simple outline above does not automatically achieve the optimized bound.

#note[What if we keep only some PMCs?][The same DP finds the best decomposition using those candidates, if one exists [5]. Use $+infinity$ for states with no feasible candidate. A finite result is an upper bound on $tw(G)$. Failure means the family is insufficient—not that the graph has no small-width decomposition. Exactness needs a complete search or a matching lower bound.]

#pagebreak()
= What small treewidth buys you
Return to maximum independent set, now *after* a width-$k$ decomposition has been found. Each bag has at most $k+1$ vertices, so a bag table has at most $2^(k+1)$ in/out assignments. This explains why the width, rather than the total number of vertices, controls the exponential part of many algorithms.

== A separator formula with correct accounting
In the split on page 1, fix an independent set $X subset.eq S$. Let $f_A(X)$ be the maximum number of chosen vertices *in $A$ only*, subject to their union with $X$ being independent; define $f_B(X)$ similarly. Then
$ alpha(G) = max_(X subset.eq S, X " independent")
  (|X| + f_A(X) + f_B(X)). $
Here $alpha(G)$ is the maximum independent-set size. Counting the boundary only once is important. If instead both child tables include $X$ in their totals, subtract $|X|$ when adding them.

== The same rule on a tree decomposition
Root the bag tree. Let $U_t$ be all vertices occurring in bags in the subtree rooted at $t$. For each independent $X subset.eq B_t$, store
$ D_t(X) = max \{|I| : I subset.eq U_t, I " independent", I inter B_t = X\}. $
A standard *nice tree decomposition* replaces the original tree by a rooted form whose steps introduce one vertex, forget one vertex, or join two subtrees with the same bag. This changes neither the width nor the problem. At a join with bag $B$ and children $a,b$,
$ D_t(X) = D_a(X) + D_b(X) - |X|. $
The subtraction removes the double count of the shared bag. The two child interiors have no edges between them, by the separator property. Introduce steps check adjacency against selected bag vertices; forget steps maximize over whether the forgotten vertex was selected. On a nice decomposition with $O((k+1) n)$ bags, these operations give time $2^(k+1)$ times a polynomial in $k$ and $n$.

#note[Keep the two tables distinct.][$F(S,C)$ searches for the best *decomposition width* using graph blocks and PMCs. $D_t(X)$ solves an *application* using a decomposition already supplied. Their states, objectives, and recurrences are different.]

== Why forgetting information is safe
Suppose a vertex no longer appears in the bag connecting a processed subtree to the rest. It cannot appear anywhere outside that subtree: otherwise its occurrences would be disconnected. Every constraint involving that vertex has therefore already been dealt with inside the subtree. We retain the best value for each boundary assignment, not the forgotten choices themselves.

This is the common reason both dynamic programs work. The boundary records what the remaining computation needs. BT optimizes how to arrange those boundaries; the application table optimizes the choices made behind them.

#pagebreak()
= Sources and reading guide
The mathematical claims above use the original BT paper and a later exact-algorithm treatment. The teaching sources supply complementary explanations of elimination and intermediate tables. The six-cycle and boundary examples are worked out explicitly in this note.

#text(size: 10pt)[
[1] V. Bouchitté and I. Todinca. *Treewidth and Minimum Fill-in: Grouping the Minimal Separators.* SIAM Journal on Computing *31*(1), 212–232 (2001). #link("https://doi.org/10.1137/S0097539799359683")[doi:10.1137/S0097539799359683]. Theorem 3.15: PMC recognition; Corollary 4.8: block recurrence; Theorem 4.9: complexity. Local copy: `ref/s0097539799359683.pdf`.

[2] M. Cygan et al. *Parameterized Algorithms.* Springer (2015), Chapter 7, “Treewidth.” #link("https://doi.org/10.1007/978-3-319-21275-3")[doi:10.1007/978-3-319-21275-3]. Tree decompositions, elimination, and dynamic programming on nice decompositions. Local copy: `ref/parameterized-algorithms.pdf`.

[3] Carnegie Mellon University, 10-708, *Lecture 4: Exact Inference* (2019). #link("https://www.cs.cmu.edu/~epxing/Class/10708-19/notes/lecture-04/")[Online lecture notes]. See “Variable Elimination” and “Graph Elimination”: eliminating a variable creates a factor on the remaining neighbors, explaining fill edges and the dependence of cost on the ordering.

[4] F. V. Fomin, D. Kratsch, I. Todinca, and Y. Villanger. *Exact Algorithms for Treewidth and Minimum Fill-In.* SIAM Journal on Computing *38*(3), 1058–1079 (2008). #link("https://doi.org/10.1137/050643350")[doi:10.1137/050643350]. #link("https://fedorvf.github.io/articles/2008/2008b.pdf")[Author-hosted full text]. Theorem 2.4: PMC test; Theorem 3.3: full-block recurrence; Theorem 3.4: $O(n^3 |Pi(G)|)$ DP with candidate lists supplied.

[5] H. Tamaki. *A heuristic use of dynamic programming to upperbound treewidth.* #link("https://arxiv.org/abs/1909.07647")[arXiv:1909.07647v2] (2019). Sections 3–4 explain BT with a restricted PMC family. This supports the distinction between an upper bound from selected bags and an exact answer from a complete search. Tamaki also refines width by counting largest bags; this note uses only the usual scalar width.

[6] MIT 6.854, *Lecture 15: Treewidth*, D. Karger; scribe J. Provine (2004; hosted in the 2018 course archive). #link("https://courses.csail.mit.edu/6.854/18/Scribe/s25-online/s25-online.html")[Online lecture notes]. The opening “Review” gives the decomposition/elimination equivalence and the tree and cycle examples.
]

== Which steps are easy, and which are theorems?
The separator property of adjacent bags follows directly from the three decomposition rules. The equivalence between completing a boundary and requiring it in one bag uses the clique-in-a-bag property. The min–max objective follows from how width is measured.

The deeper BT results are the characterization of PMCs and the guarantee that an optimal full-block solution has an admissible PMC at its attachment bag. They justify the restricted search; the intuitive splitting argument alone does not prove that no optimal solution is missed.
