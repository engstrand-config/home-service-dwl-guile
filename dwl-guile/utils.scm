;; Contains helper procedures and syntax macros
(define-module (dwl-guile utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:export (
            hex->rgba
            remove-question-mark
            maybe-exp?
            maybe-string?
            maybe-procedure?
            keycode?
            rgba-color?
            start-parameters?
            list-of-strings?
            list-of-gexps?
            list-of-tag-key-pairs?))

;; List of available key modifiers
(define %modifiers
  '(SHIFT
    CTRL
    ALT
    SUPER))

;; General predicates
(define (maybe-exp? val) #t) ;; not sure how to check if val is an expression
(define (maybe-string? val) (or (string? val) (not val)))
(define (maybe-procedure? val) (or (procedure? val) (not val)))
(define (list-of-strings? lst) (every string? lst))
(define (list-of-gexps? lst) (every gexp? lst))
(define (start-parameters? lst) (every (lambda (v) (or (file-append? v) (string? v))) lst))

(define* (rgba-color? lst)
  "Validates the format of LST as RGBA or hex.
Hex colors must be prefixed with '#' and can have a length of 6 or 8.
RGBA format requires a length of 4, where each value is between 0 and 1."
  (if (string? lst)
      (and (or (eq? (string-length lst) 7) (eq? (string-length lst) 9))
           (equal? (string-take lst 1) "#"))
      (and (equal? (length lst) 4)
           (every (lambda (v) (and (number? v) (and (>= v 0) (<= v 1)))) lst))))

(define* (hex->rgba str)
  "Converts a hex color STR into its RGBA color representation.
If the hex color does not specify the alpha, it will default to 100%."
  (define (split-rgb acc hex)
    (if (eq? (string-length hex) 0)
        acc
        (split-rgb
         (cons (exact->inexact (/ (string->number (string-take hex 2) 16) 255)) acc)
         (string-drop hex 2))))
  (let* ((hex (substring str 1))
         (rgb (split-rgb '() hex)))
    (reverse (if (eq? (length rgb) 3) (cons 1.0 rgb) rgb))))

;; Defining tag keys requires you to specify a target tag
;; for each respective key. For example, you might want to
;; generate bindings for "exclam" to tag 1: ("exclam" . 1).
;; The first value in the pair must be a valid XKB key and the
;; second value must be a number that is within the bounds of
;; the defined tags, i.e. 1-<number of tags>.
(define (list-of-tag-key-pairs? lst)
  (every
   (lambda
       (pair)
     (and (string? (car pair)) (number? (cdr pair))))
   lst))

;; Removes the '?' from the end of a string.
;; This is used when transforming a config into an alist.
(define (remove-question-mark str)
  (string-trim-right str #\?))
