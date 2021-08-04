(define-module (dwl-guile package)
               #:use-module (guix gexp)
               #:use-module (guix utils)
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
               (patch-flags '("-p1" "-F3"))
               (patches
                 (if guile-patch? (cons %patch-base patches) patches))))
           (arguments
             (substitute-keyword-arguments
               (package-arguments dwl-package)
               ((#:phases phases)
                `(modify-phases
                   ,phases
                   ; name the compiled executable "dwl-guile" so that
                   ; we can differentiate between regular dwl and dwl-guile.
                   (replace
                     'install
                     (lambda*
                       (#:key inputs outputs #:allow-other-keys)
                       (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
                         (install-file "dwl" bin)
                         (rename-file (string-append bin "/dwl")
                                      (string-append bin "/dwl-guile"))
                         #t)))))))))


