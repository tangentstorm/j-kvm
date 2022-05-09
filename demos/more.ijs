NB. simple plain-text viewer demo
NB. sort of like the 'more' command.
require 'tangentstorm/j-kvm/ui'

fnm =: 2 {:: :: '' ARGV
txt =: UiList 'b'freads^:(*@#@]) fnm
'H__txt W__txt' =: gethw_vt_''

app =: UiApp ,txt
(9!:29) 1 [ 9!:27 'run__app _ '
