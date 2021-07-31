(define-module (dwl-guile patches)
               #:use-module (guix gexp)
               #:use-module (srfi srfi-1)
               #:export (
                         %patch-base
                         %patch-xwayland
                         %patch-alpha
                         %patch-smartborders
                         %patch-attachabove
                         %patch-focusmon
                         make-patch
                         list-of-local-files?))

; Find the absolute path to home-dwl-service by looking in the
; Guile load path.
(define %patch-directory
  (find (lambda (path)
          (file-exists? (string-append path "/patches/dwl-guile.patch")))
        %load-path))

(define (list-of-local-files? val) (every local-file? val))

(define (make-patch file-name)
  (local-file (string-append %patch-directory "/patches/" file-name ".patch")))

(define %patch-base (make-patch "dwl-guile"))
(define %patch-xwayland (make-patch "xwayland"))
(define %patch-alpha (make-patch "alpha"))
(define %patch-smartborders (make-patch "smartborders"))
(define %patch-attachabove (make-patch "attachabove"))
(define %patch-focusmon (make-patch "focusmon"))
