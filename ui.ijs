NB. (text-based) UI widgets for kvm
require 'tangentstorm/j-kvm/vid'
extends_z_ =: {{ x [ coinsert y [ cocurrent x }}

cocurrent 'UiTheme' extends 'vt'

tx_fg =: 7
tx_bg =: 0
hi_fg =: 0
hi_bg =: 7

coclass 'UiWidget' extends 'UiTheme'

XY =: 0 0


load 'tangentstorm/j-kvm/ui/list'    NB. UiList
load 'tangentstorm/j-kvm/ui/field'   NB. UiField
