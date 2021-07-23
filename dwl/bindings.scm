; Create a module wrapper around the dwl C bindings
(define-module (dwl bindings)
               #:export(
                        ; Modifiers
                        %modifiers
                        SHIFT
                        CAPS
                        CTRL
                        ALT
                        MOD2
                        MOD3
                        SUPER
                        MOD5

                        ; Monitor transforms
                        NORMAL
                        ROTATE-90
                        ROTATE-180
                        ROTATE-270
                        FLIPPED
                        FLIPPED-90
                        FLIPPED-180
                        FLIPPED-270

                        ; Mouse buttons
                        MOUSE-LEFT
                        MOUSE-MIDDLE
                        MOUSE-RIGHT

                        ; Procedures
                        xkb-key?
                        test-func))

(load-extension "dwl" "init_dwl")

; List of available key modifiers
(define %modifiers
  (list SHIFT
        CAPS
        CTRL
        ALT
        MOD2
        MOD3
        SUPER
        MOD5))
