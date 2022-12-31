#lang scribble/acmart @acmthm

@require[scribble/manual
         scribble-math
         latex-utils/scribble/theorem
         latex-utils/scribble/utils
         scriblib/footnote
         scriblib/autobib]

@define-footnote[my-note make-my-note]

@(use-mathjax)

@(define-cite ~cite citet generate-bibliography #:style number-style)

@title{Primitive Equality Predicates}

@table-of-contents[]

@section{Status}

@bold{NOTE}: This proposal is a draft and is not up to date with the current state of equality predicates in Rhombus. See @hyperlink["https://github.com/racket/racket/pull/4236"]{Add equal-always? with gen:equal-mode+hash}.

@section{Proposal}

This proposal considers two different options for structuring primitive equality predicates in a language.

@section{Option A: Single Primitive Predicate}

@code{egal?} -- billed as "the finest equality predicate [a language should provide.],"

@subsection{Numeric Comparison}

@subsubsection{Mixing Types}

@code{egal?} treats numbers with different representations as being of different types, and therefore considers them unequal even if they are numerically equal. For instance, @code{(egal? 1 1.0)} is false. There are a few options here:

A. Accept @code{egal?}'s handling of numbers, and in cases where numeric equality is desired, employ a key function that maps the numbers to a rich type where they may be compared numerically without losing information (as would happen in the case of a conversion to a floating point representation). The following key function is one example:

@codeblock{
  (-> number? (or/c #f number?))
  (define (number->maybe-equal?-key x)
    (define (real->maybe-equal?-key x)
      (cond
        [(nan? x) #f]
        [(= +inf.0 x) +inf.0]
        [(= -inf.0 x) -inf.0]
        [else (inexact->exact x)]))
    (for/first ([r (in-value (real->maybe-equal?-key (real-part x)))]
                #:when r
                [i (in-value (real->maybe-equal?-key (real-part x)))]
                #:when i)
      (make-rectangular r i)))
}

B. Augment @code{egal?} so that the primitive equality relation @code{=} is @code{egal?} in all cases except for numbers. For numbers, they should be compared as reals (or complex numbers), that is, in a way that treats numbers with different representations as being of the *same* type, viz. reals or a similar "rich," lossless type, even though they may actually be a specific subtype such as rational or inexact. For inexact numbers, essentially, they should be converted to exact numbers prior to the comparison, similar to Racket's existing way of comparing exact and inexact numbers. In other words, the behavior for numbers with this option is probably identical with Racket's existing numeric @code{=}.

Between these two options, there are reasons to favor the former, since choosing our primitive equality relation @code{=} so that @code{1 = 1.0} is true would mean that @code{1 == 1.0} must hold for any @code{==} that we define in the language, if we are to consider only "well-defined specializations of equality" (see @seclink["Design_Constraints"]{Design Constraints}), and that means that we could never consider numbers with floating point representations as distinct from numerically equal numbers with exact representations. If this is what we want, then (B) would be fine. But if we do want to support distinguishing these, then only (A) would preserve "well-definedness."

A third option that may be a reasonable compromise would be to introduce a distinct numeric equality operator that is defined in terms of a key function on top of the primitive equality predicate. For instance, @code{.=} could mean numeric equality, employing the semantics of option (A).

@section{Option B: Two Primitive Predicates}

@code{equal-always?} + @code{business=?}

"Like @code{egal?}, @code{business=?} could be thought of as the coarsest-grained equivalence relation that doesn't ignore information that's important to working with mutable objects. And on the other side, @code{equal-always?} could be considered the finest-grained equivalence relation that doesn't reveal inconvenient truths like the distinction between values and their chaperones."

@section{Design Constraints}

@subsection{Well-defined Specializations of Equality}

Given a primitive equality relation @${=}, @${==} is a well-defined specialization of @${=} (which we can denote @${σ(==, =)}) when the following conditions hold:

@itemlist[#:style 'ordered
@item{@${a = b \implies a == b}}
@item{@${\text{not}(a == b) \implies \text{not}(a = b)}}
]

Every notion of equality supported by the language must satisfy these relations. This would have implications in particular for the definition of numeric equality.

@subsection{Equality and Order}

Notions of equality should generally be consistent with notions of order, but these needn't be ensured by the language beyond the design phase. That is, where applicable, these invariants should be upheld by the language on built-in types, but they needn't be ensured through programming checks such as contracts on user-defined types.

Wherever we expect the following relations to hold, they should be ensured by the language by design (rather than by contract):

@itemlist[#:style 'ordered
@item{@${a = b \iff a \le b \text{ and } b \le a}}
@item{@${a = b \implies \text{not}(a < b) \text{ and not } (a > b)}}
@item{@${a \le b \iff a < b \text{ or } a = b}}
]

For instance, all three of these should hold for numbers. For custom types, users could have the option of defining either @code{<} or @code{≤} depending on whether the relation excludes equality (e.g. for sets, employing the latter for @code{subset?} rather than the former).

Arguably, the third relation above should always be assumed to hold, even over user-defined types. Though, again, whether this is ensured by the language is another matter (and doing so would incur performance overhead).

@section{Extras}

Additional equality-related infrastructure may be built around the core to provide efficient and useful features in connection with the determination of equality.

TODO: Decidable equality

TODO: The difference between two values: @code{(diff a b)}

TODO: anything else?

@section{Prior Art}

@itemlist[
@item{@hyperlink["https://docs.racket-lang.org/relation/index.html"]{Generic Relations}}
@item{@hyperlink["https://docs.racket-lang.org/interconfection/index.html"]{Interconfection}}
@item{@hyperlink["https://docs.racket-lang.org/rebellion/index.html"]{Rebellion}}
]

@section{Contributors}

@itemlist[
@item{Ross "Nia" Angle}
@item{Jack Firth}
@item{Matthew Flatt}
@item{Sid Kasivajhula}
@item{Alex Knauth}
@item{Sorawee Porncharoenwase}
@item{Jens Axel Søgaard}
@item{(among others -- see the references below)}
]

@section{References}

@hyperlink["https://github.com/racket/rhombus-prototype/blob/master/design/equality-extension.rst"]{Two-level Universal Scheme for the Extension of Equality} -- The companion to the present proposal, this proposes a "two-level" scheme that can be used to safely extend and customize the predicates described in the present document.

@hyperlink["https://github.com/racket/racket/pull/4236"]{Add equal-always? with gen:equal-mode+hash} -- a PR to add the `equal-always?` predicate to Racket.

Rhombus Discussion: @hyperlink["https://github.com/racket/rhombus-prototype/issues/16"]{What do we do about equality?}

Rhombus Discussion: @hyperlink["https://github.com/racket/rhombus-prototype/issues/214"]{Generic order relations}

Rhombus Discussion: @hyperlink["https://github.com/racket/rhombus-prototype/discussions/180"]{Rhombus bi-weekly virtual meeting}

@section{Appendix: Special Cases to Handle}

@code{+nan.0} should be excluded from numeric comparison via @code{=}. It could either be treated as a distinct key type, so that NaN = NaN is true, or it could orphaned entirely from equality comparison.

@code{0.0} and @code{-0.0} should be treated as @code{0}, exactly (according to the IEEE standard). Since floating point numbers are to be converted to exact representations prior to comparison, this should be handled in a matter of course.

@code{+inf.0} and @code{-inf.0} should be equal to themselves but nothing else.

Once again, it's likely that these special cases coincide with the handling in Racket's numeric @code{=}.
