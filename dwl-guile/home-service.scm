; Defines the configuration records for dwl,
; as well as procedures for transforming the configuration
; into a format that can easily be parsed in C.
(define-module (dwl-guile home-service)
               #:use-module (guix gexp)
               #:use-module (guix packages)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (gnu packages)
               #:use-module (gnu packages wm)
               #:use-module (gnu packages qt)
               #:use-module (gnu packages freedesktop)
               #:use-module ((gnu packages linux) #:select(procps))
               #:use-module ((gnu packages admin) #:select(shepherd))
               #:use-module (gnu home services)
               #:use-module (gnu home services shells)
               #:use-module (gnu home services shepherd)
               #:use-module (gnu services configuration)
               #:use-module (dwl-guile utils)
               #:use-module (dwl-guile patches)
               #:use-module (dwl-guile packages)
               #:use-module (dwl-guile configuration)
               #:use-module (dwl-guile configuration transform)
               #:use-module (dwl-guile configuration default-config)
               #:export (
                         home-dwl-guile-service-type
                         home-dwl-guile-configuration
                         home-dwl-guile-configuration?
                         <home-dwl-guile-configuration>
                         home-dwl-guile-configuration-config
                         home-dwl-guile-configuration-patches
                         home-dwl-guile-configuration-package
                         home-dwl-guile-configuration-tty-number
                         home-dwl-guile-configuration-startup-commands
                         home-dwl-guile-environment-variables-service
                         home-dwl-guile-configuration-package-transform?
                         %base-environment-variables

                         modify-dwl-guile
                         modify-dwl-guile-config)

               ; re-export configurations so that they are
               ; available in the home environment without
               ; having to manually import them.
               #:re-export (
                            dwl-key
                            dwl-button
                            dwl-config
                            dwl-rule
                            dwl-colors
                            dwl-layout
                            dwl-tag-keys
                            dwl-xkb-rule
                            dwl-monitor-rule

                            %dwl-layout-tile
                            %dwl-layout-monocle
                            %dwl-layout-floating

                            %dwl-base-keys
                            %dwl-base-buttons
                            %dwl-base-layouts
                            %dwl-base-monitor-rules))

; Base wayland environment variables
; TODO: Add support for using electron apps natively in wayland?
(define %base-environment-variables
  `(("XDG_CURRENT_DESKTOP" . "dwl")
    ("XDG_SESSION_TYPE" . "wayland")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("ELM_ENGINE" . "wayland_egl")
    ("ECORE_EVAS_ENGINE" . "wayland-egl")
    ("_JAVA_AWT_WM_NONREPARENTING" . "1")
    ; TODO: This is a temporary fix to prevent dwl from crashing whenever
    ;       a GTK application is launched. It can also be fixed by manually providing
    ;       the correct $DISPLAY using input arguments, e.g. "emacs -d $DISPLAY".
    ("GDK_BACKEND" . "x11")))

; dwl service type configuration
(define-configuration
  home-dwl-guile-configuration
  (package
    (package dwl)
    "The dwl package to use. By default, this package will be
    automatically patched using the dwl-guile patch. You can
    find the base package definition for dwl in gnu/packages/wm.scm.

    If you want to use a custom dwl package, set @code{(package-transform #f)}
    in your dwl-guile configuration.")
  (tty-number
    (number 2)
    "Launch dwl on specified tty upon user login. Defaults to 2.")
  (patches
    (list-of-local-files '())
    "Additional patch files to apply to package.")
  (package-transform?
    (boolean #t)
    "If package should be dynamically transformed based on your configuration. Defaults to #t.")
  (environment-variables
    (list %base-environment-variables)
    "Environment variables for enabling wayland support in many different applications.
    Basic environment variables will be added if no value is specified.

    You can modify the variables that will be set by extending
    @code{%base-environment-variables}, or by specifying a custom list.")
  (native-qt?
    (boolean #t)
    "If qt applications should be rendered natively in Wayland.")
  (startup-commands
    (list-of-gexps '())
    "A list of gexps to be executed on dwl-guile startup.")
  (config
    (dwl-config (dwl-config))
    "Custom dwl-guile configuration. Replaces config.h.")
  (no-serialization))

; Helper for creating the custom dwl package.
; TODO: Figure out a way to only run this once?
(define (config->dwl-package config)
  (let ((package (home-dwl-guile-configuration-package config))
        (patches (home-dwl-guile-configuration-patches config)))
    (if (home-dwl-guile-configuration-package-transform? config)
        (make-dwl-package package patches)
        package)))

(define (home-dwl-guile-environment-variables-service config)
  (append
    (home-dwl-guile-configuration-environment-variables config)
    (if (home-dwl-guile-configuration-native-qt? config)
        `(("QT_QPA_PLATFORM" . "wayland-egl"))
        '())))

(define (home-dwl-guile-profile-service config)
  (append
    (list (config->dwl-package config)
          xdg-desktop-portal
          xdg-desktop-portal-wlr)
    (if (home-dwl-guile-configuration-native-qt? config)
        (list qtwayland)
        '())))

(define (home-dwl-guile-shepherd-service config)
  "Return a <shepherd-service> for the dwl-guile service"
  (list
    (shepherd-service
      (documentation "Run dwl-guile.")
      (provision '(dwl-guile))
      (auto-start? #f)
      (start
        (let ((config-dir (string-append (getenv "HOME") "/.config/dwl-guile")))
          #~(make-forkexec-constructor
              (list
                #$(file-append (config->dwl-package config) "/bin/dwl-guile")
                "-c" #$(string-append config-dir "/config.scm")
                "-s" #$(string-append config-dir "/startup.scm"))
              #:log-file #$(string-append (or (getenv "XDG_LOG_HOME") (getenv "HOME"))
                                          "/dwl-guile.log"))))
      (stop #~(make-kill-destructor)))))

; Automatically start dwl-guile on the selected tty after login
; TODO: Skip this step if @code{tty-number} is set to #f.
(define (home-dwl-guile-run-on-tty-service config)
  (list
    (format #f "[ $(tty) = /dev/tty~a ] && herd start dwl-guile"
            (home-dwl-guile-configuration-tty-number config))))

; TODO: Add option to disable this.
; TODO: Use sheperd action for this?
(define (home-dwl-guile-on-change-service config)
  `(("files/config/dwl-guile/config.scm"
     ,#~(system* #$(file-append procps "/bin/pkill") "-RTMIN" "dwl-guile"))))

(define (home-dwl-guile-files-service config)
  (let ((startup (home-dwl-guile-configuration-startup-commands config)))
    `(("config/dwl-guile/config.scm"
       ,(scheme-file
          "dwl-config.scm"
          #~(define config
              `(#$@(dwl-config->alist (home-dwl-guile-configuration-config config))))))
      ("config/dwl-guile/startup.scm"
       ,(program-file
          "dwl-startup.scm"
          (if (null? startup)
              #~(exit 0)
              #~(begin #$@startup)))))))

; Allow configuration to be extended by creating a new service
; of type @code{home-dwl-guile-service-type}.
;
; The extension service accepts a procedure that takes in
; the old configuration and returns an updated configuration.
; To reduce the amount of boilerplate needed, you can use one of
; the included syntax macro's:
;
; @example
; (simple-service
;   'change-dwl-guile-tty
;   home-dwl-guile-service-type
;   (modify-dwl-guile
;     (config =>
;             (home-dwl-guile-configuration
;               (inherit config)
;               (tty-number 3)))))
; @end example
;
; @example
; (simple-service
;   'add-dwl-guile-keybinding
;   home-dwl-guile-service-type
;   (modify-dwl-guile-config
;     (config =>
;             (dwl-config
;               (inherit config)
;               (keys
;                 (append
;                   (list
;                     (dwl-key
;                       (modifiers '(SUPER SHIFT))
;                       (key "m")
;                       (action #f)))
;                   (dwl-config-keys config)))))))
; @end example
(define (home-dwl-guile-extension old-config extend-proc)
  (extend-proc old-config))

(define-syntax modify-dwl-guile
  (syntax-rules (=>)
    ((_ (param => new-config))
     (lambda (old-config)
       (let ((param old-config))
         new-config)))))

(define-syntax modify-dwl-guile-config
  (syntax-rules (=>)
    ((_ (param => new-config))
     (lambda (old-config)
       (let ((param (home-dwl-guile-configuration-config old-config)))
         (home-dwl-guile-configuration
           (inherit old-config)
           (config new-config)))))))

(define home-dwl-guile-service-type
  (service-type
    (name 'home-dwl-guile)
    (extensions
      (list
        (service-extension
          home-profile-service-type
          home-dwl-guile-profile-service)
        (service-extension
          home-environment-variables-service-type
          home-dwl-guile-environment-variables-service)
        (service-extension
          home-files-service-type
          home-dwl-guile-files-service)
        (service-extension
          home-shepherd-service-type
          home-dwl-guile-shepherd-service)
        ; (service-extension
        ;   home-shell-profile-service-type
        ;   home-dwl-guile-run-on-tty-service)
        (service-extension
          home-run-on-change-service-type
          home-dwl-guile-on-change-service)))
    ; Each extension will override the previous config
    ; with its own, generally by inheriting the old config
    ; and then adding their own updated values.
    ;
    ; Composing the extensions is done by creating a new procedure
    ; that accepts the service configuration and then recursively
    ; call each extension procedure with the result of the previous extension.
    (compose (lambda (extensions)
               (match extensions
                      (() identity)
                      ((procs ...)
                       (lambda (old-config)
                         (fold-right (lambda (p extended-config) (p extended-config))
                                     old-config
                                     extensions))))))
    (extend home-dwl-guile-extension)
    (default-value (home-dwl-guile-configuration))
    (description "Configure and install dwl guile")))
