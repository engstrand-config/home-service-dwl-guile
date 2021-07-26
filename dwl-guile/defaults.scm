(define-module (dwl-guile defaults)
               #:use-module (guix gexp)
               #:use-module (dwl-guile configuration)
               #:export (
                         %layout-default
                         %layout-monocle
                         %layout-floating

                         %base-buttons
                         %base-keys
                         %base-layouts
                         %base-monitor-rules))

(define %base-tty-keys
  (list
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_1")
      (action #~(chvt 1)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_2")
      (action #~(chvt 2)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_3")
      (action #~(chvt 3)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_4")
      (action #~(chvt 4)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_5")
      (action #~(chvt 5)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_6")
      (action #~(chvt 6)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_7")
      (action #~(chvt 7)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_8")
      (action #~(chvt 8)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_9")
      (action #~(chvt 9)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_10")
      (action #~(chvt 10)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_11")
      (action #~(chvt 11)))
    (dwl-key
      (modifiers '(CTRL ALT))
      (key "XF86Switch_VT_12")
      (action #~(chvt 12)))))

(define %base-keys
  (append
    (list
      (dwl-key
        (modifiers '(SUPER))
        (key "d")
        (action #f)) ;; spawn .v=menucmd
      (dwl-key
        (modifiers '(SUPER))
        (key "Return")
        (action #~(spawn-terminal))) ;; spawn .v=termcmd
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Return")
        (action #f)) ;; SHCMD("samedir") ;; not implemented... how does it work in Wayland?
      (dwl-key
        (modifiers '(SUPER))
        (key "j")
        (action #f)) ;; focusstack .i=+1
      (dwl-key
        (modifiers '(SUPER))
        (key "k")
        (action #f)) ;; focusstack .i=-1
      (dwl-key
        (modifiers '(SUPER))
        (key "h")
        (action #f)) ;; setmfact .f=-0.05
      (dwl-key
        (modifiers '(SUPER))
        (key "l") ;; setmfact .f=+0.05
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "g") ;; togglegaps 0 ;; not implemented yet?
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "space")
        (action #f)) ;; zoom 0
      (dwl-key
        (modifiers '(SUPER))
        (key "Tab")
        (action #f)) ;; view 0
      (dwl-key
        (modifiers '(SUPER))
        (key "q") ;; killclient 0
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "t") ;; setlayout .v=&layouts[0]
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "m") ;; setlayout .v=&layouts[2] ;; toggle layouts?
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "f") ;; togglefullscreen 0
        (action #f))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "space") ;; togglefloating 0
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "0") ;; view .ui=~0
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "Left") ;; focusmon .i=WLR_DIRECTION_LEFT
        (action #f))
      (dwl-key
        (modifiers '(SUPER))
        (key "Right") ;; focusmon .i=WLR_DIRECTION_RIGHT
        (action #f))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Left") ;; tagmon .i=WLR_DIRECTION_LEFT
        (action #f))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Right") ;; tagmon .i=WLR_DIRECTION_RIGHT
        (action #f))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Escape") ;; quit 0
        (action #f))
      (dwl-key
        (modifiers '())
        (key "Print") ;; primary print screen command?
        (action #f))
      (dwl-key
        (modifiers '(SHIFT))
        (key "Print") ;; secondary print screen command?
        (action #f))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "w") ;; open browser
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86WWW") ;; open browser
        (action #f))
      (dwl-key
        (modifiers '())
        (key "Print") ;; print screen command?
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86PowerOff") ;; quit ;; or loginctl poweroff?
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86MonBrightnessDown") ;; monitor brightness down?
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86MonBrightnessUp") ;; monitor brightness up?
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86KbdBrightnessDown") ;; SHCMD("brightnessctl s-10%")
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86KbdBrightnessUp") ;; SHCMD("brightnessctl s+10%")
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86AudioLowerVolume") ;; SHCMD("pamixer -u -d 3") ;; not sure
        (action #f))
      (dwl-key
        (modifiers '())
        (key "XF86AudioRaiseVolume") ;; SHCMD("pamixer -u -i 3") ;; not sure
        (action #f)))
    %base-tty-keys))

; Default mouse button bindings
(define %base-buttons
  (list
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-LEFT)
      (action #f)) ; move window
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-MIDDLE)
      (action #f)) ; toggle floating
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-RIGHT)
      (action #f)))) ; resize window

; Default monitor rules
(define %base-monitor-rules
  (list (dwl-monitor-rule)))

; Basic layouts
(define %layout-default
  (dwl-layout
    (id "default")
    (symbol "[]=")
    (arrange #~(tile monitor))))

(define %layout-monocle
  (dwl-layout
    (id "monocle")
    (symbol "[M]")
    (arrange #~(monocle monitor))))

(define %layout-floating
  (dwl-layout
    (id "floating")
    (symbol "><>")
    (arrange #f)))

; Default layouts
(define %base-layouts
  (list %layout-default
        %layout-monocle
        %layout-floating))
