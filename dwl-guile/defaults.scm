(define-module (dwl-guile defaults)
               #:use-module (guix gexp)
               #:use-module (dwl-guile configuration)
               #:export (
                         %layout-default
                         %layout-monocle
                         %layout-floating

                         %base-buttons
                         %base-layouts
                         %base-monitor-rules))

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
    (arrange #~(test-func "arrange default"))))

(define %layout-monocle
  (dwl-layout
    (id "monocle")
    (symbol "[M]")
    (arrange #~(test-func "arrange monocle"))))

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
