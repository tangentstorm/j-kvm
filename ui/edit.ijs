NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  B =: y           NB. the buffer to edit.
  E=: {.@(0&$) B   NB. empty element (temp used when appending a value at the end)
  C =: 0           NB. cursor position(s)
  M =: 0           NB. mark(s) (one per cursor)
  W =: 64          NB. width/max length
  LOG =: 0$a:     NB. macro recorder history
  BG=: _234        NB. bg color
  FG=: _7          NB. fg color
  CF=: 0           NB. cursor fg
  CB=: _214        NB. cursor bg
}}

NB. buffer editing commands:
ins =: {{ R=:1[ B=:(C+&#B) {. y (<:C=:>:(+i.@#)C) } (1+C e.~ i.#b)#b=.B,E }}"0
del =: {{ R=:1[ C=:C-i.#C[B=:}:b#~-.C e.~i.#b=.B,E}}
eol =: {{ R=:1[ C=:C+(#B)->./C }}
bol =: {{ R=:1[ C=:C-<./C }}
swp =: {{ R=:1[ B=: a (C-1) } b (C-2) } B [ a=. (C-2) { B [ b=. (C-1) { B }}
for =: {{ if. (#B)>>./C do. R=:1 [ C=:>:C end. }}
bak =: {{ if. 0<<./C do. R=:1 [ C=:<:C end. }}

atz =: {{y] -. (#B)>>./C }}
at0 =: {{y] -. 0<<./C }}
atsp =: ({{y] ' ' e. C{B }}) :: 0
fwd =: {{ whilst. (atz +: atsp)'' do. for'' end. }}
bwd =: {{ whilst. (at0 +: atsp)'' do. bak'' end. }}
bsp =: {{ if. 0<<./C do. R=:1[ C=:C-1+i.#C[B=:}:b#~-.1|.C e.~i.#b=.B,E end. }}

render_cursor =: {{
  fgx CF [ bgx CB
  ({{ goxy xy [ putc y{B,' '[ goxy xy=.y,0 }} :: ])"0 C }}

render =: {{
  cscr'' [ bgx BG [ fgx FG
  puts B
  render_cursor^:y'' }}

NB. -- interactive app --
coinsert 'kvm'

LOG =: ''
log =: {{ LOG =: LOG,<y }}
kc_m =: {{ break_kvm_=: 1}}

k_asc =: {{log '?',y,'?' }} [ ins
kc_d =: log@'x' @ del
kc_h =: k_bsp =: log@'X' @ bsp
kc_a =: log@'0' @ bol
kc_e =: log@'$' @ eol
kc_b =: log@'h' @ bak
kc_f =: log@'l' @ fro
kc_t =: log@'T' @ swp  NB. TODO what does T do in vim? better code?
ka_f =: log@'w' @ fwd
ka_b =: log@'b' @ bwd

mi =: {{ y {~ I. -.@(+. _1&|.) '??' E.y }} NB. merge inserts
getlog =: {{ mi ; LOG }}

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
