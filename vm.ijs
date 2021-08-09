NB. viewmat in the console.
cocurrent 'vm'
require'viewmat tangentstorm/j-kvm/vt'
coinsert 'vt'

NB. downscale to fit inside width, height of screen,
NB. preserving the aspect ratio. Note that when we
NB. we draw, we will only use half this height.
downscale =: {{
  NB. force input to rank 2 array:
  if. 2 > # $y do. y =. |: ,. y end.
  if. 2 < # $y do. echo 'too many dimensions' throw. end.
  mxhw =. gethw_vt_''
  NB. scale whichever axis has the smaller ratio
  if. *./mxhw > $y do. y
  else. (([: |. [: >. ([:<./mxhw%$)*$) fitvm_jviewmat_ ]) y end. }}

NB. normally viewmat writes a large png file and then
NB. renders it in a separate window, but we are just going
NB. to take the raw image it creates, and render it to
NB. the console.
vm =: {{
  '' vm_vm_ y
:
  c =. 8 u:16b2580 [ y =. downscale_vm_ y
  if. x-:'rgb' do. dat =.y else. dat =. >{. x getvm1_jviewmat_ y end.
  if. 2|#dat do. dat =. dat,0 end. NB. force even number of rows
  r =.''
  for_row. (,:~2 1) <@(c,~FG24B@[,BG24B@])/;._3 dat do.
    r =. r, RESET,CEOL,(;row),CRLF
  end. emit_vm_ r }}


NB. this is a verb that emits the generated string of escape codes
NB. in a way that that plays nice with the repl in jconsole.
NB. without the ceol/reset, you can get long lines of color at the
NB. bottom of the screen. Also these just write escape codes
NB. directly to the terminal, and return nothing, which means J
NB. will not insert an extra newline after the image.
NB. The reason it is a separate verb is that you may want to
NB. capture the generated escape sequences in a string. If so,
NB. one way to do that would be: emit_vm_ =: ]
emit0 =: emit =: {{ ceol'' [ reset'' [ puts y }}
emit =: ]
vm_z_=:vm_vm_
