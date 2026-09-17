# Treewidth and the Bouchitté–Todinca algorithm

A ten-page illustrated note, written in Typst with seven editable CeTZ diagrams, revised after an online cross-check of primary papers and teaching material.

- **`main.typ`** — your original draft, preserved unchanged.
- **`treewidth-bt-note.pdf`** — compiled illustrated note.
- **`treewidth-bt-note.typ`** — separate note: text, equations, layout, and references.
- **`figures.typ`** — reusable CeTZ drawing functions and diagrams.
- **`ref/`** — supplied and newly fetched reference PDFs.
- **`online-survey.md`** — source passages, claim checks, and revision rationale.
- **`tests/verify_bt.py`** — small-graph recurrence checks against exhaustive elimination.

## Build

```sh
typst compile treewidth-bt-note.typ treewidth-bt-note.pdf
```

For live updates:

```sh
typst watch treewidth-bt-note.typ treewidth-bt-note.pdf
```

Tested with Typst 0.15.1 and CeTZ 0.4.2. Typst downloads the pinned CeTZ package on the first build if it is not cached. Fonts: Libertinus Serif and DejaVu Sans Mono.

## Reading route

Separators → tree decompositions → elimination and chordal completions → potential maximal cliques → boundary-constrained states → BT recurrence → six-cycle example → correctness and complexity → independent-set dynamic programming → sources.

## Check the recurrence

```sh
python3 tests/verify_bt.py
```

Uses only the Python standard library. Checks all 1,099 labeled graphs with 1–5 vertices, the six-cycle, and 60 seeded random graphs with 6–7 vertices. This finite regression test supports, but does not replace, the cited correctness argument.

“BT” means **Bouchitté–Todinca**, not a generic backtracking algorithm. The note distinguishes finding a decomposition from solving a problem on one, minimal from minimum triangulations, and the cost of candidate enumeration from the cost of the dynamic program.
