
class 'UiList' extends 'UiWidget'

doc =: 'A vertically-scrolling buffer with one line highlighted.'

create =: {{
  W =: 32
  H =: 8
  S =: 0      NB. scroll position
  C =: 0      NB. cursor
  L =: y      NB. list of boxed labels
}}

fwd =: {{ C=:(<:#L)<.C+1 if. (C-S) >: H do. S =: S + 1 end. C }}
bak =: {{ C=: 0 >. C-1   if. (C-S) < 0 do. S =: S - 1 end. C }}
val =: {{ C { ::a: L }}
(at0 =: {{ C = 0 }}) `(atz =: {{ C = <: #L }})
(go0 =: {{ S =: C =: 0 }})`(goz =: {{ S =: 0 >. (H-~#L) <. C =: <: #L }})

ins =: {{ R=:1 [ L=: }: (<y) C }b#~1+C=i.#b=.L,{.L }}
del =: {{ R=:1 [ L=: L#~-.C=i.#L }}
set =: {{ R=:1 [ L=: (<y) C } L }}

NB. override hook:
render_item =: {{ x ] puts W{.>y }}

render =: {{
  for_vln. H {. S }. L do.  NB. visible lines
    goxy 0,i=.vln_index
    hi =. (C=S+i)
    if. y do.
      fg hi pick TX_FG;CU_FG
      bg hi pick TX_BG;CU_BG
    else.
      fg hi pick TX_FG;HI_FG
      bg hi pick TX_BG;HI_BG
    end.
    if. vln -: a: do. puts W#' '
    else. (S+i) render_item vln end.
  end. }}
