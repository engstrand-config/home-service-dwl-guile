(define-module (dwl-guile patches)
               #:use-module (guix gexp)
               #:use-module (srfi srfi-1)
               #:export (
                         %patch-base
                         %patch-xwayland
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

; TODO: use absolute path to patches
; If we assume that `home-dwl-service` will be installed as a package,
; we can simply copy the patches folder into the build output and
; then reference the patches using #$(file-append home-dwl-service "/patches/xyz.patch"
(define %patch-base (make-patch "dwl-guile"))
(define %patch-xwayland (make-patch "xwayland"))
