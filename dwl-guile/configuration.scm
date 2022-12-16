(define-module (dwl-guile configuration)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (gnu system keyboard)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages terminals)
  #:use-module (dwl-guile utils)
  #:use-module (dwl-guile configuration records)
  #:use-module (dwl-guile configuration default-config)
  #:re-export (
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
               dwl-colors-text
               dwl-colors-fullscreen

               dwl-rule
               dwl-rule?
               <dwl-rule>)
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
            dwl-config-default-alpha
            dwl-config-border-px
            dwl-config-repeat-rate
            dwl-config-repeat-delay
            dwl-config-terminal
            dwl-config-menu
            dwl-config-acceleration-speed
            dwl-config-acceleration-profile
            dwl-config-tap-to-click?
            dwl-config-tap-and-drag?
            dwl-config-drag-lock?
            dwl-config-natural-scrolling?
            dwl-config-disable-while-typing?
            dwl-config-left-handed?
            dwl-config-middle-button-emulation?
            dwl-config-send-events-mode
            dwl-config-scroll-method
            dwl-config-click-method
            dwl-config-button-map
            dwl-config-sloppy-focus?
            dwl-config-bypass-surface-visibility?
            dwl-config-smart-borders?
            dwl-config-smart-gaps?
            dwl-config-gaps-horizontal-inner
            dwl-config-gaps-horizontal-outer
            dwl-config-gaps-vertical-inner
            dwl-config-gaps-vertical-outer
            dwl-config-documentation))

;; Predicates
(define (list-of-keys? lst) (every dwl-key? lst))
(define (list-of-rules? lst) (every dwl-rule? lst))
(define (list-of-buttons? lst) (every dwl-button? lst))
(define (list-of-layouts? lst) (every dwl-layout? lst))
(define (list-of-monitor-rules? lst) (every dwl-monitor-rule? lst))
(define (maybe-xkb-configuration? val)
  (or (or (dwl-xkb-rule? val) (keyboard-layout? val))
      (not val)))

;; Base configuration
(define-configuration
  dwl-config
  (sloppy-focus?
   (boolean #t)
   "If focus should follow mouse.")
  (bypass-surface-visibility?
   (boolean #f)
   "If enabled, idle inhibitors will disable idle tracking even if its surface
is not visible.")
  (acceleration-speed
    (number 0.0)
    "Acceleration speed for the mouse/trackpad.")
  (acceleration-profile
   (symbol 'ACCEL-PROFILE-ADAPTIVE)
   "Acceleration method for mouse/trackpad.")
  (tap-to-click?
   (boolean #f)
   "If tapping should be interpreted as a click.")
  (tap-and-drag?
   (boolean #f)
   "If dragging should be possible for tapping.")
  (drag-lock?
   (boolean #t)
   "Unknown.")
  (natural-scrolling?
   (boolean #f)
   "If the trackpad should have natural scrolling.")
  (disable-while-typing?
   (boolean #f)
   "If the trackpad should be disabled while typing.")
  (left-handed?
   (boolean #f)
   "If left handed mode should be enabled.")
  (middle-button-emulation?
   (boolean #f)
   "If middle button emulations should be enabled.")
  (send-events-mode
   (symbol 'SEND-EVENTS-ENABLED)
   "Send events mode.")
  (scroll-method
   (symbol 'SCROLL-2FG)
   "Scroll method.")
  (click-method
   (symbol 'CLICK-METHOD-BUTTON-AREAS)
   "Click method.")
  (button-map
   (symbol 'TAP-MAP-LRM)
   "Button map.")
  (border-px
   (number 1)
   "Border width of windows in pixels.")
  (repeat-rate
   (number 50)
   "Keyboard repeat rate on hold.")
  (repeat-delay
   (number 300)
   "Keyboard repeat start delay.")
  (terminal
   (start-parameters `(,(file-append foot "/bin/foot")))
   "Default terminal application to use. Will be used when calling @code{dwl:spawn-terminal}.")
  (menu
   (start-parameters `(,(file-append bemenu "/bin/bemenu")))
   "Default menu application to use. Will be used when calling @code{dwl:spawn-menu}.")
  (tags
   (list-of-strings '("1" "2" "3" "4" "5" "6" "7" "8" "9"))
   "List of tag names that may be shown in the bar.")
  (colors
   (dwl-colors (dwl-colors))
   "Default colors of elements, e.g. background, border and focus.")
  (layouts
   (list-of-layouts %dwl-base-layouts)
   "List of layouts that should be available. A layout can be selected using @code{dwl:set-layout <id>}.")
  (rules
   (list-of-rules '())
   "List of application rules.")
  (monitor-rules
   (list-of-monitor-rules %dwl-base-monitor-rules)
   "List of monitor rules.")
  (xkb-rules
   (maybe-xkb-configuration #f)
   "XKB rules and options. Allowed values are @code{dwl-xkb-rule} and @code{keyboard-layout}.")
  (keys
   (list-of-keys %dwl-base-keys)
   "List of keybindings.")
  (tty-keys
   (list-of-keys %dwl-base-tty-keys)
   "List of keys that should be used to switch tty's. By default, Alt+Ctrl+F1-F12 will be bound.")
  (tag-keys
   (dwl-tag-keys (dwl-tag-keys))
   "Automatically generate all the necessary keybindings for managing tags. Similar to @code{TAGKEYS} macro in dwl.")
  (buttons
   (list-of-buttons %dwl-base-buttons)
   "List of mouse button bindings, e.g. resizing or moving windows.")
  (default-alpha
    (number 1.0)
    "Default transparency (0-1) for windows.")
  (smart-borders?
   (boolean #t)
   "Hide borders if there is only one window.")
  (smart-gaps?
   (boolean #t)
   "Remove gaps if there is only one window.")
  (gaps-horizontal-inner
   (number 10)
   "Inner horizontal gaps between windows.")
  (gaps-horizontal-outer
   (number 10)
   "Outer horizontal gaps between windows.")
  (gaps-vertical-inner
   (number 10)
   "Inner vertical gaps between windows.")
  (gaps-vertical-outer
   (number 10)
   "Outer vertical gaps between windows.")
  (no-serialization))

(define (dwl-config-documentation)
  (generate-documentation
   `((dwl-config ,dwl-config-fields))
   'dwl-config))
