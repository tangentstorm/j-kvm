NB. ui application
class 'UiApp' extends 'kvm'

now =: 6!:1
then=: now''

create =: {{
  BG =: 0
  W =: y               NB. list of widget references
  F =: {.y             NB. reference to currently focused widget
  C =: '' conew 'vid'  NB. canvas for widgets
  B =: '' conew 'vid'  NB. main video buffer
  A =: '' conew 'vid'  NB. alternate frame buffer
  smudge'' }}

NB. smudge marks entire screen dirty so we redraw
smudge =: {{
  for_w. W do. R__w =: 1 end.
  cscr__B'' [ BG__B =: BG [ reset__B''
  fill__A 128{a. [ reset__A'' }}

update =: {{
  NB. update gets the number of seconds since last frame
  delta =. (then =: now'')-then
  for_w. W #~ 'A' of W do.
    update__w delta
  end. }}

render =: {{
  NB. redraw each visible widget that needs a refresh.
  NB. we draw each widget on buffer C (which is sized to
  NB. match the widget), then blit it to buffer B at the
  NB. relevant coordinates.
  pushterm B
  for_w. W #~ *./'VR' of "0 _  W do.
    pushterm C
    sethw__C 'HW'of"0 w
    render__w F = w   NB. has-focus flag
    popterm''
    XY__w blit__B C
  end.
  popterm''
  EMPTY }}


vtblit =: {{
  NB. compare buffers A and B, and draw only what has changed.
  jn =. ,&.>
  fc =. bc =. -82076 NB. arbitrary non-valid color
  for_row. (CHB__A~:CHB__B) +. (FGB__A~:FGB__B) +. BGB__A~:BGB__B do.
    for_col. I. row do.
      goxy |.> ix=. <row_index,col
      if. fc ~: f =.ix{FGB__B do. fg_vt_ fc=.f end.
      if. bc ~: b =.ix{BGB__B do. bg_vt_ bc=.b end.
      puts_vt_ 8 u: ix{CHB__B
    end.
  end.
  reset''
  0 0 $ copyto__A B }}

step =: vtblit@render@update

kc_l =: smudge

locpaths =: {{ (<'base'),F,coname'' }} NB. key handler paths
dispatch =: {{ (locpaths'') onkey y }}

run =: {{
  smudge''
  curs err =. break_kvm_=: 0
  try. (step with_kbd dispatch)''
  catchd. err =. 1 end.
  curs 1 [ raw 0  [ reset''
  if. err do. echo dberm'' end. }}
