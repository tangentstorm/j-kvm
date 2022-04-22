NB. UiTree is like a list, but allows expanding the nodes
NB. dynamically. The caller (or subclass) is responsible
NB. for updating the initial D,HC,EX fields, and providing
NB. an implementation of fetch_items.
NB.
NB. Internally, it uses flat lists and simply removes
NB. lines when you collapse their parent.
NB.
NB. Override 'fetch_items' to provide the logic to load the
NB. items back into the tree.
class 'UiTree' extends 'UiList'

create =: {{
  create_UiList_ f. y
  D =: 0"0 y   NB. Depth (Int vector)
  HC=: 0"0 y   NB. Has Children? (Bit vector)
  EX=: 0"0 y   NB. Expanded? (Bit vector)
}}

NB. fetch_items: must return a 2-box vector:
NB.   box 0: a list of boxed labels
NB.   box 1: corresponding 'has-children?' bits
fetch_items =: {{ 2 $ a: }} NB. <-- users should override this!


NB. tree navigation
upw =: {{ if. C{D do. R=:1 [ C=:_2{crumbs'' end. }}

crumbs =: {{ if. y-:'' do. y=.C end. ((y+1){.D) i: i.1+y{D }}
path =: {{ L {~ crumbs C }}


NB. expand/contract
render_item =: {{
  indent =. ' '#~x{D
  icon =. '  +-'{~(2*x{HC)+x{EX
  puts W {. indent,icon,' ',>y }}

NB. helpers for expand/contract
splice =: {{ {.,m,}. }}
remove =: {{ (x{.y) , (m+x) }. y }}

expand =: {{
  c =. 1 + C [ d=.(1+C{D)"0 ex =. 0#~#l[ 'l hc' =. fetch_items C
  L  =: c l splice L
  D  =: c d splice D
  HC =: c hc splice HC
  EX =: c ex splice EX
  R =: 1}}

contract =: {{
   NB. dn = distance to next item at same level or higher than C
   c =. C+1 [ dn =. {.I.}.C}.D<:C{D
   NB. if there is no such item, remove everything after C
   if. 0=dn do. dn =. C-~#D end.
   L =: c dn remove L
   D =: c dn remove D
   HC =: c dn remove HC
   EX =: c dn remove EX
   R =: 1}}

toggle =: {{
  if. -. C{HC do. EMPTY return. end.
  R =: 1 [ EX=:(ex=.-.C{EX) C} EX
  if. ex do. expand'' else. contract'' end. }}

