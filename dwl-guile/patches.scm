(define-module (dwl-guile patches)
               #:use-module (guix gexp)
               #:use-module (srfi srfi-1)
               #:export (
                         %patch-base
                         %patch-xwayland
                         make-patch
                         list-of-local-files?))

(define (list-of-local-files? val) (every local-file? val))

(define (make-patch file-name)
  (local-file (string-append "patches/" file-name ".patch")))

; TODO: use absolute path to patches
; If we assume that `home-dwl-service` will be installed as a package,
; we can simply copy the patches folder into the build output and
; then reference the patches using #$(file-append home-dwl-service "/patches/xyz.patch"
(define %patch-base (make-patch "dwl-guile"))
(define %patch-xwayland (make-patch "xwayland"))
