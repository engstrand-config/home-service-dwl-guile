(define-module (dwl-guile configuration)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (ice-9 exceptions)
               #:use-module (gnu services configuration)
               #:use-module (dwl-guile utils)
               #:use-module (dwl-guile defaults)
               #:export (
                         dwl-config
                         dwl-config?
                         <dwl-config>

                         dwl-config-keys
                         dwl-config-tags
                         dwl-config-colors
                         dwl-config-rules
                         dwl-config-layouts
                         dwl-config-buttons
                         dwl-config-tag-keys
                         dwl-config-xkb-rules
                         dwl-config-monitor-rules

                         dwl-monitor-rule
                         dwl-monitor-rule?
                         <dwl-monitor-rule>

                         dwl-xkb-rule
                         dwl-xkb-rule?
                         <dwl-xkb-rule>

                         dwl-key
                         <dwl-key>
                         dwl-key?
                         dwl-key-modifiers
                         dwl-key-key
                         dwl-key-action

                         dwl-button
                         <dwl-button>
                         dwl-button?
                         dwl-button-modifiers
                         dwl-button-button
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
                         <dwl-rule>))

; Color configuration
(define-configuration
  dwl-colors
  (root
    (rgb-color %base-root-color)
    "root color in RGBA format")
  (border
    (rgb-color %base-border-color)
    "border color in RBA format")
  (focus
    (rgb-color %base-focus-color)
    "border focus color in RGBA format")
  (no-serialization))

; Application rule configuration
(define-configuration
  dwl-rule
  (id
    (maybe-string %base-rule-id)
    "id of application")
  (title
    (maybe-string %base-title-id)
    "title of application")
  ; TODO: Allow multiple tags?
  (tag
    (number %base-tag-number)
    "tag to place application on. 1 corresponds to the first tag in the 'tags' list")
  (floating
    (boolean %base-floating-boolean)
    "if application should be floating initially")
  (monitor
    (number %base-monitor-number)
    "monitor to spawn application on")
  (no-serialization))

; https://xkbcommon.org/doc/current/structxkb__rule__names.html
(define-configuration
  dwl-xkb-rule
  (rules
    (string %base-xkb-rules)
    "the rules file to use")
  (model
    (string %base-xkb-model)
    "the keyboard model that should be used to interpret keycodes and LEDs")
  (layouts
    (list-of-strings %base-xkb-layouts)
    "a list of layouts (languages) to include in the keymap")
  (variants
    (list-of-strings %base-xkb-variants)
    "a list of layout variants, one per layout")
  (options
    (list-of-strings %base-xkb-options)
    "a list of layout options")
  (no-serialization))

; Monitor rule configuration
(define-configuration
  dwl-monitor-rule
  (name
    (maybe-string %base-monitor-name)
    "name of monitor, e.g. eDP-1")
  (master-factor
    (number %base-monitor-master-factor)
    "horizontal scaling factor for master windows")
  (number-of-masters
    (number %base-monitor-number-of-masters)
    "number of allowed windows in the master area")
  (scale
    (number %base-monitor-scale)
    "monitor scaling")
  (layout
    (string %base-monitor-layout)
    "default layout (id) to use for monitor")
  (transform
    (symbol %base-monitor-transform)
    "output transformations, e.g. rotation, reflect")
  (x
    (number %base-monitor-x)
    "position on the x-axis")
  (y
    (number %base-monitor-y)
    "position on the y-axis")
  (no-serialization))

; Keybinding configuration
(define-configuration
  dwl-key
  (modifiers
    (list-of-modifiers %base-key-modifiers)
    "list of modifiers to use for the keybinding")
  (key
    (string)
    "regular key that triggers the keybinding")
  (action
    (maybe-gexp %base-key-action)
    "gexp to call when triggered")
  (no-serialization))

; Mouse button configuration
(define-configuration
  dwl-button
  (modifiers
    (list-of-modifiers %base-button-modifiers)
    "list of modifiers to use for the button")
  (button
    (symbol)
    "mouse button to use")
  (action
    (maybe-gexp %base-button-action)
    "gexp to call when triggered")
  (no-serialization))

; Tag keybindings configuration
(define-configuration
  dwl-tag-keys
  (view-modifiers
    (list-of-modifiers %base-tag-view-modifiers)
    "modifier(s) that should be used to view a tag")
  (tag-modifiers
    (list-of-modifiers %base-tag-tag-modifiers)
    "modifier(s) that should be used to move windows to a tag")
  (toggle-view-modifiers
    (list-of-modifiers %base-tag-toggle-view-modifiers)
    "modifier(s) that should be used to toggle the visibilty of a tag")
  (toggle-tag-modifiers
    (list-of-modifiers %base-tag-toggle-tag-modifiers)
    "modifier(s) that should be used to toggle a tag for a window")
  (keys
    (list-of-tag-key-pairs
    %base-tag-keys)
    "list of key/tag pairs to generate tag keybindings for,
    e.g. '("exclam" . 1) for mapping exclamation key to tag 1")
  (no-serialization))

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
    (maybe-gexp %base-layout-arrange)
    "gexp to call when selected")
  (no-serialization))

(define (list-of-keys? lst) (every dwl-key? lst))
(define (list-of-rules? lst) (every dwl-rule? lst))
(define (list-of-buttons? lst) (every dwl-button? lst))
(define (list-of-layouts? lst) (every dwl-layout? lst))
(define (list-of-monitor-rules? lst) (every dwl-monitor-rule? lst))
(define (maybe-xkb-rule? val) (or (dwl-xkb-rule? val) (not val)))

; base configuration
(define-configuration
  dwl-config
  (sloppy-focus
    (boolean %base-config-sloppy-focus)
    "focus follows mouse")
  (border-px
    (number %base-config-border-px)
    "border pixel of windows")
  (repeat-rate
    (number %base-config-repeat-rate)
    "keyboard repeat rate on hold")
  (repeat-delay
    (number %base-config-repeat-delay)
    "keyboard repeat start delay")
  (tap-to-click
    (boolean %base-config-tap-to-click)
    "trackpad click on tap")
  (natural-scrolling
    (boolean %base-config-natural-scrolling)
    "trackpad natural scrolling")
  (terminal
    (list-of-strings %base-config-terminal)
    "terminal application to use")
  (menu
    (list-of-strings %base-config-menu)
    "menu application to use")
  (tags
    (list-of-strings %base-config-tags)
    "list of tag names")
  (colors
    (dwl-colors %base-config-colors)
    "root, border and focus colors in RGBA format, 0-255 for RGB and 0-1 for alpha")
  (layouts
    (list-of-layouts %base-layouts)
    "list of layouts to use")
  (rules
    (list-of-rules %base-config-rules)
    "list of application rules")
  (monitor-rules
    (list-of-monitor-rules %base-monitor-rules)
    "list of monitor rules")
  (xkb-rules
    (maybe-xkb-rule %base-xkb-rules)
    "xkb rules and options")
  (keys
    (list-of-keys %base-keys)
    "list of keybindings")
  (tag-keys
    (dwl-tag-keys %base-config-tag-keys)
    "tag keys configuration")
  (buttons
    (list-of-buttons %base-buttons)
    "list of mouse button keybindings, e.g. resizing or moving windows")
  (no-serialization))
