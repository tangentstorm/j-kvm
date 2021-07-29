NB. viewmat in the console.
cocurrent 'vm'
require'viewmat tangentstorm/j-kvm/vt'
coinsert 'vt'

NB. downscale to fit inside width, height of screen,
NB. preserving the aspect ratio. Note that when we
NB. we draw, we will only use half this height.
downscale =: {{
  NB. force input to rank 2 array:
  if. 2 > # $y do. y =. ,. y end.
  if. 2 < # $y do. echo 'too many dimensions' throw. end.
  maxhw =. gethw_vt_''
  NB. scale whichever axis has the smaller ratio
  if. *./maxhw > $y do. y
  else. (([: >. ([:<./maxhw%$)*$) fitvm_jviewmat_ ]) y end. }}

NB. normally viewmat writes a large png file and then
NB. renders it in a separate window, but we are just going
NB. to take the raw image it creates, and render it to
NB. the console.
vm =: {{
  '' vm y
:
  c =. 8 u:16b2580 [ 'dat ang' =. x getvm1_jviewmat_ downscale_vm_ y
  for_row. 2 1 <@(c,~FG24B@[,BG24B@])/;._3 dat do.
    ROW =: row
    puts ;row
    puts RESET,CR,LF
  end. 0 0$0}}

vm_z_=:vm_vm_
