(define-module (dwl-guile package)
               #:use-module (guix utils)
               #:use-module (guix packages)
               #:export (make-dwl-package))

; Create a new package definition based on `dwl-package`.
; This procedure also allows us to modify the package further,
; e.g. by adding the guile configuration patch, and any other user patches.
(define* (make-dwl-package dwl-package)
         (package
           (inherit dwl-package)
           (name "dwl-guile")))
