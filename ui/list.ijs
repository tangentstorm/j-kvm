
coclass 'UiList' extends 'UiTheme'

doc =: 'A vertically-scrolling buffer with one line highlighted.'

create =: verb define
  W =: 32
  H =: 8
  S =: 0      NB. scroll position
  C =: 0      NB. cursor
  L =: y      NB. boxed list of labels
)

fwd =: {{ C=:(<:#L)<.C+1 if. (C-S) >: H do. S =: S + 1 end. C }}
bak =: {{ C=: 0 >. C-1   if. (C-S) < 0 do. S =: S - 1 end. C }}
val =: {{ C { ::a: L }}
(at0 =: {{ C = 0 }}) `(atz =: {{ C = <: #L }})
(go0 =: {{ C =: 0 }})`(goz =: {{ C =: <: #L }})

render =: verb define
  XY render y
:
  for_vln. H {. S }. L do.  NB. visible lines
    goxy x + 0,vln_index
    hi =. (C=S+vln_index)
    fgc hi pick tx_fg;hi_fg
    bgc hi pick tx_bg;hi_bg
    if. vln -: a: do. puts W#' '
    else. puts W{.>vln end.
  end.
)
