#lang scribble/rhombus/manual
@(import: "common.rhm" open)

@title{Annotations}

@doc(
  operator (expr :: annotation) :: annotation
){

 Checks that the value of @rhombus(expr) satisifies
 @rhombus(annotation), and returns the value if so.

@examples(
  [1, 2, 3] :: List
)

}

@doc(
  bind.macro '$binding :: $annotation'
){

 Binds the same as @rhombus(binding), but first checks that the value to
 be bound satisfies @rhombus(annotation).

@examples(
  def x :: List: [1, 2, 3]
)

}

@doc(
  annot.macro 'Any'
){

  Matches any value.

}

@doc(
  operator (arg :~ annotation) :: annotation
){

 Associates static information to the overall expression the same as
 @rhombus(::), but performs no run-time check on the value of
 @rhombus(expr).

@examples(
  [1, 2, 3] :~ List
  "oops" :~ List
)

}

@doc(
  bind.macro '$binding :~ $annotation'
){

 Associates static information to @rhombus(binding) the same as
 @rhombus(::, ~bind), but performs no run-time check.

@examples(
  def x :~ List: [1, 2, 3]
  def x :~ List: "oops"
)

}


@doc(
  expr.macro '$expr is_a $annotation'
){

 Produces @rhombus(#true) if the value of @rhombus(expr)
 satisfies @rhombus(annotation), @rhombus(#false) otherwise.

@examples(
  [1, 2, 3] is_a List
  "oops" is_a List
)

}

@doc(
  annot.macro 'matching($binding)'
){

 Converts @rhombus(binding) into an annotation. Variables bound in
 @rhombus($binding) are not made visible, but the annotation
 corresponds to the set of values for which @rhombus(binding) would
 match.

@examples(
  def x :: matching([_, 10]): [9, 10]
  ~error: def y :: matching([_, 10]): [9, 11]
)

}

@doc(
  annot.macro 'Maybe($annotation)'
){

 An annotation that is satisfied by either @rhombus(#false) or a value
 that satisfies @rhombus(annotation).

@examples(
  #false :: Maybe(String)
  "string" :: Maybe(String)
  ~error:
    #true :: Maybe(String)
)

}
