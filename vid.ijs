NB. video buffers
NB.
NB. these are virtual console windows with separate
NB. foreground color, background corol, and character
NB. buffers.
NB.
NB. writing to the buffers is presumably much faster
NB. than actually sending output, and they can be
NB. composed to allow drawing multiple text-mode
NB. windows onto a main buffer, which can then be
NB. rendered to the screen using vt escape codes.
NB.
require 'tangentstorm/j-kvm/vt'
cocurrent'kvm'

term =: <'vt'        NB. by default, just use vt directly
stack =: ''
pushterm =: {{ term_kvm_ =: y [ stack_kvm_ =: term_kvm_,stack_kvm_ }}
popterm =: {{ stack_kvm_ =: }.stack_kvm_ [ term_kvm_ =: {.stack_kvm_ }}

cscr =: {{ cscr__term y }}
ceol =: {{ ceol__term y }}
putc =: {{ putc__term y }}
goxy =: {{ goxy__term y }}
go00 =: {{ goxy__term 0 0 }}
puts =: {{ puts__term y }}
fgc  =: {{ fgc__term y }}
bgc  =: {{ bgc__term y }}
fgx  =: {{ fgx__term y }}
bgx  =: {{ bgx__term y }}
reset=: {{ reset__term y }}

prev =. ([ coclass@'vid') coname''
create =: init@|.

fgc   =: {{ FG =: y }}
bgc   =: {{ BG =: y }}
goxy  =: {{ XY =: y }}
go00  =: goxy@0 0
reset =: fgc@7@bgc@0

fill  =: {{ 0 0$ CHB=:HW$y }}
cscr  =: {{ fill ' ' [ FGB=:HW$FG [ BGB=:HW$BG }}
sethw =: {{ cscr go00 reset WH =: |. HW =: y }}
init  =: {{ sethw gethw_vt_^:(-.*#y) y }}

peek =: {{ (<|.y) { m~ }}
poke =: {{ 0 0 $ (m)=: x (<|.y) } m~ }}
pepo =: {{ ([: m peek ]) : (m poke) :: ] }}

NB. peek/poke various buffers
fgxy =: 'FGB' pepo
bgxy =: 'BGB' pepo
chxy =: 'CHB' pepo

NB. write to ram
NB. putc =: {{ (y chxy])`(FG fgxy ])`(BG bgxy ])`:0 XY }}
putc =: {{
  y chxy XY [ FG fgxy XY [ BG bgxy XY
  if. 0={. XY =: WH|XY + 1 0 do.  XY =: 0,1+{:XY end. }}
puts =: putc"0

rnd =: {{
  CHB =: u:a.{~97+?HW$26
  FGB =: ?HW$256
  BGB =: HW$0 95 0 4 18
  coname'' }}

copyto =: {{ NB. copyto__self y
  CHB =: CHB__y
  FGB =: FGB__y
  BGB =: BGB__y
  HW  =: HW__y
  XY  =: XY__y
  0 0 $ 0 }}

blit =: {{ NB. xy blit__self src. stamp y onto self at xy.
  rc =. <(;/|.x) + L:0 <@i."0 HW__y  NB. row and col indices
  CHB =: CHB__y rc } CHB
  FGB =: FGB__y rc } FGB
  BGB =: BGB__y rc } BGB
  0 0$0}}

cocurrent prev

render =: {{ NB. render to vt
  echo@''^:(h =. 0{HW__y) c =. curxy_vt_''
  0 0 $ raw_vt_@0 goxy c+h [ c render y [ goxy c=.0 10 -~ curxy_vt_''
:
  goxy x [ reset''
  f =. FG256_vt_ each FGB__y
  b =. BG256_vt_ each BGB__y
  j =. ,&.>
  s =. f j b j CHB__y
  for_row. s do.
    goxy x + 0, row_index
    reset@'' puts_vt_ 8 u: ;row
  end. }}

rndscr =: {{
  x render rnd__vid [ vid =. 32 10 conew'vid'
  codestroy__vid''
  echo ''[reset''[ raw_vt_ 0}}


demo =: {{
  curs 0 [ b =. 64 10 conew 'vid'
  for_c. 20$ '/-+\|' do.
    10 5 render b [ fill__b c [ sleep 50
  end. curs@1 codestroy__b''
  10 5 rndscr^:25''}}
