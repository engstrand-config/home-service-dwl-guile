(define-module (dwl-guile configuration)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (ice-9 exceptions)
               #:use-module (gnu services configuration)
               #:use-module (dwl-guile utils)
               #:use-module (dwl-guile defaults)
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
                         <dwl-rule>

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
                         dwl-config-monitor-rules))

; Color configuration
(define-configuration
  dwl-colors
  (root
    (rgb-color %base-root-color)
    "Root color in RGBA format.")
  (border
    (rgb-color %base-border-color)
    "Border color in RBA format.")
  (focus
    (rgb-color %base-focus-color)
    "Border focus color in RGBA format.")
  (no-serialization))

; Application rule configuration
(define-configuration
  dwl-rule
  (id
    (maybe-string %base-rule-id)
    "Id of target application for rule.")
  (title
    (maybe-string %base-rule-title-id)
    "Title of target application for rule.")
  ; TODO: Allow multiple tags?
  (tag
    (number %base-rule-tag-number)
    "Tag to place application on. 1 corresponds to the first tag in the @code{tags} list.")
  (floating
    (boolean %base-rule-floating-boolean)
    "If the application should be floating initially.")
  (monitor
    (number %base-rule-monitor-number)
    "The monitor to spawn the application on.")
  (alpha
    (number %base-rule-alpha)
    "Default window transparency (0-1) for the application. Requires the @code{%patch-alpha} patch.")
  (no-serialization))

; https://xkbcommon.org/doc/current/structxkb__rule__names.html
(define-configuration
  dwl-xkb-rule
  (rules
    (string %base-xkb-rules)
    "The rules file to use.")
  (model
    (string %base-xkb-model)
    "The keyboard model that should be used to interpret keycodes and LEDs.")
  (layouts
    (list-of-strings %base-xkb-layouts)
    "A list of layouts (languages) to include in the keymap.")
  (variants
    (list-of-strings %base-xkb-variants)
    "A list of layout variants, one per layout.")
  (options
    (list-of-strings %base-xkb-options)
    "A list of layout options.")
  (no-serialization))

; Monitor rule configuration
(define-configuration
  dwl-monitor-rule
  (name
    (maybe-string %base-monitor-name)
    "Name of monitor, e.g. eDP-1.")
  (master-factor
    (number %base-monitor-master-factor)
    "Horizontal scaling factor for master windows.")
  (masters
    (number %base-monitor-masters)
    "Number of windows that will be shown in the master area.")
  (scale
    (number %base-monitor-scale)
    "Monitor scaling.")
  (layout
    (string %base-monitor-layout)
    "Default layout (id) to use for monitor.")
  (transform
    (symbol %base-monitor-transform)
    "Monitor output transformations, e.g. rotation, reflect.")
  (x
    (number %base-monitor-x)
    "Position on the x-axis.")
  (y
    (number %base-monitor-y)
    "Position on the y-axis.")
  (no-serialization))

; Keybinding configuration
(define-configuration
  dwl-key
  (modifiers
    (list-of-modifiers %base-key-modifiers)
    "List of modifiers to use for the keybinding")
  (key
    (keycode)
    "Keycode or keysym string to use for this keybinding")
  (action
    (maybe-exp %base-key-action)
    "Expression to call when triggered.")
  (no-serialization))

; Mouse button configuration
(define-configuration
  dwl-button
  (modifiers
    (list-of-modifiers %base-button-modifiers)
    "List of modifiers to use for the button.")
  (button
    (symbol)
    "Mouse button to use for this binding.")
  (action
    (maybe-exp %base-button-action)
    "Expression to call when triggered.")
  (no-serialization))

; Tag keybindings configuration
(define-configuration
  dwl-tag-keys
  (view-modifiers
    (list-of-modifiers %base-tag-view-modifiers)
    "Modifier(s) that should be used to view a tag.")
  (tag-modifiers
    (list-of-modifiers %base-tag-tag-modifiers)
    "Modifier(s) that should be used to move windows to a tag.")
  (toggle-view-modifiers
    (list-of-modifiers %base-tag-toggle-view-modifiers)
    "Modifier(s) that should be used to toggle the visibilty of a tag.")
  (toggle-tag-modifiers
    (list-of-modifiers %base-tag-toggle-tag-modifiers)
    "Modifier(s) that should be used to toggle a tag for a window.")
  (keys
    (list-of-tag-key-pairs
      %base-tag-keys)
    "List of key/tag pairs to generate tag keybindings for,
  e.g. @code{("1" . 1)} for mapping the key "1" to tag 1.
  The first value of the pair should be a valid keycode or keysym.")
  (no-serialization))

; Layout configuration
(define-configuration
  dwl-layout
  (id
    (string)
    "Id that can be used to reference a layout in your config, e.g. in a monitor rule.")
  (symbol
    (string)
    "Symbol that should be shown when layout is active.")
  (arrange
    (maybe-exp %base-layout-arrange)
    "Expression to call when layout is selected.")
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
    "If focus should follow mouse.")
  (border-px
    (number %base-config-border-px)
    "Border width of windows in pixels.")
  (repeat-rate
    (number %base-config-repeat-rate)
    "Keyboard repeat rate on hold.")
  (repeat-delay
    (number %base-config-repeat-delay)
    "Keyboard repeat start delay.")
  (tap-to-click
    (boolean %base-config-tap-to-click)
    "If tapping on the trackpad should be interpreted as a click.")
  (natural-scrolling
    (boolean %base-config-natural-scrolling)
    "If the trackpad should have natural scrolling.")
  (terminal
    (list-of-strings %base-config-terminal)
    "Default terminal application to use. Will be used when calling @code{dwl:spawn-terminal}.")
  (menu
    (list-of-strings %base-config-menu)
    "Default menu application to use. Will be used when calling @code{dwl:spawn-menu}.")
  (tags
    (list-of-strings %base-config-tags)
    "List of tag names that may be shown in the bar.")
  (colors
    (dwl-colors %base-config-colors)
    "Default colors of elements, e.g. background, border and focus.")
  (layouts
    (list-of-layouts %base-config-layouts)
    "List of layouts that should be available. A layout can be selected using @code{dwl:set-layout <id>}")
  (rules
    (list-of-rules %base-config-rules)
    "List of application rules.")
  (monitor-rules
    (list-of-monitor-rules %base-config-monitor-rules)
    "List of monitor rules.")
  ; TODO: Allow users to pass in the system keyboard configuration?
  (xkb-rules
    (maybe-xkb-rule %base-config-xkb-rules)
    "XKB rules and options.")
  (keys
    (list-of-keys %base-config-keys)
    "List of keybindings.")
  (tag-keys
    (dwl-tag-keys %base-config-tag-keys)
    "Automatically generate all the necessary keybindings for managing tags. Similar to @code{TAGKEYS} macro in dwl.")
  (buttons
    (list-of-buttons %base-config-buttons)
    "List of mouse button bindings, e.g. resizing or moving windows.")
  (default-alpha
    (number %base-config-default-alpha)
    "Default transparency (0-1) for windows. Requires the @code{%patch-alpha} patch")
  (no-serialization))
