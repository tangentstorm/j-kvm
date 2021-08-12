NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  B =: y           NB. the buffer to edit.
  E=: {.@(0&$) B   NB. empty element (temp used when appending a value at the end)
  C =: 0           NB. cursor position(s)
  M =: 0           NB. mark(s) (one per cursor)
  W =: 64          NB. width/max length
  R =: 1           NB. 'needs redraw' flag
  XY=: 0 0         NB. screen coordinates
  BG=: 8           NB. bg color
  FG=: 7           NB. fg color
  CF=: 0           NB. cursor fg
  CB=: 9           NB. cursor bg
  EX=: 1           NB. whether or not to draw extent
}}

NB. buffer editing commands:
ins =: {{ R=:1[ B=:(C+&#B) {. y (<:C=:>:(+i.@#)C) } (1+C e.~ i.#b)#b=.B,E }}"0
bsp =: {{ R=:1[ C=:C-1+i.#C[B=:}:b#~-.1|.C e.~i.#b=.B,E }}
del =: {{ R=:1[ C=:C-i.#C[B=:}:b#~-.C e.~i.#b=.B,E}}
eol =: {{ R=:1[ C=:C+(#B)->./C }}
bol =: {{ R=:1[ C=:C-<./C }}
swp =: {{ R=:1[ B=: a (C-1) } b (C-2) } B [ a=. (C-2) { B [ b=. (C-1) { B }}
fwd =: {{ R=:1 [ C=:>:C }}
bak =: {{ if. 0<<./C do. R=:1 [ C=:<:C end. }}

render =: {{
  bgc BG [ fgc FG [ goxy XY
  NB. draw buffer and extra space:
  puts B,(EX*0>.W-#B)#' '
  NB. draw the cursor:
  fgc CF [ bgc CB
  ({{ goxy xy [ putc y{B,' '[ goxy xy=.XY+y,0 }} :: ])"0 C
}}

NB. -- interactive app --
coinsert 'kvm'

kc_m =: {{ break_kvm_=: 1}}
k_asc =: {{ ins y }}
kc_d =: del
kc_h =: k_bksp =: bsp
kc_e =: eol
kc_b =: bak
kc_f =: gor
kc_t =: swp

kvm_init =: {{ R =: 1 [ curs 0 }}
kvm_done =: {{ curs 1 [ reset'' [ echo'' [ raw 0}}
lined =: {{ if. R do. draw'' [ R=: 0 end. }} loop@'UiField'
ed_z_=:lined_ed_

NB. tests framework
create''
assert '!.!michal!.!' -: 'B'~ [ ins'!.!' [ B=:'michal' [ C=:0 6
sho =. {{ b,:'-^' {~ C e.~i.#b=.B,E }}
sho B0=.B [ C0=.C
create ''