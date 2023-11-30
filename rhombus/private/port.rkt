#lang racket/base
(require (for-syntax racket/base)
         "provide.rkt"
         "name-root.rkt"
         (submod "annotation.rkt" for-class)
         (submod "string.rkt" static-infos)
         "function-arity-key.rkt"
         "define-arity.rkt"
         "static-info.rkt"
         (submod "define-arity.rkt" for-info))

(provide (for-spaces (rhombus/annot
                      rhombus/namespace)
                     Port))

(define-annotation-syntax Port (identifier-annotation #'port? #'()))

(define-name-root Port
  #:fields
  (Input
   Output
   ;; TEMP see `Input` and `Output`
   [current_input current-input-port]
   [current_output current-output-port]
   [current_error current-error-port]
   [open_output_string Port.open_output_string]
   [get_output_string Port.get_output_string]))

(define-name-root Input
  #:fields
  ([current current-input-port]))

(define-name-root Output
  #:fields
  ([current current-output-port]
   [current_error current-error-port]))

(define-annotation-syntax Input (identifier-annotation #'input-port? #'()))
(define-annotation-syntax Output (identifier-annotation #'output-port? #'()))

(define-static-info-syntaxes (current-input-port current-output-port current-error-port)
  (#%function-arity 3)
  (#%indirect-static-info indirect-function-static-info))

(define/arity Port.open_output_string
  #:inline
  #:primitive (open-output-string)
  (case-lambda
    [() (open-output-string)]
    [(name) (open-output-string name)]))

(define/arity (Port.get_output_string port)
  #:inline
  #:primitive (get-output-string)
  #:static-infos ((#%call-result #,string-static-infos))
  (string->immutable-string (get-output-string port)))
