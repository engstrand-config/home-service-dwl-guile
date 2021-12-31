(define-module (dwl-guile configuration default-config)
  #:use-module (dwl-guile configuration records)
  #:use-module (dwl-guile configuration keycodes))

;; Basic layouts
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

;; Default layouts
(define-public %dwl-base-layouts
  (list %dwl-layout-tile
        %dwl-layout-monocle))

;; Default monitor rules
(define-public %dwl-base-monitor-rules
  (list (dwl-monitor-rule
         (layout "tile"))))

;; Default keybindings
(define-public %dwl-base-tty-keys
  (map
   (lambda (v)
     (dwl-key
      (key (string-append "C-M-<f" (number->string v) ">"))
      (action `(dwl:chvt ,v))))
   (iota 12 1 1)))

(define-public %dwl-base-keys
  (list
   (dwl-key
    (key "s-d")
    (action '(dwl:spawn-menu)))
   (dwl-key
    (key "s-<return>")
    (action '(dwl:spawn-terminal)))
   (dwl-key
    (key "s-j")
    (action '(dwl:focus-stack 1)))
   (dwl-key
    (key "s-k")
    (action '(dwl:focus-stack -1)))
   (dwl-key
    (key "s-l")
    (action '(dwl:set-master-factor 0.05)))
   (dwl-key
    (key "s-h")
    (action '(dwl:set-master-factor -0.05)))
   (dwl-key
    (key "s-<space>")
    (action '(dwl:zoom)))
   (dwl-key
    (key "s-<tab>")
    (action '(dwl:view)))
   (dwl-key
    (key "s-q")
    (action '(dwl:killclient)))
   (dwl-key
    (key "s-t")
    (action '(dwl:set-layout "tile")))
   (dwl-key
    (key "s-m")
    (action '(dwl:set-layout "monocle")))
   (dwl-key
    (key "s-f")
    (action '(dwl:toggle-fullscreen)))
   (dwl-key
    (key "S-s-<space>")
    (action '(dwl:toggle-floating)))
   (dwl-key
    (key "s-0")
    (action '(dwl:view 0)))
   (dwl-key
    (key "S-s-<escape>")
    (action '(dwl:quit)))
   (dwl-key
    (key "<XF86PowerOff>")
    (action '(dwl:quit)))

   ;; TODO: Remove these
   (dwl-key
    (key "<XF86MonBrightnessDown>")
    (action '(dwl:shcmd "brightnessctl s 10%-")))
   (dwl-key
    (key "<XF86MonBrightnessUp>")
    (action '(dwl:shcmd "brightnessctl s +10%")))
   (dwl-key
    (key "<XF86AudioLowerVolume>")
    (action '(dwl:shcmd "pamixer -u -d 3")))
   (dwl-key
    (key "<XF86AudioRaiseVolume>")
    (action '(dwl:shcmd "pamixer -u -i 3")))
   (dwl-key
    (key "<XF86AudioMute>")
    (action '(dwl:shcmd "pamixer -t")))))

;; Default mouse button bindings
(define-public %dwl-base-buttons
  (list
   (dwl-button
    (key "s-<mouse-left>")
    (action '(dwl:move-resize CURSOR-MOVE)))
   (dwl-button
    (key "s-<mouse-middle>")
    (action '(dwl:toggle-floating)))
   (dwl-button
    (key "s-<mouse-right>")
    (action '(dwl:move-resize CURSOR-RESIZE)))))
