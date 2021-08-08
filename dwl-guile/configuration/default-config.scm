(define-module (dwl-guile configuration default-config)
               #:use-module (dwl-guile configuration records)
               #:use-module (dwl-guile configuration keycodes))

; Basic layouts
(define-public %dwl-layout-tile
               (dwl-layout
                 (id "tile")
                 (symbol "[]=")
                 (arrange '(dwl:tile monitor))))

(define-public %dwl-layout-monocle
               (dwl-layout
                 (id "monocle")
                 (symbol "[M]")
                 (arrange '(dwl:monocle monitor))))

(define-public %dwl-layout-floating
               (dwl-layout
                 (id "floating")
                 (symbol "><>")
                 (arrange #f)))

; Default layouts
(define-public %dwl-base-layouts
               (list %dwl-layout-tile
                     %dwl-layout-monocle
                     %dwl-layout-floating))

; Default monitor rules
(define-public %dwl-base-monitor-rules
               (list (dwl-monitor-rule
                       (layout "tile"))))

; Default keybindings
(define-public %dwl-base-tty-keys
               (map
                 (lambda (v)
                   (dwl-key
                     (modifiers '(CTRL ALT))
                     (key (string-append "F" (number->string v)))
                     (action `(dwl:chvt ,v))))
                 (iota 12 1 1)))

(define-public %dwl-base-keys
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
                 %dwl-base-tty-keys))

; Default mouse button bindings
(define-public %dwl-base-buttons
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
