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
  #:export (
            home-dwl-guile-service-type
            home-dwl-guile-configuration
            home-dwl-guile-configuration?
            <home-dwl-guile-configuration>
            home-dwl-guile-configuration-config
            home-dwl-guile-configuration-package
            home-dwl-guile-configuration-native-qt?
            home-dwl-guile-configuration-auto-start?
            home-dwl-guile-configuration-reload-config-on-change?
            home-dwl-guile-configuration-startup-commands
            home-dwl-guile-configuration-environment-variables
            home-dwl-guile-configuration-documentation
            home-dwl-guile-extension
            %dwl-guile-base-env-variables)

  ;; re-export configurations so that they are
  ;; available in the home environment without
  ;; having to manually import them.
  #:re-export (dwl-guile patch-dwl-guile-package))

;; Base wayland environment variables
;; TODO: Add support for using electron apps natively in wayland?
(define %dwl-guile-base-env-variables
  `(("XDG_CURRENT_DESKTOP" . "dwl")
    ("XDG_SESSION_TYPE" . "wayland")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("ELM_ENGINE" . "wayland_egl")
    ("ECORE_EVAS_ENGINE" . "wayland-egl")
    ("_JAVA_AWT_WM_NONREPARENTING" . "1")
    ("GDK_BACKEND" . "wayland")))

;; dwl service type configuration
(define-configuration
  home-dwl-guile-configuration
  (package
   (package dwl-guile)
   "The dwl package to use.
    If you want to use a custom dwl package, set @code{(package-transform #f)}
    in your dwl-guile configuration.")
  (auto-start?
   (boolean #t)
   "Launch dwl automatically upon user login. Defaults to #t.")
  (reload-config-on-change?
   (boolean #t)
   "Automatically reload dwl-guile configuration when reconfiguring the home environment.")
  (environment-variables
   (list %dwl-guile-base-env-variables)
   "Environment variables for enabling Wayland support in many different applications.
    Basic environment variables will be added if no value is specified.

    You can modify the variables that will be set by extending
    @code{%dwl-guile-base-env-variables}, or by specifying a custom list.")
  (native-qt?
   (boolean #t)
   "If Qt applications should be rendered natively in Wayland.
This will also install the qtwayland package.")
  (startup-commands
   (list-of-gexps '())
   "A list of gexps to be executed on dwl-guile startup.")
  (config
   (list-of-gexps '())
   "Custom dwl-guile configuration. Replaces config.h.")
  (no-serialization))

(define (home-dwl-guile-environment-variables-service config)
  (append
   (home-dwl-guile-configuration-environment-variables config)
   (if (home-dwl-guile-configuration-native-qt? config)
       `(("QT_QPA_PLATFORM" . "wayland-egl"))
       '())))

(define (home-dwl-guile-profile-service config)
  (append
   (list (home-dwl-guile-configuration-package config)
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
    (auto-start? (home-dwl-guile-configuration-auto-start? config))
    (start
     (let ((config-dir (string-append (getenv "HOME") "/.config/dwl-guile")))
       #~(make-forkexec-constructor
          (list
           #$(file-append (home-dwl-guile-configuration-package config) "/bin/dwl-guile")
           "-c" #$(string-append config-dir "/config.scm")
           "-s" #$(string-append config-dir "/startup.scm"))
          #:pid-file #$(string-append (or (getenv "XDG_RUNTIME_DIR")
                                          (format #f "/run/user/~a" (getuid)))
                                      "/dwl-guile.pid")
          #:log-file #$(string-append (or (getenv "XDG_LOG_HOME")
                                          (getenv "HOME"))
                                      "/dwl-guile.log"))))
    (stop #~(make-kill-destructor)))))

(define (home-dwl-guile-on-change-service config)
  (if (home-dwl-guile-configuration-reload-config-on-change? config)
      `(("files/.config/dwl-guile/config.scm"
         ,#~(system*
             #$(file-append (home-dwl-guile-configuration-package config) "/bin/dwl-guile")
                     "-e" "(dwl:reload-config)")))
      '()))

(define (home-dwl-guile-files-service config)
  (let ((startup (home-dwl-guile-configuration-startup-commands config)))
    `((".config/dwl-guile/config.scm"
       ,(scheme-file
         "dwl-config.scm"
         #~(#$@(home-dwl-guile-configuration-config config))))
       (".config/dwl-guile/startup.scm"
        ,(program-file
          "dwl-startup.scm"
          (if (null? startup)
              #~(exit 0)
              #~(begin #$@startup)))))))

(define (home-dwl-guile-extension original-config extensions)
  (let ((extensions (reverse extensions)))
    (home-dwl-guile-configuration
     (inherit original-config)
     (config
      (append
       (home-dwl-guile-configuration-config original-config)
       extensions)))))

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
     (service-extension
      home-run-on-change-service-type
      home-dwl-guile-on-change-service)))
   ;; Each extension will override the previous config
   ;; with its own, generally by inheriting the old config
   ;; and then adding their own updated values.
   ;;
   ;; Composing the extensions is done by creating a new procedure
   ;; that accepts the service configuration and then recursively
   ;; call each extension procedure with the result of the previous extension.
   (compose identity)
   (extend home-dwl-guile-extension)
   (default-value (home-dwl-guile-configuration))
   (description "Configure and install dwl-guile")))

(define (home-dwl-guile-configuration-documentation)
  (generate-documentation
   `((home-dwl-guile-configuration
      ,home-dwl-guile-configuration-fields))
   'home-dwl-guile-configuration))
