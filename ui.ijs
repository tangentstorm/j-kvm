NB. (text-based) ui widgets for kvm
require 'tangentstorm/j-kvm/vid'
cocurrent 'uiTheme'

XY =: 0 0
tx_fg =: 7
tx_bg =: 0
hi_fg =: 0
hi_bg =: 7

coclass 'uiList'
coinsert 'uiTheme';'vt'

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
atz =: {{ C = <: #L }}

render =: verb define
  XY render y
:
  for_vln. H {. S }. L do.  NB. visible lines
    goxy x + 0,vln_index
    if. vln -: a: do. puts W#' ' [ bgc tx_bg
    else.
      fgc (C=S+vln_index) pick tx_fg;hi_fg
      bgc (C=S+vln_index) pick tx_bg;hi_bg
      puts W{.>vln
    end.
  end.
)
