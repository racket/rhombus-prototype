#lang racket/base
(require (for-syntax racket/base
                     syntax/parse)
         syntax/parse
         "syntax-local.rkt"
         "private/transform.rkt"
         "hier-name-parse.rkt"
         "private/name-path-op.rkt"
         "private/check.rkt")

;; Degenerate variant of enforestation with only prefix operators that
;; must consume the full group, but also with the opportinuty consume
;; subsequent groups

(provide sequence-transformer?
         sequence-transformer-proc
         sequence-transformer

         define-sequence-transform)

(struct sequence-transformer (proc))

(define-syntax (define-sequence-transform stx)
  (syntax-parse stx
    [(_ (~alt (~optional (~seq #:syntax-class form)
                         #:defaults ([form #':form]))
              (~optional (~seq #:predicate form?)
                         #:defaults ([form? #'#f]))
              (~optional (~seq #:desc form-kind-str)
                         #:defaults ([form-kind-str "form"]))
              (~optional (~seq #:in-space in-space)
                         #:defaults ([in-space #'values]))
              (~optional (~seq #:name-path-op name-path-op)
                         #:defaults ([name-path-op #'name-path-op]))
              (~optional (~seq #:transformer-ref transformer-ref)
                         #:defaults ([transformer-ref #'transformer-ref]))
              (~optional (~seq #:check-result check-result)
                         #:defaults ([check-result #'check-is-syntax])))
        ...)
     #`(begin
         (define-splicing-syntax-class form
           (pattern (~seq ((~datum group) . (~var hname (:hier-name-seq values name-path-op))) tail-in (... ...))
                    #:do [(define head-id #'hname.name)]
                    #:do [(define t (syntax-local-value* (in-space head-id) transformer-ref))]
                    #:when t
                    #:do [(define-values (parsed tail)
                            (apply-sequence-transformer t head-id
                                                        (datum->syntax #f (cons head-id #'hname.tail))
                                                        #'(tail-in (... ...))
                                                        check-result))]
                    #:attr parsed parsed
                    #:attr tail tail))
         #,@(if (syntax-e #'form?)
                #`((define (form? e)
                     (syntax-parse e
                       [((~datum group) . (~var hname (:hier-name-seq values name-path-op)))
                        (and (syntax-local-value* (in-space #'hname.name) transformer-ref)
                             #t)]
                       [_ #f])))
                '()))]))

(define (apply-sequence-transformer t id stx tail checker)
  (define proc (sequence-transformer-proc t))
  (call-as-transformer
   id
   (lambda (in out)
     (define-values (forms new-tail) (proc (in stx) (in tail)))
     (check-transformer-result (out (datum->syntax #f (checker forms proc)))
                               (out new-tail)
                               proc))))