load 'tangentstorm/j-kvm/vid'
coinsert'kvm vt'
NB. make a video buffer the size of the terminal
buf =: '' conew 'vid'

init__buf =: {{
  CHB =: a.{~33+?HW$127-33
  FGB =: -?HW$256
  BGB =: HW$0 }}

rnd__buf =: {{
  for_yx. ?({.HW)#,:HW do.
    CHB =: CHB (<yx)}~ a.{~33+?127-33
    FGB =: FGB (<yx)}~ -?256
  end. }}

T =: 0
draw_fps =: {{
  pushterm buf
  goxy 2 1
  puts ' FPS: ',' ',~ 6j2 ": % (T =: 6!:1'') - T  NB. seconds/frame
  popterm'' }}

rnd =: {{
  NB. reload just for debugging:
  load 'tangentstorm/j-kvm/vid'
  while. keyp'' do. rkey'' end.
  init__buf''
  curs 0
  while. -.@keyp'' do.
    rnd__buf''
    draw_fps''
    0 0 blit buf
  end.
  curs 1 [ raw 0 }}

(9!:29) 1 [ 9!:27 'rnd _ '
