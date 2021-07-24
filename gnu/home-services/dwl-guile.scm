; Defines the configuration records for dwl,
; as well as procedures for transforming the configuration
; into a format that can easily be parsed in C.
(define-module (gnu home-services dwl-guile)
               #:use-module (guix gexp)
               #:use-module (guix packages)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (gnu packages wm)
               #:use-module (gnu home-services)
               #:use-module (gnu services configuration)
               #:use-module (dwl-guile utils)
               #:use-module (dwl-guile defaults)
               #:use-module (dwl-guile transforms)
               #:use-module (dwl-guile configuration)
               #:export (home-dwl-guile-service-type
                          home-dwl-guile-configuration)

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

                            %layout-default
                            %layout-monocle
                            %layout-floating

                            %base-buttons
                            %base-layouts
                            %base-monitor-rules))

; dwl service type configuration
(define-configuration
  home-dwl-guile-configuration
  (package
    (package dwl)
    "dwl package to use")
  (config
    (dwl-config (dwl-config))
    "dwl configuration")
  (no-serialization))

(define (home-dwl-guile-profile-service config)
  (list (home-dwl-guile-configuration-package config)))

; TODO: Update command to restart dwl rather than printing the config
(define (home-dwl-guile-on-change-service config)
  `(("files/config/dwl/config.scm"
     ,#~(system* "cat" "/home/fredrik/.config/dwl/config.scm"))))

; TODO: Respect XDG configuration
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
          home-files-service-type
          home-dwl-guile-files-service)
        (service-extension
          home-run-on-change-service-type
          home-dwl-guile-on-change-service)))
    (compose concatenate)
    (default-value (home-dwl-guile-configuration))
    (description "Configure and install dwl")))

; Custom dwl config
; (define config
;   (dwl-config
;     (border-px 2)
;     (tags
;       (list "1" "2" "3" "4" "5"))
;     (colors
;       (dwl-colors
;         (root '(0.4 0.4 0.4 1))))
;     (rules
;       (list
;         (dwl-rule
;           (id "firefox")
;           (tag 4))
;         (dwl-rule
;           (id "tidal")
;           (tag 5))))
;     (monitor-rules
;       (append
;         (list
;           (dwl-monitor-rule
;             (name "eDP-1")
;             (layout "monocle")
;             (transform FLIPPED-90)
;             (x 1920)
;             (y -10)))
;         %base-monitor-rules))
;     (xkb-rules
;       (dwl-xkb-rule
;         (layouts '("us" "se"))
;         (options '("grp:alt_shift_toggle" "grp_led:caps" "caps:escape"))))
;     (keys
;       (list
;         (dwl-key
;           (modifiers
;             (list SUPER SHIFT))
;           (key "p")
;           (action #~(test-func "action 1")))
;         (dwl-key
;           (modifiers
;             (list SUPER ALT))
;           (key "Return"))))
;     (tag-keys
;       (dwl-tag-keys
;         (keys
;           '(("1" . 1)
;             ("2" . 2)
;             ("3" . 3)
;             ("4" . 4)
;             ("5" . 5)))))))
