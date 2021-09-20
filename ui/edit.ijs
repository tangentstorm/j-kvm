NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  setval y
  W =: 64          NB. width/max length
  BG=: _234        NB. bg color
  FG=: _7          NB. fg color
  MACRO =: ''      NB. the macro we are playing
  I =: _1          NB. the index into macro / instruction pointer
  T =: 0           NB. timer. seconds since last key (sum of time delta from update verb)
  KPS =: 12.2      NB. typing speed (keystrokes per second)
  TSV =: %(10*KPS) NB. max delay for random modifier for typing speed (in seconds/key)
  NEXT =: 0        NB. time for next keypress/macro event (last keypress+computed delay)
}}

setval =: {{
  B =: y           NB. the buffer to edit.
  E=: {.@(0&$) B   NB. empty element (temp used when appending a value)
  C =: #B          NB. cursor position(s)
  M =: 0           NB. mark(s) (one per cursor)
  MODE =: 'n'      NB. MODE e. 'niq'  : 'n'avigate, 'i'nsert, 'q'uote
  LOG =: 0$a:      NB. macro recorder history
  TS =: 0$0        NB. timestamps for the log
  R =: 1           NB. set redraw flag
}}

getstate =: {{ C;B;M;MODE }}
setstate =: {{)v
  'c b m mode' =. y
  setval b
  0 0 $ C =: c [ M =: m [ MODE =: mode }}

ins =: {{
  tmp =. (1+C e.~ i.#b)#b=.B,E
  inspos =. <:C=:>:(+i.@#)C  NB. move all cursors forward
  newlen =. C+&#B
  R=:1 [ B=: newlen {. y inspos } tmp }}"0

NB. !! maybe factor out 'tmp' here, as above in 'ins'?
del =: {{ R=:1[ C=:C-i.#C[B=:}: (1-C e.~ i.#b)#b=.B,E }}
bsp =: del@bak

keol =: {{ R=:1[ B =: (C=:{.C) {. B }} NB. collapse cursors,kill to eol
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
  if. y do. fg CU_FG [ bg CU_BG else. fg HI_FG [ bg HI_BG  end.
  ({{ goxy xy [ putc y{B,E [ goxy xy=.y,0 }} :: ])"0 C }}

render =: {{
  bg BG [ fg FG
  puts B
  render_cursor y
  bg BG [ fg FG  }}


do =: {{ NB. queue macro y for playback
  MACRO =: y NB. the macro to play
  NEXT =: 0 NB. start immediately
  T =: 0 NB. start the timer
  A =: 1 NB. start animation mode
  I =: 0 NB. the index into macro / instruction pointer
}}


update =: {{
  if. (T =: T + y) < NEXT do. return. end. NB. y = seconds since last update
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
      case. 'K' do. keol''  NB. TODO: 'd$' is the correct macro
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
kc_k =: log@'K' @ keol
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
