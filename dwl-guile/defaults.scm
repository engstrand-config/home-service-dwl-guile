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
    (arrange '(dwl:tile monitor))))

(define %layout-monocle
  (dwl-layout
    (id "monocle")
    (symbol "[M]")
    (arrange '(dwl:monocle monitor))))

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
  (map
    (lambda (v)
      (dwl-key
        (modifiers '(CTRL ALT))
        (key (string-append "XF86Switch_VT_" (number->string v)))
        (action `(dwl:chvt ,v))))
    (iota 12 1 1)))

(define %base-config-keys
  (append
    (list
      (dwl-key
        (modifiers '(SUPER))
        (key "d")
        (action '(dwl:spawn-menu)))
      (dwl-key
        (modifiers '(SUPER))
        (key "Return")
        (action '(dwl:spawn-terminal)))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Return")
        (action '(dwl:shcmd "samedir")))
      (dwl-key
        (modifiers '(SUPER))
        (key "j")
        (action '(dwl:focus-stack 1)))
      (dwl-key
        (modifiers '(SUPER))
        (key "k")
        (action '(dwl:focus-stack -1)))
      (dwl-key
        (modifiers '(SUPER))
        (key "l")
        (action '(dwl:set-master-factor 0.05)))
      (dwl-key
        (modifiers '(SUPER))
        (key "h")
        (action '(dwl:set-master-factor -0.05)))
      ; (dwl-key
      ;   (modifiers '(SUPER))
      ;   (key "g")
      ;   (action '(dwl-toggle-gaps)))
      (dwl-key
        (modifiers '(SUPER))
        (key "space")
        (action '(dwl:zoom)))
      (dwl-key
        (modifiers '(SUPER))
        (key "Tab")
        (action '(dwl:view)))
      (dwl-key
        (modifiers '(SUPER))
        (key "q")
        (action '(dwl:killclient)))
      (dwl-key
        (modifiers '(SUPER))
        (key "t")
        (action '(dwl:set-layout "default")))
      (dwl-key
        (modifiers '(SUPER))
        (key "m")
        (action '(dwl:set-layout "monocle")))
      (dwl-key
        (modifiers '(SUPER))
        (key "f")
        (action '(dwl:toggle-fullscreen)))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "space")
        (action '(dwl:toggle-floating)))
      (dwl-key
        (modifiers '(SUPER))
        (key "0")
        (action '(dwl:view 0)))
      (dwl-key
        (modifiers '(SUPER))
        (key "Left")
        (action '(dwl:focus-monitor DIRECTION_LEFT)))
      (dwl-key
        (modifiers '(SUPER))
        (key "Right")
        (action '(dwl:focus-monitor DIRECTION_RIGHT)))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Left")
        (action '(dwl:tag-monitor DIRECTION_LEFT)))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Right")
        (action '(dwl:tag-monitor DIRECTION_LEFT)))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "Escape")
        (action '(dwl:quit)))
      (dwl-key
        (modifiers '())
        (key "Print")
        (action '(dwl:shcmd "grim")))
      (dwl-key
        (modifiers '(SHIFT))
        (key "Print")
        (action '(dwl:shcmd "flameshot")))
      (dwl-key
        (modifiers '(SUPER SHIFT))
        (key "w")
        (action '(dwl:shcmd "$BROWSER")))
      (dwl-key
        (modifiers '())
        (key "XF86WWW")
        (action '(dwl:shcmd "$BROWSER")))
      (dwl-key
        (modifiers '())
        (key "XF86PowerOff")
        (action '(dwl:quit)))
      (dwl-key
        (modifiers '())
        (key "XF86MonBrightnessDown")
        (action '(dwl:shcmd "brightnessctl s 10%-")))
      (dwl-key
        (modifiers '())
        (key "XF86MonBrightnessUp")
        (action '(dwl:shcmd "brightnessctl s +10%")))
      (dwl-key
        (modifiers '())
        (key "XF86AudioLowerVolume")
        (action '(dwl:shcmd "pamixer -u -d 3")))
      (dwl-key
        (modifiers '())
        (key "XF86AudioRaiseVolume")
        (action '(dwl:shcmd "pamixer -u -i 3"))))
    %base-tty-keys))

; Default mouse button bindings
(define %base-config-buttons
  (list
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-LEFT)
      (action '(dwl:move-resize CURSOR-MOVE)))
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-MIDDLE)
      (action '(dwl:toggle-floating)))
    (dwl-button
      (modifiers '(SUPER))
      (button 'MOUSE-RIGHT)
      (action '(dwl:move-resize CURSOR-RESIZE)))))
