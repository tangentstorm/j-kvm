
class 'UiTree' extends 'UiList'

create =: {{
  create_UiList_ f. y
  NB. EXpanded? HasKids? Depth
  EX =: HK =: D =: 0"0 y }}

fetch_items =: {{ 2 $ a: }} NB. override this!

upw =: {{ if. C{D do. R=:1 [ C=:_2{crumbs'' end. }}
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

NB. helpers for expand/contract
splice =: {{ {.,m,}. }}
remove =: {{ (x{.y) , (m+x) }. y }}

expand =: {{
  c =. 1 + C [ d=.(1+C{D)"0 ex =. 0#~#l[ 'l hk' =. fetch_items C
  L  =: c l splice L
  D  =: c d splice D
  HK =: c hk splice HK
  EX =: c ex splice EX
  R =: 1}}

contract =: {{
   NB. dn = distance to next item at same level or higher than C
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

