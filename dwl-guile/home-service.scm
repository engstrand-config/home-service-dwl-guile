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
               #:use-module (gnu home-services)
               #:use-module (gnu home-services shells)
               #:use-module (gnu home-services shepherd)
               #:use-module (gnu services configuration)
               #:use-module ((gnu packages admin) #:select(shepherd))
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
                         %base-environment-variables)

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
    ("QT_QPA_PLATFORM" . "wayland-egl")
    ("_JAVA_AWT_WM_NONPARENTING" . "1")))

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

; Add wayland specific environment variables
(define (home-dwl-guile-environment-variables-service config)
  (home-dwl-guile-configuration-environment-variables config))

; Add dwl-guile package to your profile
(define (home-dwl-guile-profile-service config)
  (append
    (list (config->dwl-package config))
    (map specification->package '("xdg-desktop-portal" "xdg-desktop-portal-wlr"))))

; Add new shepherd service for starting, stopping and restarting dwl-guile
(define (home-dwl-guile-shepherd-service config)
  "Return a <shepherd-service> for the dwl-guile service"
  (list
    (shepherd-service
      (documentation "Run dwl-guile")
      (provision '(dwl-guile))
      ; No need to auto start. Enabling this option means that
      ; dwl will start every time you run `guix home reconfigure`.
      ; Instead, we start it manually whenever we login to the
      ; chosen tty.
      (auto-start? #f)
      (start
        #~(make-forkexec-constructor
            (list
              #$(file-append (config->dwl-package config) "/bin/dwl-guile")
              "-c"
              ; TODO: Respect XDG configuration.
              ;       Set target config path in configuration?
              (string-append (getenv "HOME") "/.config/dwl/config.scm"))))
      (stop #~(make-kill-destructor)))))

; Automatically start dwl-guile on the selected tty after login
; TODO: Skip this step if @code{tty-number} is set to #f.
(define (home-dwl-guile-run-on-tty-service config)
  (list
    (format #f "[ $(tty) = /dev/tty~a ] && herd start dwl-guile"
            (home-dwl-guile-configuration-tty-number config))))

; Automatically updates the configuration of dwl-guile
; TODO: Add option to disable this.
;       Use signals instead? Killing dwl-guile is inefficient and
;       it will close all of your windows. Perhaps we could even
;       attach a file listener directly to dwl and re-parse the config
;       when changed?
(define (home-dwl-guile-on-change-service config)
  `(("files/config/dwl/config.scm"
     ,#~(system* #$(file-append shepherd "/bin/herd") "restart" "dwl-guile"))))

; Create the config file based on the configuration options.
; TODO: Respect XDG configuration?
(define (home-dwl-guile-files-service config)
  `(("config/dwl/config.scm"
     ,(scheme-file
        "dwl-config.scm"
        #~(define config
            `(#$@(dwl-config->alist (home-dwl-guile-configuration-config config))))))))

(define home-dwl-guile-service-type
  (service-type
    (name 'home-dwl)
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
        (service-extension
          home-shell-profile-service-type
          home-dwl-guile-run-on-tty-service)
        (service-extension
          home-run-on-change-service-type
          home-dwl-guile-on-change-service)))
    (compose concatenate)
    (default-value (home-dwl-guile-configuration))
    (description "Configure and install dwl guile")))
