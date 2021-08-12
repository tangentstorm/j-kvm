NB. ui application

coclass 'UiApp' extends 'kvm'

create =: {{
  W =: y               NB. list of widget references
  F =: a:              NB. reference to currently focused widget
  C =: '' conew 'vid'  NB. canvas for widgets
  B =: '' conew 'vid'  NB. main video buffer
  A =: '' conew 'vid'  NB. alternate frame buffer
  smudge''
}}

of =: {{ (x,'__y')~ [ y }}"1 0

NB. smudge marks entire screen dirty so we redraw
smudge =: {{ fill__A 128{a. }}

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
    if. # I. row do.
      goxy 0, ri=.row_index
      f =. FG256_vt_ each ri{FGB__B
      b =. BG256_vt_ each ri{BGB__B
      s =. f jn b jn ri{CHB__B
      reset@'' puts_vt_ 8 u: ;s
    end.
  end.
  0 0 $ copyto__A B }}
