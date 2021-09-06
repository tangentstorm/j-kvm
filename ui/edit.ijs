NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  setval y
  W =: 64          NB. width/max length
  BG=: _234        NB. bg color
  FG=: _7          NB. fg color
  CF=: 0           NB. cursor fg
  CB=: _214        NB. cursor bg
  MACRO =: ''      NB. the macro we are playing
  I =: _1          NB. the index into macro / instruction pointer
  T =: 0           NB. time counter
  KPS =: 12.2      NB. typing speed (keystrokes per second)
  TSV =: %(10*KPS) NB. random modifier for typing speed (in seconds per keystroke)
  NEXT =: 0        NB. time for next keypress/macro event
}}

setval =: {{
  B =: y           NB. the buffer to edit.
  E=: {.@(0&$) B   NB. empty element (temp used when appending a value at the end)
  C =: 0           NB. cursor position(s)
  M =: 0           NB. mark(s) (one per cursor)
  MODE =: 'n'      NB. MODE e. 'niq'  : 'n'avigate, 'i'nsert, 'q'uote
  LOG =: 0$a:      NB. macro recorder history
  TS  =: 0$0       NB. timestamps for the log
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


do =: {{ NB. queue macro y for playback
  MACRO =: y NB. the macro to play
  NEXT =: 0 NB. start immediately
  T =: 0 NB. start the timer
  A =: 1 NB. start animation mode
  I =: 0 NB. the index into macro / instruction pointer
}}

( 0 : 0 )
  y = seconds since last tick
  T = seconds since last keypress (sum of y over animation frames)
  NEXT = seconds between last keypress and next keypress
  KPS = keystrokes per second
  %KPS = seconds per keystroke
  TSV = some random term added to %KPS (in seconds per keystroke)
)

update =: {{
  if. (T =: T + y) < NEXT do. return. end.
  T =: 0 [ NEXT =: (TSV*?0) + %KPS NB. schedule next keypress
  NB. this provides a little language for animating the editors.
  NB. execute a series of actions on the token editor
  q =. '?'  NB. quote char. '?' is rare symbol in j
  if. I < # MACRO do.
    c =. I{MACRO
    select. MODE
    fcase. 'q' do.
      if. c = q do. ins q [ MODE =: 'i' return.
      else. MODE=:'n' end. NB. and fall through
    case. 'n' do.
      select. c
      case. '?' do. MODE =: 'i'
      case. 'b' do. bwd''
      case. 'h' do. bak''
      case. '0' do. bol''
      case. '$' do. eol''
      case. 'X' do. bsp''
      case. 'x' do. del''
      case. 'w' do. fwd''
      case. 'l' do. for''
      case. 'T' do. swp''
        NB. case. '!' do. eval''
      end.
    case. 'i' do.
      if. c = q do. MODE =: 'q'
      else. ins c end.
    end.
    R =: 1 [ I =: I + 1
  else. A =: 0 end.
  if. MODE = 'q' do. MODE =: 'n' end. }}

NB. -- interactive app --
coinsert 'kvm'

now =: 6!:1
log =: {{ TS =: TS,now'' [ LOG =: LOG,<y }}

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
gettimes =: {{
  q=.5 NB. quantization factor
  <.q^.100*2-~/\TS }}
getlog =: {{ mi ;<@;"1 LOG ,.~ (#&'_') each 0,gettimes'' }}

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
