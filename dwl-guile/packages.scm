(define-module (dwl-guile packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages libbsd)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages freedesktop)
  #:use-module (dwl-guile patches)
  #:export (
            dwl-guile
            libddrm-2.4.113
            wayland-1.21.0
            wayland-protocols-1.27
            xorg-server-xwayland-22.1.5
            wlroots-0.16.0

            make-dwl-package))

(define libdrm-2.4.113
  (package
   (inherit libdrm)
   (name "libdrm")
   (version "2.4.113")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://dri.freedesktop.org/libdrm/libdrm-"
                  version ".tar.xz"))
            (sha256
             (base32
              "1qg54drng3mxm64dsxgg0l6li4yrfzi50bgj0r3fnfzncwlypmvz"))))))

(define wayland-1.21.0
  (package
   (inherit wayland)
   (name "wayland")
   (version "1.21.0")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://gitlab.freedesktop.org/wayland/wayland/-/releases/"
                                version "/downloads/" name "-" version ".tar.xz"))
            (sha256
             (base32
              "1b0ixya9bfw5c9jx8mzlr7yqnlyvd3jv5z8wln9scdv8q5zlvikd"))))
   (propagated-inputs
    (list libffi))))

(define wayland-protocols-1.27
  (package
   (inherit wayland-protocols)
   (name "wayland-protocols")
   (version "1.27")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/"
                  version "/downloads/" name "-" version ".tar.xz"))
            (sha256
             (base32
              "0p1pafbcc8b8p3175b03cnjpbd9zdgxsq0ssjq02lkjx885g2ilh"))))
   (inputs
    (modify-inputs (package-inputs wayland-protocols)
                   (replace "wayland" wayland-1.21.0)))))

(define xorg-server-xwayland-22.1.5
  (package
   (inherit xorg-server-xwayland)
   (name "xorg-server-xwayland")
   (version "22.1.5")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://xorg.freedesktop.org/archive/individual"
                         "/xserver/xwayland-" version ".tar.xz"))
     (sha256
      (base32
       "0whnmi2v1wvaw8y7d32sb2avsjhyj0h18xi195jj30wz24gsq5z3"))))
   (inputs
    (modify-inputs (package-inputs xorg-server-xwayland)
                   (prepend libbsd libxcvt)
                   (replace "wayland" wayland-1.21.0)
                   (replace "wayland-protocols" wayland-protocols-1.27)))))

(define wlroots-0.16.0
  (package
   (inherit wlroots)
   (name "wlroots")
   (version "0.16.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://gitlab.freedesktop.org/wlroots/wlroots")
           (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "18rfr3wfm61dv9w8m4xjz4gzq2v3k5vx35ymbi1cggkgbk3lbc4k"))))
   (inputs
    (modify-inputs (package-inputs wlroots)
                   (prepend `(,hwdata "pnp"))))
   (propagated-inputs
    (modify-inputs (package-propagated-inputs wlroots)
                   (prepend libdrm-2.4.113)
                   (replace "wayland" wayland-1.21.0)
                   (replace "wayland-protocols" wayland-protocols-1.27)
                   (replace "xorg-server-xwayland" xorg-server-xwayland-22.1.5)))
   (arguments
    (substitute-keyword-arguments
     (package-arguments wlroots)
     ((#:phases phases)
      #~(modify-phases
         #$phases
         (add-after 'unpack 'patch-hwdata-path
                    (lambda* (#:key inputs #:allow-other-keys)
                      (substitute* "backend/drm/meson.build"
                                   (("/usr/share/hwdata/pnp.ids")
                                    (search-input-file inputs "share/hwdata/pnp.ids")))))))))))

(define dwl-guile
  (package
   (inherit dwl)
   (name "dwl-guile")
   (version "2.0.0")
   (inputs
    (modify-inputs (package-inputs dwl)
                   (prepend guile-3.0)
                   (replace "wlroots" wlroots-0.16.0)))
   (source
    (origin
     (inherit (package-source dwl))
     (uri (git-reference
           (url "https://github.com/engstrand-config/dwl-guile")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "1yyrsarc702ppcmni6cmp53gzzclyzjkf4jsysgr5rpqzv498wb6"))))
   (arguments
    (substitute-keyword-arguments
     (package-arguments dwl)
     ((#:phases phases)
      `(modify-phases
        ,phases
        ;; name the compiled executable "dwl-guile" so that
        ;; we can differentiate between regular dwl and dwl-guile.
        (replace
         'install
         (lambda*
             (#:key inputs outputs #:allow-other-keys)
           (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
             (install-file "dwl" bin)
             (rename-file (string-append bin "/dwl")
                          (string-append bin "/dwl-guile"))
             #t)))))))))

;; Create a new package definition based on `dwl-package`.
;; This procedure also allows us to modify the package further,
;; e.g. by adding the guile configuration patch, and any other user patches.
(define (make-dwl-package dwl-package patches)
  (package
   (inherit dwl-package)
   (source
    (origin
     (inherit (package-source dwl-package))
     (patch-flags '("-p1" "-F3"))
     (patches patches)))))
