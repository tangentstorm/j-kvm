load 'tangentstorm/j-kvm/ui'
coinsert'kvm vt'

NB. -------------------------------------------------------

class 'RandomTextWidget' extends 'UiWidget'

create =: {{
  (|.gethw'') create y
:
  'W H' =: x NB. default widget size is size of terminal.
  A =: 1     NB. it is animated.
  NB. make a video buffer the size of this widget:
  buf =: x conew 'vid'
  NB. add some methods to it:
  init__buf =: {{
    CHB =: a.{~33+?HW$127-33
    FGB =: -?HW$256
    BGB =: HW$0 }}
  step__buf =: {{
    for_yx. ?({.HW)#,:HW do.
      CHB =: CHB (<yx)}~ a.{~33+?127-33
      FGB =: FGB (<yx)}~ -?256
    end. }}
  init__buf'' }}

update =: {{ step__buf'' }}
render =: {{ 0 0 blit buf }}
codestroy =: {{
  codestroy__buf''
  codestroy_z_ f. '' }}

NB. -------------------------------------------------------

class 'FPSWidget' extends 'UiWidget'

create =: {{
  create_UiWidget_ f. y
  T =: 0 NB. frame timer
  W =: # text'' }}

text =: {{ ' FPS: ',' ',~ 6j2 ": % (T =: 6!:1'') - T }}
render =: {{ puts text'' }}

NB. -------------------------------------------------------

cocurrent 'base'

main =: {{
  rnd =: RandomTextWidget''
  fps =: FPSWidget''
  curs 0
  app =: UiApp(rnd,fps)
  step__app loop_kvm_'base'
  curs 1 [ raw 0  [ reset''
NB.  codestroy__rnd''
NB.  codestroy__fps''
NB.  codestroy__app''
}}

(9!:29) 1 [ 9!:27 'main _ '
