(define-module (dwl-guile defaults)
               #:use-module (guix gexp)
               #:use-module (dwl-guile configuration)
               #:export (
                         %layout-default
                         %layout-monocle
                         %layout-floating

                         %base-root-color
                         %base-border-color
                         %base-focus-color

                         %base-rule-id
                         %base-title-id
                         %base-tag-number
                         %base-floating-boolean
                         %base-monitor-number

                         %base-xkb-rules
                         %base-xkb-model
                         %base-xkb-layouts
                         %base-xkb-variants
                         %base-xkb-options

                         %base-monitor-name
                         %base-monitor-master-factor
                         %base-monitor-number-of-masters
                         %base-monitor-scale
                         %base-monitor-layout
                         %base-monitor-transform
                         %base-monitor-x
                         %base-monitor-y

                         %base-key-modifiers
                         %base-key-action

                         %base-button-modifiers
                         %base-button-action

                         %base-tag-view-modifiers
                         %base-tag-tag-modifiers
                         %base-tag-toggle-view-modifiers
                         %base-tag-toggle-tag-modifiers
                         %base-tag-keys-list-of-tag-to-key-pairs

                         %base-layout-arrange

                         %base-config-sloppy-focus
                         %base-config-border-px
                         %base-config-repeat-rate
                         %base-config-repeat-delay
                         %base-config-tap-to-click
                         %base-config-natural-scrolling
                         %base-config-terminal
                         %base-config-menu
                         %base-config-tags
                         %base-config-colors
                         %base-config-rules
                         %base-config-xkb-rules
                         %base-config-tag-keys
                         %base-config-buttons
                         %base-config-keys
                         %base-config-layouts
                         %base-config-monitor-rules
                         ; do not need to write "%base-" before each variable?
                         ; can load the variables in the configuration with
                         ; #:prefix %base-
                         ; ?
                         ))

; Default colors
(define %base-root-color '(0.3 0.3 0.3 1.0))
(define %base-border-color '(0.5 0.5 0.5 1.0))
(define %base-focus-color '(1.0 0.0 0.0 1.0))

; Default application rules
(define %base-rule-id #f)
(define %base-title-id #f)
(define %base-tag-number 1)
(define %base-floating-boolean #f)
(define %base-monitor-number 1) ;; can be confused with %base-monitor-* below?

; Default XKB rules
(define %base-xkb-rules "")
(define %base-xkb-model "")
(define %base-xkb-layouts '())
(define %base-xkb-variants '())
(define %base-xkb-options '())

; Default layout values
(define %base-layout-arrange #f)

; Default monitor rules
(define %base-monitor-name #f)
(define %base-monitor-master-factor 0.55)
(define %base-monitor-number-of-masters 1)
(define %base-monitor-scale 1)
(define %base-monitor-layout "default")
(define %base-monitor-transform 'TRANSFORM-NORMAL)
(define %base-monitor-x 0)
(define %base-monitor-y 0)

; Default keybinding values
(define %base-key-modifiers '(SUPER))
(define %base-key-action #f)

; Default mouse button values
(define %base-button-modifiers '(SUPER))
(define %base-button-action #f)

; Default tag keybindings
(define %base-tag-view-modifiers '(SUPER))
(define %base-tag-tag-modifiers '(SUPER SHIFT))
(define %base-tag-toggle-view-modifiers '(SUPER CTRL))
(define %base-tag-toggle-tag-modifiers '(SUPER SHIFT CTRL))
(define %base-tag-keys '(("1" . 1)
                         ("2" . 2)
                         ("3" . 3)
                         ("4" . 4)
                         ("5" . 5)
                         ("6" . 6)
                         ("7" . 7)
                         ("8" . 8)
                         ("9" . 9)))

; Default base configuration values
(define %base-config-sloppy-focus #t)
(define %base-config-border-px 1)
(define %base-config-repeat-rate 50)
(define %base-config-repeat-delay 300)
(define %base-config-tap-to-click #t)
(define %base-config-natural-scrolling #f)
(define %base-config-terminal '("alacritty"))
(define %base-config-menu '("bemenu"))
(define %base-config-tags '("1" "2" "3" "4" "5" "6" "7" "8" "9"))
(define %base-config-colors (dwl-colors))
(define %base-config-rules '())
(define %base-config-xkb-rules #f)
(define %base-config-tag-keys (dwl-tag-keys))

; Default monitor rules
(define %base-config-monitor-rules
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
(define %base-config-layouts
  (list %layout-default
        %layout-monocle
        %layout-floating))

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

(define %base-config-keys
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
(define %base-config-buttons
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
