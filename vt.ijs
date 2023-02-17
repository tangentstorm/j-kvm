NB. ----------------------------------------------
NB. j virtual terminal support.
NB. supports windows and linux (and osx??)
NB. ----------------------------------------------
cocurrent 'vt'

help =: 0 : 0

  'vt' locale: j virtual terminal support
  ----------------------------------------
  raw b     -> enter(b=1)/leave(b=0) raw mode
  keyp t    -> bit. is key pressed? t timeout ms ('' means 0)
  rkey''    -> read key from keyboard
  wfc c     -> wait for character c to be pressed

  cscr''    -> clear screen
  ceol''    -> clear to end of line

  gethw''   -> get video height/width
  xmax''    -> get max x coordinate
  ymax''    -> get max y coordinate

  curs b    -> hide(b=0) or show(b=1) cursor
  curxy''   -> get cursor xy
  goxy x,y  -> set cursor xy

  puts s    -> emit string

  fgc n     -> set foreground color
  bgc n     -> set background color
  fgx n     -> set 24-bit foreground color
  bgx n     -> set 24-bit background color
  reset''   -> reset to default colors

  sleep n   -> sleep for n milliseconds

  mouse b   -> enable/disable mouse events
)



NB. ANSI/VT-100/xterm escape codes
NB. -------------------------------------------------------
NB. these all-caps names indicate string constants
NB. or verbs that return strings. This is so you can
NB. build up your own sequences in bulk.

ESC  =: u:27               NB. ANSI escape character
CSI  =: ESC,'['            NB. vt100 'command sequence introduce'
CSCR =: ,CSI,"1 0'HJ'      NB. clear screen
CEOL =: CSI,'0K'           NB. clear to end of line
RESET =: CSI,'0m'          NB. reset color to gray on black
CURSU =: CSI,'A'           NB. cursor up
CURSD =: CSI,'B'           NB. cursor down
CURSL =: CSI,'D'           NB. cursor left
CURSR =: CSI,'C'           NB. cursor right

NB. xterm 256-color codes
NB. Most modern terminals seem to support 256 colors.
NB. FG256 y ->str.
FG256=: CSI,'38;5;', 'm',~ ":   NB. fg (numeric)
BG256=: CSI,'48;5;', 'm',~ ":   NB. bg (numeric)

NB. xterm 24-bit color codes
NB. FG24B y ->str.
FG24B=: CSI,'38;2;', 'm',~ [: rplc&(' ';';')@": (3#256)&#:
BG24B=: CSI,'48;2;', 'm',~ [: rplc&(' ';';')@": (3#256)&#:

NB. GOXY[X,Y]->str: code to set cursor position
GOXY =: CSI, ":@{:, ';', 'f',~ ":@{.

NB. CURS [0/1]->str: code to show/hide cursor
CURS =: CSI,'?25','lh'{~]


NB. ----------------------------------------------------
NB. windows terminal:
NB. ----------------------------------------------------

NB. https://docs.microsoft.com/en-us/windows/console/console-functions
SetConsoleMode =: 'kernel32 SetConsoleMode b x s'&cd
GetConsoleScreenBufferInfo =: 'kernel32 GetConsoleScreenBufferInfo c x *s'&cd
GetStdHandle =: 'kernel32 GetStdHandle *c s'&cd
ReadConsoleInput =: 'kernel32 ReadConsoleInputA b x *s i *i'&cd
PeekConsoleInput =: 'kernel32 PeekConsoleInputA b x *s i *i'&cd
SetConsoleOutputCP =: 'kernel32 SetConsoleOutputCP b i'&cd
InputArgs =: {{ w_stdi;(10#0);1;<,0 }}
WriteConsole =: 'kernel32 WriteConsoleA b x *c *i x'&cd


w_puts =: {{ 0 0$WriteConsole w_stdo;(,y);(<#y);0 }}
w_gethw =: {{
  'l t r b'=. 4{.5}.>{: GetConsoleScreenBufferInfo w_stdo;22#0
  (b-t),(r-l) }}

w_keyp =: {{
  sleep y
  r=. PeekConsoleInput InputArgs [ w_skip''
  0{>{: r }}
w_skip =: {{ NB. skip events besides keydown
  NB. names for windows event codes
  'FOCUS KEY MENU MOUSE SIZE' =.  16b10 16b01 16b08 16b02 16b04
  while. *{.nr ['r h b n0 nr'=.PeekConsoleInput InputArgs'' do.
    NB. keep key down event
    if. KEY -: 0{b do. if. 2{b do. break. end. end.
    NB. otherwise read and discard the event:
    ReadConsoleInput InputArgs''
  end.
0 0$0}}

w_rkey =: {{
  while. 1 do.
    w_skip''
    'r h b n0 nr' =. ReadConsoleInput InputArgs''
    if. *{.nr do.
      dn=. 2{b
      'rc kc sc ch' =. 4{.4}.b
      ch =. u:ch
      mod =. '.x'{~_32{.!.0#: 65536 65536 #. _2{.b
      NB. smoutput 'dn:';dn;'rc:';rc;'kc:';kc;'ch:';ch;'mod:';mod
      NB. skip over modifier keys
      if. dn > kc e. 16 17 18 do. a.i.{.ch return. end.
    end.
  end. }}

NB. ----------------------------------------------------
NB. vt-100 terminal queries (must be done in raw mode)
NB. ----------------------------------------------------

curxy =: {{ raw 1
  r =. 2}. wfc 'R' [ puts CSI,'6n'
  |.0".>';' splitstring r }}

mouse =: {{
  'cdm' mouse y  NB. click, drag, move events
:
  f =. y { 'lh'  NB. 0->l=off, 1->h=on
  qs =. ''
  if. 'c' e. x do. qs=.qs,CSI,'?1000',f end.
  if. 'd' e. x do. qs=.qs,CSI,'?1002',f end.
  if. 'm' e. x do. qs=.qs,CSI,'?1003',f end.
  puts CSI,'?1006h',qs }}

init =: {{
  NB. define (raw, rkey, gethw, puts) + platform-specific helpers
  if. IFWIN do.
    w_stdi =: >{. GetStdHandle _10
    w_stdo =: >{. GetStdHandle _11
    SetConsoleMode w_stdo;7   NB. enable escape codes
    SetConsoleOutputCP 65001  NB. CP_UTF8
    raw  =: ]
    rkey =: w_rkey
    gethw =: w_gethw
    keyp =: w_keyp
    puts =: w_puts
  elseif. IFUNIX do.
    u_raw1 =: '' [ [: 2!:0 'stty raw -echo' []
    u_raw0 =: ][ [: 2!:0 'stty -raw echo' []
    u_libc =: unxlib 'c'
    raw  =: {{ if. y do. u_raw1'' else. u_raw0'' end. }}
    gethw =: {{ _".}: 2!:0 'stty size' }}
    NB. ravel - as & cannot take a scalar
    puts =: 0 0 $ [:(u_libc,' write n i &c l')&cd 0 ; , ; #
    rkey =: a.i.0{2{:: [:(u_libc,' read l i *c l')&cd 1 ; ((,0){a.) ; 1:
    NB. obtain a pointer to stdin, so we can ungetc()
    u_fcntl =: (u_libc,' fcntl i i i i')&cd
    u_poll =: (u_libc,' poll i *l i i')&cd
    if. UNAME-:'Linux' do.
      F_SETFL=: 4
      O_NONBLOCK=: 2048
      POLLIN =: 1
    elseif. UNAME-:'FreeBSD' do.
      F_SETFL=: 4
      O_NONBLOCK=: 4
      POLLIN =: 1
    elseif. UNAME-:'Darwin' do.
      F_SETFL=: 4
      O_NONBLOCK=: 4
      POLLIN =: 1
    else.
      assert. 0
    end.
    u_noblock =: {{ u_fcntl 0,F_SETFL,O_NONBLOCK }}
    u_block =: {{ u_fcntl 0,F_SETFL,0 }}
    NB. x: list of events; m: timeout; y: corresponding list of fds
    NB. return: list of events
    poll =: {{
      NB. struct pollfd { int fd; short events; short revents; }
      p =. ,^:(0-:#@$) y + 32 (33 b.) x
      NB. shift off everything but revents.  Requires little endian; ok
      _48 (33 b.) 1{:: u_poll p;(#@,p);m
    }}

    keyp =: {{
      u_noblock''
      r=. 1 (y poll) 0
      u_block''
      r
    }}
  else.
    'vt.ijs only supports windows and unix platforms.'
  end. >a: }}

wfc =: {{ r=.'' while. -.y-:c=.a.{~0{rkey'' do. r=.r,c end. r }}

cscr =: puts@CSCR
ceol =: puts@CEOL

xmax =: <:@{:@gethw
ymax =: <:@{.@gethw

goxy =: puts@GOXY
curs =: puts@CURS

fgc =: puts@FG256
bgc =: puts@BG256
fgx =: puts@FG24B
bgx =: puts@BG24B
reset=: puts@RESET

NB. these two are just handy to type when your screen gets messy:
cls =: CSCR_vt_
bw  =: RESET_vt_

sleep =: [: (6!:3) 0.001 * ]

init''

NB. just a demo to show colors and waiting for a keypress.
demo =: {{
  reset''
  cscr''
  puts '256 terminal colors:',CR,LF
  (puts@(CR,LF) ([: puts ' ',~hfd [ fgc)"0)"1  i.16 16
  reset''
  puts^:2 CR,LF
  puts 'press a key!'
  xy=.curxy'' [ s =. ' _.,oO( )Oo,._ ' [ raw 1
  whilst. -. keyp 150 do.
    goxy xy [ bgc 4 [ fgc 9
    puts '['
    fgc 15
    puts 4{. s=.1|.s
    fgc 9
    puts']'
  end.
  echo a.{~rkey'' [ reset''
  puts^:2 CR,LF
  raw 0
  }}
