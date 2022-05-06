NB.
NB. kvm: keyboard/video/mouse driver for terminal apps in j
NB.
NB. ----------------------------------------------------
cocurrent 'kvm'
coinsert 'vt' [ require 'tangentstorm/j-kvm/vt'

ticks=: 0 NB. milliseconds between calling v
break=: 0

NB. with_kbd: run v on keypress, u every 'ticks' milliseconds.
NB. until i get keyp'' test working)
with_kbd =: {{
  u'' [ raw 1 [ y
  while. -. break_kvm_ do.
    if. keyp'' do. v rkey''
    else. sleep ticks end.
    u''
  end. raw 0 [ curs 1 }}

NB. Mouse state as a vector
'MB0 MB1 MB2 MWHL' =: 2 3 4 5
MOUSE =: 6$0


NB. find callback name for input in y (where y:rkey'')
NB. note: if key is ESC, this may read extra values from input,
NB. so only call this once per event.
key_handlers =: {{
  'NUL CTL ESC SEP SPC ASC BSP UTF' =. i.1+# bins =. 0 26 27 31 32 126 127
  select. c =. bins I. k =. {.>y
  case. NUL do. vnm =. 'k_nul'
  case. CTL do. vnm =. 'kc_',a.{~97+<:k  NB. ascii ctrl+letter ^C-> kc_c
  case. ESC do. vnm =. 'k_esc'
    NB. check for immediate second key
    NB. TODO: this should be table driven, since different
    NB. terminals have different encodings.
    if. keyp'' do.
      k2=.>rkey''
      if. k2 e. 97+i.26 do. NB. alt x comes in as esc,x
        vnm =. 'ka_',k2{a.
      elseif. 91 = k2 do.          NB. 91 = a.i.'['
        select. k3=.{.>rkey''
        case.  65 do. vnm =. 'k_arup'   NB. CSI,'A'
        case.  66 do. vnm =. 'k_ardn'   NB. CSI,'B'
        case.  67 do. vnm =. 'k_arrt'   NB. CSI,'B'
        case.  68 do. vnm =. 'k_arlf'   NB. CSI,'C'
        case.  60 do. vnm =. 'm_evt'    NB. CSI,'<' mouse events after 'mouse 1'
          vnm =. 'm_evt'
          s =. '' while. -. (c=.a.{~{.>rkey'') e. 'Mm' do. s=.s,c end.
          'me mx my' =. 0&". every ';' cut s
          MOUSE =: (<:mx,my) 0 1 } MOUSE
          select. me
          case. 0 do. MOUSE =: ('mM' i.c) MB0 } MOUSE
          case. 1 do. MOUSE =: ('mM' i.c) MB1 } MOUSE
          case. 2 do. MOUSE =: ('mM' i.c) MB2 } MOUSE
          case.64 do. MOUSE =: (<:MWHL{MOUSE) MWHL } MOUSE
          case.65 do. MOUSE =: (>:MWHL{MOUSE) MWHL } MOUSE
          end.
          reset@'' ceol@'' puts ": MOUSE [ fgc 12 [ goxy 0 0
        case. do.
          if. 49 54 ({.@] < [)*.([ < {:@]) k do.
            select. kn =. 0". (k3{a.),wfc'~'
            case. 1 do. vnm =. 'k_home' case. 2 do. vnm =. 'k_ins'
            case. 3 do. vnm=. 'k_del'   case. 4 do. vnm=. 'k_end'
            case. 5 do. vnm=. 'k_pgup'  case. 6 do. vnm=. 'k_pgdn'
            case. 7 do. vnm=. 'k_pgdn'
            case. 11 do. vnm=. 'k_f1'   NB. shift-f1 is same as f11
            case. 12 do. vnm=. 'k_f2'
            case. 13 do. vnm=. 'k_f3'   case. 25 do. vnm =. 'k_sf3'
            case. 14 do. vnm=. 'k_f4'   case. 26 do. vnm =. 'k_sf4'
            case. 15 do. vnm=. 'k_f5'   case. 28 do. vnm =. 'k_sf5'
            case. 16 do. NB. ?!?!       case. 27 do. ??
            case. 17 do. vnm=. 'k_f6'   case. 29 do. vnm =. 'k_sf6'
            case. 18 do. vnm=. 'k_f7'   case. 31 do. vnm =. 'k_sf7'
            case. 19 do. vnm=. 'k_f8'   case. 32 do. vnm =. 'k_sf8'
            case. 20 do. vnm=. 'k_f9'   case. 33 do. vnm =. 'k_sf9'
            case. 21 do. vnm=. 'k_f10'
            case. 22 do. NB. !?
            case. 23 do. vnm=. 'k_f11'  NB. same as shift-f1
            case. 24 do. vnm=. 'k_f12'  NB. same as shift-f2
            end.
          end.
        end.
      else.
        NB. echo 'unexpected key after esc:', ":k2
      end.
    end.
  case. SEP do. NB. TODO TODO ^\, ^], ^^, ^_ (FS,GS,RS,US)
  case. SPC do. vnm =. 'k_spc'
  case. ASC do. vnm =. 'k_',a.{~k
  case. BSP do. vnm =. 'k_bsp'
  case. UTF do. vnm =. 'kx_',hfd k
    NB. hex code catchall (k=255)-> kc_ff
    NB. ^? = KDEL, other alt chars
  end.
  r =. <vnm
  if. c e. SPC,ASC do. r=.r,<'k_asc' end.
  r }}


NB. dispatch key event y (y=.rkey'') in namespaces x
onkey =: {{
  (coname'') onkey y
:
  for_kh. (key_handlers y),<'k_any' do.
    for_loc. x do.
      if. 3 = 4!:0 vnm=.<(>kh),'__x' do.
        (>vnm)~ a.{~>y
        EMPTY return.
      end.
    end.
  end.
  if. 0={.>y do. break_kvm_=:1 end. NB. break unless k_nul found
  EMPTY }}

loop =: {{
  if. #y do. cocurrent y end.
  if. 3=4!:0<'kvm_init' do. kvm_init'' end.
  u with_kbd onkey break_kvm_ =: 0
  if. 3=4!:0<'kvm_done' do. kvm_done'' end. }}
