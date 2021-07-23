; Defines the configuration records for dwl,
; as well as procedures for transforming the configuration
; into a format that can easily be parsed in C.
(define-module (gnu home-services dwl)
               #:use-module (guix gexp)
               #:use-module (dwl utils)
               #:use-module (dwl bindings)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (ice-9 format)
               #:use-module (ice-9 pretty-print)
               #:use-module (ice-9 exceptions)
               #:use-module (gnu packages)
               #:use-module (gnu home-services)
               #:use-module (gnu services configuration)
               #:export (
                         dwl-key
                         dwl-rule
                         dwl-layout
                         dwl-colors
                         dwl-button
                         dwl-xkb-rule
                         dwl-tag-keys
                         dwl-monitor-rule

                         %layout-default
                         %layout-monocle
                         %layout-floating

                         %base-layouts
                         %base-buttons
                         %base-monitor-rules

                         home-dwl-service-type
                         home-dwl-configuration))

; Layout configuration
(define-configuration
  dwl-layout
  (id
    (string)
    "id that can be used to reference a layout, e.g. in a monitor rule")
  (symbol
    (string)
    "symbol that should be shown when layout is active")
  (arrange
    (maybe-gexp #f)
    "gexp to call when selected")
  (no-serialization))

; Basic layouts
(define %layout-default
  (dwl-layout
    (id "default")
    (symbol "[]=")
    (arrange #~(test-func "arrange default"))))

(define %layout-monocle
  (dwl-layout
    (id "monocle")
    (symbol "[M]")
    (arrange #~(test-func "arrange monocle"))))

(define %layout-floating
  (dwl-layout
    (id "floating")
    (symbol "><>")
    (arrange #f)))

; Default layouts
(define %base-layouts
  (list %layout-default
        %layout-monocle
        %layout-floating))

; dwl color configuration
(define-configuration
  dwl-colors
  (root
    (rgb-color '(0.3 0.3 0.3 1.0))
    "root color in RGBA format")
  (border
    (rgb-color '(0.5 0.5 0.5 1.0))
    "border color in RBA format")
  (focus
    (rgb-color '(1.0 0.0 0.0 1.0))
    "border focus color in RGBA format")
  (no-serialization))

; Application rule configuration
(define-configuration
  dwl-rule
  (id
    (maybe-string #f)
    "id of application")
  (title
    (maybe-string #f)
    "title of application")
  (tag
    (number 1)
    "tag to place application on. 1 corresponds to the first tag in the 'tags' list")
  (floating
    (boolean #f)
    "if application should be floating initially")
  (monitor
    (number 1)
    "monitor to spawn application on")
  (no-serialization))

; Monitor rule configuration
(define-configuration
  dwl-monitor-rule
  (name
    (maybe-string #f)
    "name of monitor, e.g. eDP-1")
  (master-factor
    (number 0.55)
    "horizontal scaling factor for master windows")
  (number-of-masters
    (number 1)
    "number of allowed windows in the master area")
  (scale
    (number 1)
    "monitor scaling")
  (layout
    (string "default")
    "default layout (id) to use for monitor")
  (transform
    (number NORMAL)
    "output transformations, e.g. rotation, reflect")
  (x
    (number 0)
    "position on the x-axis")
  (y
    (number 0)
    "position on the y-axis")
  (no-serialization))

; XKB configuration
; https://xkbcommon.org/doc/current/structxkb__rule__names.html
(define-configuration
  dwl-xkb-rule
  (rules
    (string "")
    "the rules file to use")
  (model
    (string "")
    "the keyboard model that should be used to interpret keycodes and LEDs")
  (layouts
    (list-of-strings '())
    "a list of layouts (languages) to include in the keymap")
  (variants
    (list-of-strings '())
    "a list of layout variants, one per layout")
  (options
    (list-of-strings '())
    "a list of layout options")
  (no-serialization))

; Keybinding configuration
(define-configuration
  dwl-key
  (modifiers
    (list-of-modifiers (list MODKEY))
    "list of modifiers to use for the keybinding")
  (key
    (string)
    "regular key that triggers the keybinding")
  (action
    (maybe-gexp #f)
    "gexp to call when triggered")
  (no-serialization))

; Mouse button configuration
(define-configuration
  dwl-button
  (modifiers
    (list-of-modifiers (list MODKEY))
    "list of modifiers to use for the button")
  (button
    (number)
    "mouse button to use")
  (action
    (maybe-gexp #f)
    "gexp to call when triggered")
  (no-serialization))

; Tag keybindings configuration
(define-configuration
  dwl-tag-keys
  (view-modifiers
    (list-of-modifiers (list SUPER))
    "modifier(s) that should be used to view a tag")
  (tag-modifiers
    (list-of-modifiers (list SUPER SHIFT))
    "modifier(s) that should be used to move windows to a tag")
  (toggle-view-modifiers
    (list-of-modifiers (list SUPER CTRL))
    "modifier(s) that should be used to toggle the visibilty of a tag")
  (toggle-tag-modifiers
    (list-of-modifiers (list SUPER SHIFT CTRL))
    "modifier(s) that should be used to toggle a tag for a window")
  (keys
    (list-of-tag-key-pairs
      '(("1" . 1)
        ("2" . 2)
        ("3" . 3)
        ("4" . 4)
        ("5" . 5)
        ("6" . 6)
        ("7" . 7)
        ("8" . 8)
        ("9" . 9)))
    "list of key/tag pairs to generate tag keybindings for,
    e.g. '("exclam" . 1) for mapping exclamation key to tag 1")
  (no-serialization))

; dwl configuration type predicates
(define (list-of-tags? lst) (every string? lst))
(define (list-of-keys? lst) (every dwl-key? lst))
(define (list-of-rules? lst) (every dwl-rule? lst))
(define (list-of-buttons? lst) (every dwl-button? lst))
(define (list-of-layouts? lst) (every dwl-layout? lst))
(define (maybe-xkb-rule? val) (or (dwl-xkb-rule? val) (not val)))
(define (list-of-monitor-rules? lst) (every dwl-monitor-rule? lst))

; Default monitor rules
(define %base-monitor-rules
  (list (dwl-monitor-rule)))

; Default mouse button bindings
(define %base-buttons
  (list
    (dwl-button
      (modifiers (list SUPER))
      (button MOUSE-LEFT)
      (action #f)) ; move window
    (dwl-button
      (modifiers (list SUPER))
      (button MOUSE-MIDDLE)
      (action #f)) ; toggle floating
    (dwl-button
      (modifiers (list SUPER))
      (button MOUSE-RIGHT)
      (action #f)))) ; resize window

; dwl configuration
(define-configuration
  home-dwl-configuration
  (sloppy-focus
    (number 1)
    "focus follows mouse")
  (border-px
    (number 1)
    "border pixel of windows")
  (repeat-rate
    (number 50)
    "keyboard repeat rate on hold")
  (repeat-delay
    (number 300)
    "keyboard repeat start delay")
  (tap-to-click
    (number 1)
    "trackpad click on tap")
  (natural-scrolling
    (number 0)
    "trackpad natural scrolling")
  (terminal
    (string "st")
    "terminal application to use")
  (menu
    (string "bemenu")
    "menu application to use")
  (tags
    (list-of-tags
      (list "1" "2" "3" "4" "5" "6" "7" "8" "9"))
    "list of tag names")
  (colors
    (dwl-colors (dwl-colors))
    "root, border and focus colors in RGBA format, 0-255 for RGB and 0-1 for alpha")
  (layouts
    (list-of-layouts %base-layouts)
    "list of layouts to use")
  (rules
    (list-of-rules '())
    "list of application rules")
  (monitor-rules
    (list-of-monitor-rules %base-monitor-rules)
    "list of monitor rules")
  (xkb-rules
    (maybe-xkb-rule #f)
    "xkb rules and options")
  (keys
    (list-of-keys '())
    "list of keybindings")
  (tag-keys
    (dwl-tag-keys (dwl-tag-keys))
    "tag keys configuration")
  (buttons
    (list-of-buttons %base-buttons)
    "list of mouse button keybindings, e.g. resizing or moving windows")
  (no-serialization))

; Value transforms
(define (transform-monitor-rule field value original)
  (match
    field
    ('layout
     (let* ((layouts (home-dwl-configuration-layouts original))
            (index (list-index (lambda (l) (equal? (dwl-layout-id l) value)) layouts)))
       (match
         index
         (#f
          (raise-exception
            (make-exception-with-message
              (string-append value " is not a valid layout id"))))
         (_ index))))
    (_ value)))

(define (transform-procedure proc)
  (if
    (not proc)
    proc
    (gexp->approximate-sexp #~(. ,(lambda () #$proc)))))

(define (transform-layout field value original)
  (match
    field
    ('arrange (transform-procedure value))
    (_ value)))

(define (transform-key-or-button field value original)
  (match
    field
    ('modifiers (delete-duplicates value))
    ('action (transform-procedure value))
    ('key
     (if
       (xkb-key? value)
       value
       (raise-exception
         (make-exception-with-message
           (string-append value " is not a valid XKB key")))))
    (_ value)))

(define (transform-rule field value original)
  (match
    field
    ('tag
     (let ((tags (length (home-dwl-configuration-tags original)))
           (tag (- value 1)))
       (if
         (< tag tags)
         tag
         (raise-exception
           (make-exception-with-message
             (string-append
               "specified tag ("
               (number->string value)
               ") is out of bounds, there are only "
               (number->string tags)
               " available tags"))))))
    (_ value)))

(define (transform-xkb-rule field value original)
  (match
    field
    ((or 'layouts 'variants 'options)
     (if
       (null? value)
       "" ; empty string is interpreted as NULL in `xkb_keymap_new_from_names()`
       (string-join value ",")))
    (_ value)))

; Transform tag keys into separate dwl-key configurations.
; This is a helper transform for generating keybindings for tag actions,
; e.g. viewing tags, moving windows, toggling visibilty of tags, etc.
; For example, a list of 9 tags will result i 9*4 keybindings.
;
; TODO: Add correct action to each generated keybinding
; TODO: Do we need to specify different bindings for those that use the shift modifier?
;       See https://github.com/djpohly/dwl/blob/3b05eadeaf5e2de4caf127cfa07642342cccddbc/config.def.h#L55
(define (transform-tag-keys value original)
  (let ((keys (dwl-tag-keys-keys value))
        (view-modifiers (dwl-tag-keys-view-modifiers value))
        (tag-modifiers (dwl-tag-keys-tag-modifiers value))
        (toggle-view-modifiers (dwl-tag-keys-toggle-view-modifiers value))
        (toggle-tag-modifiers (dwl-tag-keys-toggle-tag-modifiers value)))
    (map
      (lambda
        (parsed-key)
        (transform-config
          #:transform-value transform-key-or-button
          #:type <dwl-key>
          #:config parsed-key
          #:original-config original))
      (fold
        (lambda
          (pair acc)
          (let
            ((key (car pair))
             (tag (cdr pair)) ; currently unused until we add the actions
             (tags (length (home-dwl-configuration-tags original))))
            (if
              (<= tag tags)
              (cons*
                (dwl-key
                  (modifiers view-modifiers)
                  (key key)
                  (action #f))
                (dwl-key
                  (modifiers tag-modifiers)
                  (key key)
                  (action #f))
                (dwl-key
                  (modifiers toggle-view-modifiers)
                  (key key)
                  (action #f))
                (dwl-key
                  (modifiers toggle-tag-modifiers)
                  (key key)
                  (action #f))
                acc)
              (raise-exception
                (make-exception-with-message
                  (string-append
                    "specified target tag ("
                    (number->string tag)
                    ") in tag key is out of bounds, there are only "
                    (number->string tags)
                    " available tags"))))))
        '()
        keys))))

; Apply conditional transformations to singular
; values inside the root dwl configuration.
(define (transform-config-value field value original)
  (match
    field
    ('colors
     (transform-config
       #:type <dwl-colors>
       #:config value
       #:original-config original))
    ('keys
     (map
       (lambda
         (key)
         (transform-config
           #:transform-value transform-key-or-button
           #:type <dwl-key>
           #:config key
           #:original-config original))
       value))
    ('tag-keys
     (if
       (<=
         (length (home-dwl-configuration-tags original))
         (length (dwl-tag-keys-keys value)))
       (transform-tag-keys value original)
       (raise-exception
         (make-exception-with-message
           "too few tag keys, not all tags can be accessed"))))
    ('buttons
     (map
       (lambda
         (button)
         (transform-config
           #:transform-value transform-key-or-button
           #:type <dwl-button>
           #:config button
           #:original-config original))
       value))
    ('layouts
     (map
       (lambda
         (layout)
         (transform-config
           #:transform-value transform-layout
           #:type <dwl-layout>
           #:config layout
           #:original-config original))
       value))
    ('rules
     (map
       (lambda
         (rule)
         (transform-config
           #:type <dwl-rule>
           #:transform-value transform-rule
           #:config rule
           #:original-config original))
       value))
    ('monitor-rules
     (map
       (lambda
         (monitor-rule)
         (transform-config
           #:transform-value transform-monitor-rule
           #:type <dwl-monitor-rule>
           #:config monitor-rule
           #:original-config original))
       value))
    ('xkb-rules
     (if
       (not value)
       value
       (transform-config
         #:transform-value transform-xkb-rule
         #:type <dwl-xkb-rule>
         #:config value
         #:original-config original)))
    (_ value)))

; Transforms a record into alist to allow the values to easily be
; fetched via C using `scm_assoc_ref(alist, key)`.
(define*
  (transform-config
    #:key
    (transform-value transform-config-value)
    (type #f)
    (config '())
    (original-config '()))
  (remove
    ; the %location field is autogenerated and is not needed
    (lambda (pair) (equal? (car pair) "%location"))
    (fold-right
      (lambda (field acc)
        (append
          (let ((accessor ((record-accessor type field) config)))
            `((,(symbol->string field) . ,(transform-value field accessor original-config))))
          acc))
      '()
      (record-type-fields type))))

; TODO: Allow the user to specify a custom dwl package in the home-dwl-configuration.
;       Modify the package definition dynamically to apply the guile patch?
(define (home-dwl-profile-service config)
  (list (specification->package "dwl")))

; TODO: Update command to restart dwl rather than printing the config
(define (home-dwl-on-change-service config)
  `(("files/config/dwl/config.scm"
     ,#~(system* "cat" "/home/fredrik/.config/dwl/config.scm"))))

(define (home-dwl-files-service config)
  `(("config/dwl/config.scm"
     ,(scheme-file
        "dwl-config.scm"
        #~(define config
            `(#$@(transform-config
                   #:transform-value transform-config-value
                   #:type <home-dwl-configuration>
                   #:config config
                   #:original-config config)))))))

(define home-dwl-service-type
  (service-type
    (name 'home-dwl)
    (extensions
      (list
        (service-extension
          home-profile-service-type
          home-dwl-profile-service)
        (service-extension
          home-files-service-type
          home-dwl-files-service)
        (service-extension
          home-run-on-change-service-type
          home-dwl-on-change-service)))
    (compose concatenate)
    (default-value (home-dwl-configuration))
    (description "Configure and install dwl")))

; Custom dwl config
; (define dwl-config
;   (home-dwl-configuration
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
