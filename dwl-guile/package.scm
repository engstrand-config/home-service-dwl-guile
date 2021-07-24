(define-module (dwl-guile package)
               #:use-module (guix utils)
               #:use-module (guix packages)
               #:export (make-dwl-package))

; Create a new package definition based on `dwl-package`.
; Adds a new `dwl.desktop` file to the list of wayland
; sessions in `share/wayland-sessions`. It allows you to
; select dwl in your display manager when logging in.
;
; This procedure also allows us to modify the package further,
; e.g. by adding the guile configuration patch, and any other user patches.
(define*
  (make-dwl-package
    #:key
    (dwl-package #f)
    (desktop-entry? #t))
  (package
    (inherit dwl-package)
    (name "dwl-guile")
    (arguments
      (if (not desktop-entry?)
          (package-arguments dwl-package)
          (substitute-keyword-arguments
            (package-arguments dwl-package)
            ((#:phases phases)
             `(modify-phases
                ,phases
                (delete 'configure)
                (add-after
                  'build
                  'install-wayland-session
                  (lambda*
                    (#:key outputs #:allow-other-keys)
                    ;; Add a .desktop file to wayland-sessions
                    (let* ((output (assoc-ref outputs "out"))
                           (wayland-sessions (string-append output "/share/wayland-sessions")))
                      (mkdir-p wayland-sessions)
                      (with-output-to-file
                        (string-append wayland-sessions "/dwl.desktop")
                        (lambda _
                          (format #t
                                  "[Desktop Entry]~@
                                  Name=dwl~@
                                  Comment=Dynamic Window Manager for Wayland~@
                                  Exec=~a/bin/dwl~@
                                  TryExec=~@*~a/bin/dwl~@
                                  Icon=~@
                                  Type=Application~%"
                                  output)))))))))))))
