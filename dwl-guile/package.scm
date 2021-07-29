(define-module (dwl-guile package)
               #:use-module (guix gexp)
               #:use-module (guix packages)
               #:use-module (gnu packages guile)
               #:use-module (dwl-guile patches)
               #:export (make-dwl-package))

; Create a new package definition based on `dwl-package`.
; This procedure also allows us to modify the package further,
; e.g. by adding the guile configuration patch, and any other user patches.
(define* (make-dwl-package dwl-package patches guile-patch?)
         (package
           (inherit dwl-package)
           (name "dwl-guile")
           (inputs
             `(("guile-3.0" ,guile-3.0)
               ,@(package-inputs dwl-package)))
           (source
             (origin
               (inherit (package-source dwl-package))
               (patches
                 (if guile-patch? (cons %patch-base patches) patches))))))
