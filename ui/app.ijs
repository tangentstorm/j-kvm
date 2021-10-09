NB. ui application

coclass 'UiApp' extends 'kvm'

now =: 6!:1
then=: now''

create =: {{
  W =: y               NB. list of widget references
  F =: {.y             NB. reference to currently focused widget
  C =: '' conew 'vid'  NB. canvas for widgets
  B =: '' conew 'vid'  NB. main video buffer
  A =: '' conew 'vid'  NB. alternate frame buffer
  smudge''
}}

of =: {{ (x,'__y')~ [ y }}"1 0

NB. smudge marks entire screen dirty so we redraw
smudge =: {{
  for_w. W do. R__w =: 1 end.
  cscr__B'' [ reset__B''
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
  NB. TODO: compare A to B and draw only what has changed.
  jn =. ,&.>
  for_row. (CHB__A ~: CHB__B)+.(FGB__A ~: FGB__B)+.(BGB__A ~: BGB__B) do.
    if. +./ row do.
      goxy 0, ri=.row_index
      f =. FGC each ri{FGB__B
      b =. BGC each ri{BGB__B
      s =. f jn b jn ri{CHB__B
      reset@'' puts_vt_ 8 u: ;s
    end.
  end.
  0 0 $ copyto__A B }}

step =: render@update