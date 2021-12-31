(define-module (dwl-guile configuration records)
  #:use-module (srfi srfi-1)
  #:use-module (gnu services configuration)
  #:use-module (dwl-guile utils)
  #:export (
            dwl-monitor-rule
            dwl-monitor-rule?
            <dwl-monitor-rule>

            dwl-xkb-rule
            dwl-xkb-rule?
            <dwl-xkb-rule>

            dwl-key
            <dwl-key>
            dwl-key?
            dwl-key-key
            dwl-key-action

            dwl-button
            <dwl-button>
            dwl-button?
            dwl-button-key
            dwl-button-action

            dwl-tag-keys
            <dwl-tag-keys>
            dwl-tag-keys?
            dwl-tag-keys-keys
            dwl-tag-keys-fields
            dwl-tag-keys-view-modifiers
            dwl-tag-keys-tag-modifiers
            dwl-tag-keys-toggle-view-modifiers
            dwl-tag-keys-toggle-tag-modifiers

            dwl-layout
            dwl-layout?
            <dwl-layout>
            dwl-layout-id
            dwl-layout-symbol
            dwl-layout-arrange

            dwl-colors
            dwl-colors?
            <dwl-colors>
            dwl-colors-root
            dwl-colors-border
            dwl-colors-focus

            dwl-rule
            dwl-rule?
            <dwl-rule>

            dwl-monitor-rule-documentation
            dwl-xkb-rule-documentation
            dwl-key-documentation
            dwl-button-documentation
            dwl-tag-keys-documentation
            dwl-layout-documentation
            dwl-colors-documentation
            dwl-rule-documentation))

;; Color configuration
(define-configuration
  dwl-colors
  (root
      (rgb-color '(0.3 0.3 0.3 1.0))
    "Root color in RGBA format.")
  (border
   (rgb-color '(0.5 0.5 0.5 1.0))
   "Border color in RGBA format.")
  (focus
   (rgb-color '(1.0 0.0 0.0 1.0))
   "Border focus color in RGBA format.")
  (text
   (rgb-color '(1.0 1.0 1.0 1.0))
   "Text color in RGBA format.")
  (no-serialization))

;; Application rule configuration
(define-configuration
  dwl-rule
  (id
   (maybe-string #f)
   "Id of target application for rule.")
  (title
   (maybe-string #f)
   "Title of target application for rule.")
  ;; TODO: Allow multiple tags?
  (tag
   (number 0)
   "Tag to place application on. 1 corresponds to the first tag in the @code{tags} list.")
  (floating?
   (boolean #f)
   "If the application should be floating initially.")
  (monitor
   (number -1)
   "The monitor to spawn the application on.")
  (alpha
   (number 0.9)
   "Default window transparency (0-1) for the application.")
  (no-swallow
   (boolean #f)
   "If true, the application will NOT be swallowed. Requires the @code{%patch-swallow} patch.")
  (terminal
   (boolean #f)
   "If true, this application can swallow child processes. Requires the @code{%patch-swallow} patch.")
  (no-serialization))

;; https://xkbcommon.org/doc/current/structxkb__rule__names.html
(define-configuration
  dwl-xkb-rule
  (rules
   (string "")
   "The rules file to use.")
  (model
   (string "")
   "The keyboard model that should be used to interpret keycodes and LEDs.")
  (layouts
   (list-of-strings '())
   "A list of layouts (languages) to include in the keymap.")
  (variants
   (list-of-strings '())
   "A list of layout variants, one per layout.")
  (options
   (list-of-strings '())
   "A list of layout options.")
  (no-serialization))

;; Monitor rule configuration
(define-configuration
  dwl-monitor-rule
  (name
   (maybe-string #f)
   "Name of monitor, e.g. eDP-1.")
  (master-factor
   (number 0.55)
   "Horizontal scaling factor for master windows.")
  (masters
   (number 1)
   "Number of windows that will be shown in the master area.")
  (scale
   (number 1)
   "Monitor scaling.")
  (layout
   (string "tile")
   "Default layout (id) to use for monitor.")
  (transform
   (symbol 'TRANSFORM-NORMAL)
   "Monitor output transformations, e.g. rotation, reflect.")
  (x
   (number 0)
   "Position on the x-axis.")
  (y
   (number 0)
   "Position on the y-axis.")
  (width
   (number 1920)
   "Monitor resolution width. Requires the @code{%patch-monitor-config} patch.")
  (height
   (number 1080)
   "Monitor resolution height Requires the @code{%patch-monitor-config} patch.")
  (refresh-rate
   (number 60)
   "Monitor refresh rate. Requires the @code{%patch-monitor-config} patch.")
  (adaptive-sync?
   (boolean #f)
   "Enable adaptive sync for monitor. Requires the @code{%patch-monitor-config} patch.")
  (no-serialization))

;; Keybinding configuration
(define-configuration
  dwl-key
  (key
    (string)
    "Emacs-like key binding string, e.g. @code{C-s-<tab>}.")
  (action
   (maybe-exp #f)
   "Expression to call when triggered.")
  (no-serialization))

;; Mouse button configuration
(define-configuration
  dwl-button
  (key
   (string)
   "Emacs-like button binding string, e.g. @code{s-<mouse-left>}.")
  (action
   (maybe-exp #f)
   "Expression to call when triggered.")
  (no-serialization))

;; Tag keybindings configuration
(define-configuration
  dwl-tag-keys
  (view-modifiers
   (string "s")
   "Modifier(s) that should be used to view a tag.")
  (tag-modifiers
   (string "S-s")
   "Modifier(s) that should be used to move windows to a tag.")
  (toggle-view-modifiers
   (string "C-s")
   "Modifier(s) that should be used to toggle the visibilty of a tag.")
  (toggle-tag-modifiers
   (string "C-S-s")
   "Modifier(s) that should be used to toggle a tag for a window.")
  (keys
   (list-of-tag-key-pairs `(("1" . 1)
                            ("2" . 2)
                            ("3" . 3)
                            ("4" . 4)
                            ("5" . 5)
                            ("6" . 6)
                            ("7" . 7)
                            ("8" . 8)
                            ("9" . 9)))
   "List of key/tag pairs to generate tag keybindings for,
  e.g. @code{("1" . 1)} for mapping the key "1" to tag 1.
  The first value of the pair should be a valid keycode or keysym.")
  (no-serialization))

;; Layout configuration
(define-configuration
  dwl-layout
  (id
   (string)
   "Id that can be used to reference a layout in your config, e.g. in a monitor rule.")
  (symbol
   (string)
   "Symbol that should be shown when layout is active.")
  (arrange
   (maybe-exp #f)
   "Expression to call when layout is selected.")
  (no-serialization))

(define (dwl-monitor-rule-documentation)
  (generate-documentation
   `((dwl-monitor-rule ,dwl-monitor-rule-fields))
   'dwl-monitor-rule))

(define (dwl-xkb-rule-documentation)
  (generate-documentation
   `((dwl-xkb-rule ,dwl-xkb-rule-fields))
   'dwl-xkb-rule))

(define (dwl-key-documentation)
  (generate-documentation
   `((dwl-key ,dwl-key-fields))
   'dwl-key))

(define (dwl-button-documentation)
  (generate-documentation
   `((dwl-button ,dwl-button-fields))
   'dwl-button))

(define (dwl-tag-keys-documentation)
  (generate-documentation
   `((dwl-tag-keys ,dwl-tag-keys-fields))
   'dwl-tag-keys))

(define (dwl-layout-documentation)
  (generate-documentation
   `((dwl-layout ,dwl-layout-fields))
   'dwl-layout))

(define (dwl-colors-documentation)
  (generate-documentation
   `((dwl-colors ,dwl-colors-fields))
   'dwl-colors))

(define (dwl-rule-documentation)
  (generate-documentation
   `((dwl-rule ,dwl-rule-fields))
   'dwl-rule))
