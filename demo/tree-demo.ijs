load 'tangentstorm/j-kvm/ui'
coinsert'kvm vt'

class 'UiTree' extends 'UiList'

create =: {{
  create_UiList_ f. y
  NB. EXpanded? HasKids? Depth
  EX =: HK =: D =: 0"0 y }}

upw =: {{ if. C{D do. R=:1 [ C=:_2{crumbs'' end. }}

fetch_items =: {{ 2 $ a: }}

crumbs =: {{ if. y-:'' do. y=.C end. ((y+1){.D) i: i.1+y{D }}
path =: {{ L {~ crumbs C }}

render_item =: {{
  indent =. ' '#~x{D
  icon =. '  +-'{~(2*x{HK)+x{EX
  if. x~:C do.
    if. x{HK do. fg _15 end.
    if. '~'={:>y do. fg _8 end.
  end.
  puts W {. indent,icon,' ',>y }}

splice =: {{ {.,m,}. }}

expand =: {{
  c =. 1 + C [ d=.(1+C{D)"0 ex =. 0#~#l[ 'l hk' =. fetch_items C
  L  =: c l splice L
  D  =: c d splice D
  HK =: c hk splice HK
  EX =: c ex splice EX
  R =: 1}}

remove =: {{ (x{.y) , (m+x) }. y }}

contract =: {{
   NB. dis = distance to next item at same level or higher than C
   c =. C+1 [ dn =. {.I.}.C}.D<:C{D
   NB. if there is no such item, remove everything after C
   if. 0=dn do. dn =. C-~#D end.
   L =: c dn remove L
   D =: c dn remove D
   HK =: c dn remove HK
   EX =: c dn remove EX
   R =: 1}}


toggle =: {{
  if. -. C{HK do. EMPTY return. end.
  R =: 1 [ EX=:(ex=.-.C{EX) C} EX
  if. ex do. expand'' else. contract'' end. }}


cocurrent 'base'

tree =: UiTree conl''

k_n =: fwd__tree
k_p =: bak__tree
k_u =: upw__tree
k_q =: {{break_kvm_=:1}}
kc_i =: toggle__tree  NB. tab key

team=:{{x`:6 L: _1 y}}"0 _1
myls =: {{
  NB. returns 2 boxed vectors:
  NB. boxed names, is-dir bits
  try.
    t =. <"1] 0 4{|:1!:0 '*',~'/',~^:(*#y) y
    ]`(('d'=4&{) S:0) team t
  catch. 2 $ a:
  end.}}

dbg 1
main =: {{
  tree =: UiTree L ['L HK'=.myls''
  H__tree =: <:{.gethw''
  TX_BG__tree =: _234
  fetch_items__tree =: {{ myls_base_ '/' joinstring path'' }}
  HK__tree =: HK
  curs 0
  app =: UiApp ,tree
  step__app loop_kvm_ 'base'
  curs 1 [ raw 0  [ reset''
NB.  codestroy__rnd''
NB.  codestroy__fps''
NB.  codestroy__app''
NB.  exit 0
}}

(9!:29) 1 [ 9!:27 'main _ '
