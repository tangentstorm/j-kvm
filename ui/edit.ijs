NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  B =: y           NB. the buffer to edit.
  E=: {.@(0&$) B   NB. empty element (temp used when appending a value at the end)
  C =: 0           NB. cursor position(s)
  M =: 0           NB. mark(s) (one per cursor)
  W =: 64          NB. width/max length
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

kc_m =: {{ break_kvm_=: 1}}
k_asc =:ins
kc_d =: del
kc_h =: k_bsp =: bsp
kc_a =: bol
kc_e =: eol
kc_b =: bak
kc_f =: for
kc_t =: swp
ka_f =: fwd
ka_b =: bwd

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
