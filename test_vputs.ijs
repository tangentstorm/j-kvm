NB. start on a test framework for vt-100 escape code interpreter (vputs) from vid.ijs
NB. todo: make a better and more thorough test framework.

load 'tangentstorm/j-kvm/vid'
load 'tangentstorm/j-kvm/vm'

bhw =: 15 15
buf =: (|.bhw) conew 'vid'
fill__buf '.'
BGB__buf =: bhw $ _2
FGB__buf =: bhw $ _15

pushterm buf

FG__buf =: _7
BG__buf =: 0

goxy 0 0

s =: (vm i. 10 10),RESET

vputs CSI,'41mhello'  NB. red 'hello' in upper left
vputs CSI,'H'
echo XY__buf
assert XY__buf -: 0 0
vputs CSI,'38;5;255mHELLO',CRLF NB. ovewrite in upper case with bright white on red
assert XY__buf -: 0 1

vputs s
popterm''
20 0  render buf
