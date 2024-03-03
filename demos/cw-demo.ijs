require 'tangentstorm/j-kvm/cw'

NB. cw = colorwrite!
NB.
NB. a tiny domain-specific language i originally wrote in turbo
NB. pascal way back in 1992 or so, for writing colored text to
NB. the display.
NB.
NB. the color codes were copied from the renegade bbs software.
NB. they are mnemonics for the 16 standard ansi colors:
NB.
NB. blac'k'  'r'ed      'g'reen   'y'ellow
NB. 'b'lue   'm'agenta  'c'yan    'w'hite
NB.
NB. (uppercase gives bright versions, !sets background)
NB. ex: |!k|w  is white (light gray) on a black background.
NB.
NB. I also added things like indentation (|> and |<), newlines (|_),
NB. and clearing the screen (|$).

cwl '|$|Ghello|K, |Bworld|K!|!k|w|_'

cwl '|>|cdef |Windented|w()|K:|_|G"""python?!"""|_|cpass|<|_|_|K#back here|w|_'
