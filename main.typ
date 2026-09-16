#align(center)[== Tree Width, Dynamic Programming, and Tensor Network Contraction]

#align(center)[Longli Zheng]

We consider computational hard problems on graph in this note.
And among them, a large part is about calculation or optimization of some kind of global quantity under local constraint.
An example is the independent set problem, it is about the size of independent set, which is a global structure across the whole graph, under local contraint, which is two vertices connected by an edge cannot show up at the same time.

=== Divide and Conquer

A natrual thought is to divide a bigger problem into several smaller ones to solve.
Assume that we find such a separation of the graph $G$ into three vertex subsets $A$, $B$, and $S$ that with the property
$
  A union B union S = V_G, forall a in A, forall b in B, a b in.not E_G,
$
which means $A$ and $B$ are not directly connected, connection between them must go through vertices in $S$.
Under this setting, by fixing the vertices in $S$, we can then solve independent set for $A$ and $B$ separated (since there are no connection between, the local constraints in $A$ would not affect $B$).
After that, we can then just union their results to get the result for original problem on $G$.
Or, in a bottom-up way, we can solve the problem of $A union S$ and $B union S$, then iterate through possible configuration of $S$ to get final result.

=== Tree Decomposition

The above mentioned process can be done recursively, i.e., we apply similar separation to the subgraphs $A union S$ and $B union S$ and on and on and on.
This process would give us a tree called tree decomposition of this graph, the nodes are subsets of vertices.
And it has three defining properties:
1. union of every node is the total vertex set,
2. every edge can be found inside a certain node,
3. every node containing a certain vertex form a subtree.
The first property is trivial. The second one is clear from the construction: we apply this decomposition (or separation) exactly because there are no edges between $A$ and $B$, edges can only be inside $A union S$, $B union S$, or $S$.
The third one is also easy to see: the two children $A union S$ and $B union S$ are supersets of $S$, so if a vertex shows up in a node, it would surely show up in following nodes.

=== Dynamic Programming on Tree Decomposition

Dynamic programming on tree decomposition is pretty straight forward.
All we need is to calculate a "table" for each tree node from bottom to top,
denoted as a map $T_k (hat(S)_k)$, where $hat(S)_k$ is the configuration of vertices in this node and its value is the size of maximum independent set of this subgraph under fixed configuration $hat(S)_k$.
This table is of size $2^(|"node"|)$ (iteration over all possible configuration of the node).
To get the table of a parent node, it is effectively a (tropical) "contraction" of its children tables
$
  max_hat(S)(T_1 (hat(A) union hat(S)) + T_2 (hat(B) union hat(S))).
$

// TBA: nice tree, tree width algorithm

=== Reference

Parameterized Algorithms, chapter 7


