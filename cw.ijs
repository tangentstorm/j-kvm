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
NB. This is the smallest possible start on porting a small
NB. domain-specific language that I wrote many years ago
NB. for colored text output:
NB.
NB. https://github.com/tangentstorm/xpl/blob/master/code/cw.pas
NB.
require 'tangentstorm/j-kvm/vt'
cocurrent 'cw'
coinsert 'vt'

cwc=. [: - [: [:^:(16=]) 'krgybmcwKRGYBMCW' i. ]
ischr=. 2 = 3!:0
fg=: ([: fg_vt_ cwc^:ischr) f.
bg=: ([: bg_vt_ cwc^:ischr) f.
