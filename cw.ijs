NB. cw : colorwrite
NB. ------------------------------------------------------------
NB. This unit provides simple one-character mnemonics
NB. for the 16 standard ANSI colors codes.
NB.
NB. The first eight are:
NB.
NB. blac'k'  'r'ed      'g'reen   'y'ellow
NB. 'b'lue   'm'agenta  'c'yan    'w'hite
NB.
NB. The next eight are the same but uppercase,
NB. indicating a brighter version of the color.
NB.
NB. To use:
NB.
NB. coinsert 'cw' [ require 'tangentstorm/j-kvm/cw'
NB. fg'r'
NB. echo 'this is red'
NB.
NB. ------------------------------------------------------------
NB.
NB. There is also a verb, 'cw' that provides a mini-language
NB. for generating colored text, clearing the screen, indenting
NB. lines, and so on.
NB.
NB. See /demos/cw-demo.ijs for examples.
NB.
NB. ------------------------------------------------------------
NB.
NB. This is a start on porting a small domain-specific language
NB. that I wrote many years ago for colored text output:
NB.
NB. https://github.com/tangentstorm/xpl/blob/master/code/cw.pas
NB.
require 'tangentstorm/j-kvm/vt'
cocurrent 'cw'
coinsert 'vt'

CWCs=: 'krgybmcwKRGYBMCW'
cwc=: [: - [: [:^:(16=]) CWCs i. ]
ischr=: 2 = 3!:0

fg=: ([: fg_vt_ (cwc^:ischr f.))
bg=: ([: bg_vt_ (cwc^:ischr f.))

cw  =: {{
  '|' cw y
:
  assert ((1=#) *. ('literal' -: datatype)) esc=.x

  NB. esc,' ' will be a no-op to allow the initial cut.
  chunks =. <;.1 esc,' ',y

  NB. We also have to deal with esc,esc (double-escapes):
  chunks =. (#~ [: -. _1 |. 1 1 E. a:&=) chunks

  indent =. 0
  w =. {{if.#y do. puts y end.}} NB. not sure why i need this?
  for_c. chunks do.
    if. c = a: do. puts esc
    else.
      select. h =. {. s=.}.>c NB. h=head of s=string inside the chunk
      case. '{' do. w s}.~>:s i.'}' NB. comment until } !!TODO: esc in comment
      case. ' ' do. w }.s NB. initial cut.
      case. '_' do. puts CRLF,' '#~2*indent
      case. '>' do. w }.s [ indent=.indent+1
      case. '<' do. w }.s [ indent=.indent-1
      case. '$' do. cscr_vt_''
      case. '%' do. w  }.s [ ceol_vt_''
      case. '!' do. w 2}.s[ bg 1{s
      case. do.
        if. h e. CWCs do. w}.s [ fg h
        else. puts '<?',s,'?>' end.
      end.
    end.
  end.
}}

cwl =: puts@CRLF @ cw

fg_z =: fg_cw_
bg_z =: bg_cw_
cw_z_=:cw_cw_
cwl_z_=:cwl_cw_
