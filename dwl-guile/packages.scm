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

            patch-dwl-guile-package))

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
   (version "2.0.2")
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
       "0z8ls92cgkry0fvybqzvg8jplwh3zjakdmq79kfxbczabvyijxk8"))))))

(define* (patch-dwl-guile-package pkg #:key (patches '()))
  "Create a new patched package of PKG with each patch in PATCHES
applied. This can be used to dynamically apply patches imported from
@code{(dwl-guile patches)}. Generally, it is recommended to create your
own package for dwl-guile that already has the patches applied."
  (package
   (inherit pkg)
   (source
    (origin
     (inherit (package-source pkg))
     (patch-flags '("-p1" "-F3"))
     (patches patches)))))
