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
  MODE =: 'n'      NB. MODE e. 'niq'  : navigate, insert, quote
  LOG =: 0$a:      NB. macro recorder history
}}

ins =: {{
  tmp =. (1+C e.~ i.#b)#b=.B,E
  inspos =. <:C=:>:(+i.@#)C  NB. move all cursors forward
  newlen =. C+&#B
  R=:1 [ B=: newlen {. y inspos } tmp }}"0

NB. !! maybe factor out 'tmp' here, as above in 'ins'?
del =: {{ R=:1[ C=:C-i.#C[B=:}: (1-C e.~ i.#b)#b=.B,E }}
bsp =: del@bak

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

render_cursor =: {{
  fg CF [ bg CB
  ({{ goxy xy [ putc y{B,E [ goxy xy=.y,0 }} :: ])"0 C }}

render =: {{
  cscr'' [ bg BG [ fg FG
  puts B
  render_cursor ''
  bg BG [ fg FG  }}

do =: {{
  NB. this provides a little language for animating the editors.
  NB. execute a series of actions on the token editor
  i=.0 [ q =. '?'  NB. quote char. '?' is rare symbol in j
  refresh =. echo@''@render@1  NB. TODO: remove this
  refresh''
  for_c. y do. i =. c_index
    select. MODE
    fcase. 'q' do.
      if. c = q do. ins q [ MODE =: 'i' continue.
      else. MODE=:'n' end. NB. and fall through
    case. 'n' do.
      select. c
      case. '?' do. MODE =: 'i'
      case. 'b' do. bwd''
      case. 'h' do. bak''
      case. '$' do. eol''
      case. 'X' do. bsp''
      NB. case. '!' do. eval''
      end.
    case. 'i' do.
      if. c = q do. MODE =: 'q'
      else. ins c end.
    end.
    sleep 15+?20
    refresh''
  end.
  if. MODE = 'q' do. MODE =: 'n' end.
  refresh''
  0 0 $ 0}}

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
kc_f =: log@'l' @ for
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
