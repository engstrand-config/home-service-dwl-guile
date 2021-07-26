(define-module (dwl-guile transforms)
               #:use-module (srfi srfi-1)
               #:use-module (ice-9 match)
               #:use-module (ice-9 exceptions)
               #:use-module (guix gexp)
               #:use-module (dwl-guile utils)
               #:use-module (dwl-guile configuration)
               #:export (
                         arrange->exp
                         binding->exp
                         dwl-config->alist
                         configuration->alist))

; Converts an arrange procedure into a scheme expression.
(define (arrange->exp proc)
  (if
    (not proc)
    proc
    `(. (lambda (monitor) ,proc))))

; Converts a binding procedure into a scheme expression.
(define (binding->exp proc)
  (if
    (not proc)
    proc
    `(. (lambda () ,proc))))

; Converts a configuration into alist to allow the values to easily be
; fetched in C using `scm_assoc_ref(alist, key)`.
(define*
  (configuration->alist
    #:key
    (transform-value #f)
    (type #f)
    (config '())
    (source '()))
  (remove
    ; the %location field is autogenerated and is not needed
    (lambda (pair) (equal? (car pair) "%location"))
    (fold-right
      (lambda (field acc)
        (append
          (let ((value ((record-accessor type field) config)))
            `((,(symbol->string field) .
                                       ,(if (not transform-value)
                                            value
                                            (transform-value field value source)))))
          acc))
      '()
      (record-type-fields type))))

(define (transform-rule field value source)
  (match
    field
    ('tag
     (let ((tags (length (dwl-config-tags original)))
           (tag (- value 1)))
       (if
         (< tag tags)
         tag
         (raise-exception
           (make-exception-with-message
             (string-append
               "dwl: specified tag '"
               (number->string value)
               "' is out of bounds, there are only "
               (number->string tags)
               " available tags"))))))
    (_ value)))

(define (transform-layout field value source)
  (match
    field
    ('arrange (arrange->exp value))
    (_ value)))

(define (transform-binding field value source)
  (match
    field
    ('modifiers (delete-duplicates value))
    ('action (binding->exp value))
    (_ value)))

(define (transform-xkb-rule field value source)
  (match
    field
    ((or 'layouts 'variants 'options)
     (if
       (null? value)
       "" ; empty string is interpreted as NULL in `xkb_keymap_new_from_names()`
       (string-join value ",")))
    (_ value)))

(define (transform-monitor-rule field value source)
  (match
    field
    ('layout
     (let* ((layouts (dwl-config-layouts source))
            (index (list-index (lambda (l) (equal? (dwl-layout-id l) value)) layouts)))
       (match
         index
         (#f
          (raise-exception
            (make-exception-with-message
              (string-append "dwl: '" value "' is not a valid layout id"))))
         (_ index))))
    (_ value)))

(define (transform-config field value source)
  (match
    field
    ('colors (dwl-colors->alist value source))
    ('keys (map (lambda (key) (dwl-key->alist key source)) value))
    ('buttons (map (lambda (button) (dwl-button->alist button source)) value))
    ('layouts (map (lambda (layout) (dwl-layout->alist layout source)) value))
    ('rules (map (lambda (rule) (dwl-rule->alist rule source)) value))
    ('monitor-rules (map (lambda (rule) (dwl-monitor-rule->alist rule source)) value))
    ('xkb-rules (if (not value) value (dwl-xkb-rule->alist value source)))
    ('tag-keys
     (if (<= (length (dwl-config-tags source)) (length (dwl-tag-keys-keys value)))
       (dwl-tag-keys->alist value source)
       (raise-exception
         (make-exception-with-message
           "dwl: too few tag keys, not all tags can be accessed"))))
    (_ value)))

(define (dwl-colors->alist colors source)
  (configuration->alist
    #:type <dwl-colors>
    #:config colors
    #:source source))

(define (dwl-rule->alist rule source)
  (configuration->alist
    #:transform-value transform-rule
    #:type <dwl-rule>
    #:config rule
    #:source source))

(define (dwl-layout->alist layout source)
  (configuration->alist
    #:type <dwl-layout>
    #:transform-value transform-layout
    #:config layout
    #:source source))

(define (dwl-key->alist key source)
  (configuration->alist
    #:transform-value transform-binding
    #:type <dwl-key>
    #:config key
    #:source source))

(define (dwl-button->alist button source)
  (configuration->alist
    #:transform-value transform-binding
    #:type <dwl-button>
    #:config button
    #:source source))

; Transform tag keys into separate dwl-key configurations.
; This is a helper transform for generating keybindings for tag actions,
; e.g. viewing tags, moving windows, toggling visibilty of tags, etc.
; For example, a list of 9 tags will result i 9*4 keybindings.
;
; TODO: Add correct action to each generated keybinding
; TODO: Do we need to specify different bindings for those that use the shift modifier?
;       See https://github.com/djpohly/dwl/blob/3b05eadeaf5e2de4caf127cfa07642342cccddbc/config.def.h#L55
(define (dwl-tag-keys->alist value source)
  (let ((keys (dwl-tag-keys-keys value))
        (view-modifiers (dwl-tag-keys-view-modifiers value))
        (tag-modifiers (dwl-tag-keys-tag-modifiers value))
        (toggle-view-modifiers (dwl-tag-keys-toggle-view-modifiers value))
        (toggle-tag-modifiers (dwl-tag-keys-toggle-tag-modifiers value)))
    (map
      (lambda
        (parsed-key)
        (dwl-key->alist parsed-key source))
      (fold
        (lambda
          (pair acc)
          (let
            ((key (car pair))
             (tag (cdr pair))) ; currently unused until we add the actions
             (cons*
               (dwl-key
                 (modifiers view-modifiers)
                 (key key)
                 (action `(view ,key)))
               (dwl-key
                 (modifiers tag-modifiers)
                 (key key)
                 (action `(tag ,key)))
               (dwl-key
                 (modifiers toggle-view-modifiers)
                 (key key)
                 (action `(toggle-view ,key)))
               (dwl-key
                 (modifiers toggle-tag-modifiers)
                 (key key)
                 (action `(toggle-tag ,key)))
               acc)))
        '()
        keys))))

(define (dwl-xkb-rule->alist rule source)
  (configuration->alist
    #:type <dwl-xkb-rule>
    #:transform-value transform-xkb-rule
    #:config rule
    #:source source))

(define (dwl-monitor-rule->alist rule source)
  (configuration->alist
    #:type <dwl-monitor-rule>
    #:transform-value transform-monitor-rule
    #:config rule
    #:source source))

(define (dwl-config->alist config)
  (configuration->alist
    #:type <dwl-config>
    #:transform-value transform-config
    #:config config
    #:source config))
