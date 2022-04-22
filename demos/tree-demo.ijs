NB. example program : directory browser
NB. ------------------------------------------------------------
load 'tangentstorm/j-kvm/ui'
coinsert'kvm vt'

NB. run each verb in gerund x against corresponding boxed item of y
team=:{{x`:6 L: _1 y}}"0 _1

myls =: {{ NB. path -> boxed(boxed names) and boxed(isdir bits)
  try. t =. <"1] 0 4{|:1!:0 '*',~'/',~^:(*#y) y
    ]`(('d'=4&{) S:0) team t
  catch. 2 $ a:
  end.}}

NB. build tree widget
tree =: UiTree L ['L HC'=.myls''
H__tree =: <:{.gethw''
TX_BG__tree =: _234
fetch_items__tree =: {{ myls_base_ '/' joinstring path'' }}
HC__tree =: HC

NB. override the colors for directories and emacs backups (*~)
render_item__tree =: {{
  if. x~:C do.
    if. x{HC do. fg _15 end.
    if. '~'={:>y do. fg _8 end.
  end.
  x render_item_UiTree_ f.y }}

NB. assign key handlers
k_n =: fwd__tree
k_p =: bak__tree
k_u =: upw__tree
k_q =: {{break_kvm_=:1}}
k_t =: toggle__tree
kc_i =: toggle__tree  NB. tab key

NB. code to run instead of j prompt
main =: {{
  curs 0
  app =: UiApp ,tree
  step__app loop_kvm_ 'base'
  curs 1 [ raw 0  [ reset''
  codestroy__app''
  exit 0 }}

(9!:29) 1 [ 9!:27 'main _ '
