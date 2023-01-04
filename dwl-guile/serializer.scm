(define-module (dwl-guile serializer)
  #:use-module (guix gexp)
  #:use-module (gnu services configuration)
  #:export (sexp-config? serialize-sexp-config))

;; Taken from rde:
;; https://github.com/abcdw/rde/blob/5b8605f421d0b8a9569e43cb6f7e651e7a8f7218/src/rde/serializers/lisp.scm
(define sexp-config? list?)
(define (sexp-serialize sexps)
  (define (serialize-list-element elem)
    (cond
     ((gexp? elem)
      elem)
     (else
      #~(string-trim-right
           (with-output-to-string
             (lambda ()
               ((@ (ice-9 pretty-print) pretty-print)
                '#$elem
                #:max-expr-width 79)))
           #\newline))))

  #~(string-append
     #$@(interpose
         (map serialize-list-element sexps)
         "\n" 'suffix)))

(define (serialize-sexp-config field-name sexps)
  (sexp-serialize sexps))
