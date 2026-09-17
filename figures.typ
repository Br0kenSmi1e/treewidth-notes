#import "@preview/cetz:0.4.2": canvas, draw

#let ink = rgb("24364B")
#let blue = rgb("2869A0")
#let teal = rgb("087F82")
#let amber = rgb("B56719")
#let pale = rgb("EAF4F4")
#let muted = rgb("63758A")
#let node(p, label, color: ink, fill: white) = {
  draw.circle(p, radius: .23, fill: fill, stroke: (paint: color, thickness: 1.2pt))
  draw.content(p, text(size: 10pt, fill: color, weight: "semibold", label))
}
#let edge(a, b, fill: false) = draw.line(a, b, stroke: (paint: if fill {amber} else {ink}, thickness: 1.2pt, dash: if fill {"dashed"} else {"solid"}))
#let label(p, body, color: ink, size: 10pt) = draw.content(p, text(size: size, fill: color, body))
#let bag(p, body, accent: false, width: 2.2) = {
  let (x, y) = p
  draw.rect((x - width / 2, y - .34), (x + width / 2, y + .34), radius: .12, fill: if accent {pale} else {rgb("F2F5F9")}, stroke: (paint: if accent {teal} else {blue}, thickness: 1pt))
  label(p, body, color: if accent {teal} else {ink})
}
#let hexpoints = ((0, 1.5), (1.3, .75), (1.3, -.75), (0, -1.5), (-1.3, -.75), (-1.3, .75))
#let cycle-six(shift: (0, 0), fills: (), selected: ()) = {
  let p = hexpoints.map(q => (q.at(0) + shift.at(0), q.at(1) + shift.at(1)))
  for i in range(6) { edge(p.at(i), p.at(calc.rem(i + 1, 6))) }
  for (i, j) in fills { edge(p.at(i - 1), p.at(j - 1), fill: true) }
  for i in range(6) { node(p.at(i), str(i + 1), color: if selected.contains(i + 1) {teal} else {ink}, fill: if selected.contains(i + 1) {pale} else {white}) }
}

#let separator-figure() = canvas({
  import draw: *
  rect((-3.6, -1.45), (-1.25, 1.45), radius: .2, fill: rgb("EFF4FA"), stroke: none)
  rect((1.25, -1.45), (3.6, 1.45), radius: .2, fill: rgb("EFF4FA"), stroke: none)
  rect((-.55, -1.45), (.55, 1.45), radius: .2, fill: pale, stroke: none)
  let a = (-2.8, .7); let b = (-2.8, -.7); let c = (-1.6, 0)
  let x = (0, .8); let y = (0, -.8)
  let d = (1.6, 0); let e = (2.8, .7); let f = (2.8, -.7)
  for (u,v) in ((a,b),(a,c),(b,c),(c,x),(b,y),(x,d),(y,d),(d,e),(d,f),(e,f)) { edge(u,v) }
  for (p,t) in ((a,"a"),(b,"b"),(c,"c"),(d,"d"),(e,"e"),(f,"f")) { node(p,t) }
  node(x,"x",color:teal,fill:pale); node(y,"y",color:teal,fill:pale)
  label((-2.4, 1.8), [side $A$], color: blue)
  label((0,1.8), [boundary $S$], color: teal)
  label((2.4,1.8), [side $B$], color: blue)
  label((0,-1.85), [Fix the choices on $S$: the two sides become independent.])
})

#let decomposition-figure() = canvas({
  import draw: *
  cycle-six(shift: (-3.9, 0))
  label((-3.9, 2.1), [Original graph: a cycle], color: blue)
  line((-1.9,0),(-.9,0), mark: (end: ">"), stroke: muted)
  let ps = ((.7,1.5),(3.5,1.5),(3.5,-.4),(.7,-.4))
  for i in range(3) { edge(ps.at(i),ps.at(i+1)) }
  bag(ps.at(0), [1, 2, 3],accent:true)
  bag(ps.at(1), [1, 3, 4],accent:true)
  bag(ps.at(2), [1, 4, 5],accent:true)
  bag(ps.at(3), [1, 5, 6],accent:true)
  label((2.1,2.1), [A tree of four bags], color: blue)
  label((2.1,-1.45), [Vertex 1 stays on a connected path.], color:teal)
  label((2.1,-1.95), [Largest bag: 3 vertices → width 2.])
})

#let elimination-figure() = canvas({
  import draw: *
  let sq = ((-1,1),(1,1),(1,-1),(-1,-1))
  for (offset, title) in ((-3.1,[Before: eliminate $a$]),(3.1,[After: keep the fill edge])) {
    let p = sq.map(q => (q.at(0)+offset,q.at(1)))
    if offset < 0 {
      for i in range(4) {edge(p.at(i),p.at(calc.rem(i+1,4)))}
      edge(p.at(1),p.at(3),fill:true)
      for (i,t) in ("a","b","c","d").enumerate() {node(p.at(i),t,color:if i==0 {teal}else{ink},fill:if i==0 {pale}else{white})}
    } else {
      edge(p.at(1),p.at(2)); edge(p.at(2),p.at(3)); edge(p.at(1),p.at(3),fill:true)
      for (i,t) in ((1,"b"),(2,"c"),(3,"d")) {node(p.at(i),t)}
    }
    label((offset,1.65),title,color:blue)
  }
  line((-1.3,0),(1.4,0),mark:(end:">"),stroke:muted)
  label((0,.45),[join $b$ and $d$],color:amber)
  label((0,-1.7),[Elimination bag: $\{a,b,d\}$. Two surviving neighbors → width 2.])
})

#let pmc-figure() = canvas({
  import draw: *
  cycle-six(shift: (-3.6,0),selected:(1,3,5),fills:((1,3),(3,5),(1,5)))
  label((-3.6,2.05), [A valid candidate: $Omega = \{1,3,5\}$],color:blue)
  label((-3.6,-2.1), [Each missing pair has an outside witness.])
  cycle-six(shift:(3.6,0),selected:(1,3))
  label((3.6,2.05), [A separator, but not a PMC: $\{1,3\}$],color:blue)
  label((3.6,-2.1), [Component $\{2\}$ sees the entire candidate.])
})

#let boundary-figure() = canvas({
  import draw: *
  for (x, completed) in ((-3.4,false),(3.4,true)) {
    let a = (x - 1,1); let b = (x,0); let c = (x + 1,1)
    edge(a,b); edge(b,c)
    if completed { edge(a,c,fill:true) }
    node(a,"1",color:teal,fill:pale)
    node(b,"2")
    node(c,"3",color:teal,fill:pale)
    label((x,1.7),if completed {[$R(S,C)$: require a common boundary bag]} else {[$G[S union C]$: ignore the boundary]},color:blue)
    if completed {
      bag((x,-1),[1, 2, 3],accent:true)
      label((x,-1.7),[Boundary $\{1,3\}$ fits in one bag.],color:teal)
      label((x,-2.15),[Constrained width = 2])
    } else {
      edge((x - 1,-1),(x + 1,-1))
      bag((x - 1,-1),[1, 2],width:1.5)
      bag((x + 1,-1),[2, 3],width:1.5)
      label((x,-1.7),[No bag contains both 1 and 3.])
      label((x,-2.15),[Unconstrained width = 1])
    }
  }
})

#let recurrence-figure() = canvas({
  import draw: *
  for x in (-3.5,0,3.5) {
    edge((0,1.5),(x,-.2))
    bag((x,-.2), if x < 0 {[$F(S_1,C_1)$]} else if x == 0 {[$F(S_2,C_2)$]} else {[$F(S_3,C_3)$]},width:2.5)
  }
  bag((0,1.5),[chosen bag $Omega$],accent:true,width:3.1)
  label((0,2.25),[Try a candidate → pay for its largest piece.],color:blue)
  label((-3.4,.85),[attach along $S_1$],size:9pt)
  label((3.4,.85),[attach along $S_3$],size:9pt)
  label((0,-1),[$max (|Omega|-1, F(S_1,C_1), F(S_2,C_2), F(S_3,C_3))$])
})

#let worked-figure() = canvas({
  import draw: *
  cycle-six(shift:(-3.5,0),selected:(1,3,5),fills:((1,3),(3,5),(1,5)))
  label((-3.5,2.05),[Complete the central triangle],color:blue)
  let root = (2, .6)
  for p in ((-.1,-1.2),(2,2),(4.1,-1.2)) {edge(root,p)}
  bag(root,[1, 3, 5],accent:true,width:2)
  bag((-.1,-1.2),[1, 2, 3],width:1.8)
  bag((2,2),[3, 4, 5],width:1.8)
  bag((4.1,-1.2),[1, 5, 6],width:1.8)
  label((2,-2.05),[One root bag + three solved blocks],color:blue)
})
