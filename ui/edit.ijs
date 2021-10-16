NB. simple abstract editor

coclass 'UiEditWidget' extends 'UiWidget'

create =: {{
  setval y
  A =: 0           NB. only animate when macro is playing
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
del =: {{ if. (>./C)>:#B do. return.
          else. R=:1[ C=:C-i.#C[B=:}: (1-C e.~ i.#b)#b=.B,E end. }}
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

NB. this is a dyad so that multi-line editor can draw the cursor
NB. on a line other than line 0. (y_coord render_cursor is_focused)
NB. (so sadly, argument x is the y coordinate.)
render_cursor =: 0&$: : {{
  if. y do. fg CU_FG [ bg CU_BG else. fg HI_FG [ bg HI_BG  end.
  NB. draw each cursor at cooridates (C,x) (where again arg x=y coord)
  C {{ goxy xy [ putc x{B,E [ goxy xy=.x,y }}"0 x
  0 0$0}}

render =: {{
  bg BG [ fg FG
  puts B
  render_cursor y
  bg BG [ fg FG  }}

do =: play NB. old name. !!! deprecate this.
play =: {{ NB. queue macro y for playback
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
      if. c='?' do. MODE =: 'i'
      else. (CMD_VERBS`] {~ CMD_CHARS&i.c)`:0 '' end.
    case. 'i' do.
      if. c = q do. MODE =: 'q'
      else. ins c end.
    end.
    R =: 1 [ I =: I + 1
  else. on_macro_end'' [ A =: 0 end.
  if. MODE = 'q' do. MODE =: 'n' end. }}

NB. -- interactive app --
coinsert 'kvm'

NB. event handlers for up/down/enter keys
on_up =: ]
on_dn =: ]
on_accept =: ]
on_macro_end =: ]

now =: 6!:1
log =: {{ TS =: TS,now'' [ LOG =: LOG,<y }}

k_asc =: {{log '?',y,'?' }} [ ins

NB. -- tables for macro language and keybindings
rdtbl =: {{cut&> LF cut y-.CR}}

NB. key<->macro table
KEYS =: rdtbl noun define
k_ardn v
k_arup ^
k_bsp X
ka_b b
ka_f w
kc_a 0
kc_b <
kc_d x
kc_e $
kc_f >
kc_h X
kc_k K
kc_m !
kc_n v
kc_p ^
kc_t T
)

NB. macro<->method table
CMDS =: rdtbl noun define
! on_accept
$ eol
0 bol
K keol
T swp
X bsp
b bwd
< bak
v on_dn
^ on_up
> for
w fwd
x del
)

NB. extract columns of those above tables
KEY_PRESS=: 0{"1 KEYS     NB. ex: <'kc_e'
KEY_CMDS=:  1{"1 KEYS     NB. ex: <'$'
CMD_CHARS =: ,>0{"1 CMDS  NB. ex: '$'
CMD_VERBS =:   1{"1 CMDS  NB. ex: <'eol'

NB. 3 column table of keypress, key_cmd/cmd_char, cmd_verb
KEYMAP =: KEY_PRESS ,. KEY_CMDS ,. CMD_VERBS {~ CMD_CHARS i. >KEY_CMDS

NB. define keyboard handlers using the above tables.
NB. for each (k_verb, cmdchar, cmdverb) triple, define:
NB.     k_verb =: log@cmdchar @ cmdverb
NB. ex: kc_e =: log@'$' @ eol
".(' =: log@'''; ''' @ ';'') ;@,.~"1  KEYMAP

NB. catch-all keyboard handling for inserting normal keys into text
k_asc =: {{log '?',y,'?' }} [ ins


mi =: {{ y {~ I. -.@(+. _1&|.) '??' E.y }} NB. merge inserts
gettimes =: {{
  q=.5 NB. quantization factor
  <.q^.100*2-~/\TS }}

getlog =: {{ if. 0=#LOG do. '' else. mi ;<@;"1 LOG ,.~ (#&'_') each 0,gettimes'' end. }}

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
