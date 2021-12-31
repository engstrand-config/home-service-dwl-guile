;; Contains helper procedures and syntax macros
(define-module (dwl-guile utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:export (
            remove-question-mark
            maybe-exp?
            maybe-string?
            maybe-procedure?
            keycode?
            rgb-color?
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

;; Validates the format of an RGBA list, e.g.
;; '(0.2 0.5 0.6 1.0). Only values between 0-1 are allowed
;; and no more than 4 elements may be present.
(define (rgb-color? lst)
  (and
   (equal? (length lst) 4)
   (every
    (lambda (v) (and (number? v) (and (>= v 0) (<= v 1))))
    lst)))

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
