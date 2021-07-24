(use-modules (guix gexp)
             (guix packages)
             ((guix licenses))
             (guix git-download)
             (guix build-system guile)
             (gnu packages guile)
             (gnu packages package-management))

(define this-directory
  (dirname (current-filename)))

(define source
  (local-file this-directory
	      #:recursive? #t
	      #:select? (git-predicate this-directory)))

; Package can not be installed because guix home is not available.
; This should be fixed in the next release of Guix:
; https://lists.gnu.org/archive/html/guix-devel/2021-07/msg00004.html
(package
    (name "home-dwl-guile")
    (version "0.0.1")
    (source source)
    (build-system guile-build-system)
    (native-inputs
     `(("guile" ,guile-3.0)
       ("guix" ,guix)))
    (home-page "https://github.com/engstrand-config/home-dwl-service")
    (synopsis "A home service for the dwl window manager with configuration in Guile")
    (description "This package provides a new home service for dwl that allows you to
install, configure and run dwl. Configuration is done entirely using guile, i.e. you
do not need to modify config.h and recompile to make changes. The configuration
is defined in your home config and will be applied when you run `guix home reconfigure`")
    (license gpl3+))
