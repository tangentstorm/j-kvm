NB. (text-based) UI widgets for kvm
require 'tangentstorm/j-kvm/vid'

NB. mini object-oriented vocabulary
class_z_   =: (coclass f.) [ {{ ". y,'_z_ =: conew&',quote y }}
extends_z_ =: {{ x [ coinsert y [ cocurrent x }}
of_self_z_ =: {{ (m,'_','_',~>coname'')~ }}
of_z_ =: {{ (x,'__y')~ [ y }}"1 0

cocurrent 'UiTheme' extends 'kvm'

NB. TX = plain text color
TX_FG =: _7
TX_BG =: 0

NB. HI = hilight color (unfocused cursor)
HI_FG =: 0
HI_BG =: _7

NB. CU = focused cursor
CU_FG =: 0
CU_BG =: _214


class 'UiWidget' extends 'UiTheme'

create =: ]
render =: ]
update =: ]

tobuf =: {{
  buf =. (W,H) conew 'vid'
  pushterm buf
  render y
  popterm''
  buf }}

termdraw =: {{ NB. y is hasfocus (same arg as render)
  buf =. tobuf y
  XY blit buf
  0 0 $ codestroy__buf'' }}

XY =: 0 0          NB. location on screen
H  =: 1            NB. height
W  =: 1            NB. width
R  =: 1            NB. need to redraw?
V  =: 1            NB. visible?
A  =: 1            NB. animated/active?

load 'tangentstorm/j-kvm/ui/list'    NB. UiList
load 'tangentstorm/j-kvm/ui/tree'    NB. UiTree
load 'tangentstorm/j-kvm/ui/edit'    NB. UiEditWidget
load 'tangentstorm/j-kvm/ui/app'     NB. UiApp
