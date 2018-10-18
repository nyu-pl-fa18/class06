# Class 6

## Higher-Order Functions

In functional programming languages, functions are typically treated
as "*first-class citizens*". That is, functions may take other
functions as arguments and may again produce functions as return
values. A function that takes another function as argument is called a
*higher-order function*.

Higher-order functions provide a powerful mechanism for abstracting
over common computation patterns in programs. This mechanism is
particularly useful for designing libraries with rich interfaces
that support callbacks to client code. We will study these mechanisms
using the example of Scheme's list data type.

As a warm-up, suppose that we want to write a function `sumInts` that
takes the bounds `a` and `b` of a (half-open) interval `[a,b)` of
integer numbers and computes the sum of the values in that
interval. For example, `(sumInts 1 4)` should yield `6`. The following
recursive implementation does what we want:

```scheme
(define (sumInts a b)
  (if (< a b) 
      (+ a (sumInts (+ a 1) b))
      0))
```

Now, consider the following function `sumSqrs` that computes
the sum of the squares of the numbers in an interval `[a,b)`:

```scheme
(define (sumSqrs a b) 
  (if (< a b) 
    (+ (* a a) (sumSqrs (+ a 1) b))
    0))
```

The functions `sumInts` and `sumSqrs` are almost identical. They only
differ in the summand that is added in each recursive call. In the
case of `sumInts` it is `a`, and in the case of `sumSqrs`, it is `(* a
a)` (i.e. `a` squared). We can write a higher-order function `sum`
that abstracts from these differences. The function `sum` takes
another function `f` as additional parameter. The function `f`
captures the computation that is performed in the summand:

```scheme
(define (sum f a b) 
  (if (< a b) 
      (+ (f a) (sum f (+ a 1) b))
      0))
```

```scheme
(define (square a) (* a a))
(define (sumSqrs a b) (sum square a b))
```

Instead of defining the function `square` explicitly, we can also
provide it to `sum` as an anonymous function given by a lambda
abstraction:

```scheme
(define (sumInts a b) (sum (lambda (a) a) a b))
(define (sumSqrs a b) (sum (lambda (a) (* a a)) a b))
```

### Curried Functions

Reconsider our definition of `sumInts` and `sumSqrs` in
terms of `sum`:

```scheme
(define (sumInts a b) (sum (lambda (a) a) a b))
(define (sumSqrs a b) (sum (lambda (a) (* a a)) a b))
```

One annoyance with these definitions is that we have to redeclare the
parameters `a` and `b` which are simply passed to
`sum`. We can avoid this by redefining `sum` as a function that first
takes the function parameter `f` and then returns another function
that takes the remaining parameters `a` and `b`. This technique is
referred to as *currying*.

There are various ways to define curried functions in Scheme. One way
is to define the nested function explicitly by name using a nested
`let` declaration and then returning that function:

```scheme
(define (sum f)
  (let ((sumHelp (lambda (a b)
        (if (< a b) 
            (+ (f a) ((sum f) (+ a 1) b))
            0))))
    sumHelp))
```

Using the curried version of `sum`, the definition of `sumInts` and
`sumSqrs` can be simplified like this:

```scheme
(define sumInts (sum (lambda (a) a)))
(define sumSqrs (sum (lambda (a) (* a a))))
```

In our curried version of `sum`, the function `sumHelp`
is not recursive and is directly returned after being declared. We can
thus simplify the definition of `sum` further by turning
`sumHelp` into an anonymous function:

```scheme
(define (sum f)
  (lambda (a b)
    (if (< a b) 
        (+ (f a) ((sum f) (+ a 1) b))
        0)))
```


### Higher-Order Functions on Lists

A common use case of higher-order functions is to realize
callbacks to client code from within library functions. We discuss
this scenario using list-manipulating functions.

#### Functional Lists and Pattern Matching

Lists are one of the most important data structures in functional
programming languages. A list is a sequence of data values of some
common element type, e.g., a sequence of integer numbers
`3,6,1,2`. Unlike imperative linked lists, which you have probably
studied in your Data Structures course, lists in functional
programming languages are immutable. As with other immutable data
structures, immutable lists have the advantage that their
representation in memory can be shared across different list
instances. For example, the two lists `1,4,3` and `5,2,4,3` can share
their common sublist `4,3`. This feature enables immutable lists to be
used for space-efficient, high-level implementations of algorithms if
the data structure is used correctly. 

We have already seen that lists in Scheme can be constructed from the
empty list `'()` using the *constructor* `cons` and deconstructed
using the *destructors* `car` and `cdr`. Often, though, it is more
convenient to deconstruct lists using *pattern matching*.

A pattern matching expression in Scheme takes the form

```scheme
(match exp 
  [pat1 exp1] 
  ... 
  [patn expn])
```

The semantics of such an expression is similar to case expressions
that we discussed earlier in the course: first, `exp` is
evaluated. The result value of `exp` is then matched against the
patterns `pat1` to `patn` one at a time starting with `pat1`. The
first pattern that matches applies. For the pattern that applies, the
accompanying expression is evaluated (e.g. if `pat1` applies `exp1` is
evaluated) and the result value of that expression is the result value
of the match expression itself. If none of the patterns matches, then
the whole `match` expression fails with an exception.

Patterns are defined recursively. We will focus on the following types
of patterns. For a more comprehensive introduction
see [here](https://docs.racket-lang.org/reference/match.html).

* *variable patterns* `x`: matches any value and binds it to the name
  `x`. The scope of this binding is the expression accompanying the
  pattern.
  
* *wildcard patterns* `_`: matches any value

* *cons patterns* `(cons pat1 pat2)`: matches a value of the form
  `(cons exp1 exp2)` if `pat1` recursively matches `exp1` and `pat2`
  matches `exp2`.


For instance, the pattern `(cons hd tl)` matches
the list `'(1 2 3)`, with `hd` bound to `1` and `tl` bound to
`'(2 3)`:

```scheme
> (match '(1 2 3)
    [(cons hd tl) hd]
    ['() 0])
1
```

Here is an example where we use a `match` expression to obtain the
second element from a list `xs` (if it exists):

```scheme
(match xs
  [(cons _ (cons x _)) x])
```

and the following example only matches lists `xs` of length at least
two whose first two elements are equal and then prints that duplicate element: 

```scheme
(match xs
  [(cons x (cons x _)) (printf "found duplicate of value ~s" x)])
```

Pattern matching gives us a convenient way to define functions
that operate on lists. For example, the following function computes
the length of a list:

```scheme
(define (length xs)
  (match xs
    [(cons _ tl) (+ 1 (length tl))]
    ['() 0]))
```

The next function is more interesting, it takes two lists `l1` and
`l2` and creates a new list by concatenating `l1` and `l2`.

```scheme
(define (append xs ys)
  (match xs
    [(cons hd tl) (cons hd (append tl ys))]
    ['() ys]))
```

```scheme
> (append '(3 4 1) '(2 6))
'(3 4 1 2 6)
```

The next function reverses a given list using tail-recursion:

```scheme
(define (reverse xs)
  (letrec
      ((rev (lambda (xs rxs)
           (match xs
             [(cons hd tl) (rev tl (cons hd rxs))]
             ['() rxs]))))
    (rev xs '())))
```

```scheme
> (reverse '(3 4 1 2))
'(2 1 4 3)
```

This is how the execution of this function looks like for this example:
Function | `xs` | `rxs`
--- | ---- | ---
`reverse` | `'(3 4 1 2)` | -
`rev` | `'(3 4 1 2)` | `'()`
`rev` | `'(4 1 2)` | `'(3)`
`rev` | `'(1 2)` | `'(4 3)`
`rev` | `'(2)` | `'(1 4 3)`
`rev` | `'()` | `'(2 1 4 3)`


Here is a function that uses a more complex nested pattern to remove
all consecutive duplicate elements that occur in a list `xs`:

```scheme
(define (removeDuplicates xs)
  (match xs
    [(cons hd (cons hd tl)) (removeDuplicates (cons hd tl))]
    [(cons hd tl) (cons hd (removeDuplicates tl))]
    ['() '()]))
```

Note how the implementation of `removeDuplicates` uses the pattern
`(cons hd (cons hd tl))` to match a list `xs` of length at least two
in which the first two elements are identical.

```scheme
> (removeDuplicates '(1 1 1 3 3 1 2 2 2 4))
'(1 3 1 2 4)
```


#### The `map` function

In the earlier examples we saw that functions operating on lists
follow a common pattern: they traverse the list, decomposing it into
its elements, and then apply some operation to each of the
elements. We can extract these common patterns and implement them in
more general higher-order functions that abstract from the specific
operations being performed on the elements.

A particularly common operation on lists is to traverse a list and
apply some function to each element, obtaining a new list. For
example, suppose we have a list of numbers that we want to scale by a
given factor to obtain a list of scaled values. The following function
implements this operation:

```scheme
(define (scale factor xs)
  (match xs
    [(cons hd tl) (cons (* factor hd) (scale factor tl))]
    ['() '()]))
```

A similar operation is implemented by the following function, which
takes a list of numbers and increments each element to obtain a new
list:

```scheme
(define (incr xs)
  (match xs
    [(cons hd tl) (cons (+ hd 1) (incr xs))]
    ['() '()]))
```

The type of operation that is performed by `scale` and
`incr` is called a `map`. We can implement the map
operation as a higher-order function that abstracts from the concrete
operation that is applied to each element in the list:

```scheme
(define (map op)
  (lambda (xs)
    (match xs
      [(cons hd tl) (cons (op hd) ((map op) tl))]
      ['() '()])))
```

The `map` function transforms the input list `xs` by applying an
operation `op` to each element in `xs`. Note that the order of the
elements in the input list is preserved.

We can now redefine `scale` and `incr` as instances of `map`:
```scheme
(define (scale factor) (map (lambda (x) (* factor x))))
(define incr (map (lambda (x) (+ x 1))))
```

Note that Scheme's standard library has a predefined `map` function
that generalizes our implementation from the case where we apply a unary
operation to a single list to the case where we apply an *n*-ary
operation to *n* lists.

For instance, using the predefined `map` function, we can compute the
pairwise sum of two lists `'(1 2 3)` and `'(4 5 6)` by mapping the
binary `+` operator over them:

```scheme
> (map + '(1 2 3) '(4 5 6))
'(5 7 9)
```

#### Folding Lists

We have seen that we can often identify common patterns in functions
on data structures and implement them in generic higher-order
functions. We can then conveniently reuse these generic functions,
reducing the amount of code we have to write. In this section, we will
look at the most general patterns for performing operations on
lists, namely *fold operations*.

As a motivating example, consider the following function, which
computes the sum of the values stored in a list of integers

```scheme
(define (sumList xs)
  (match xs
    [(cons hd tl) (+ hd (sumList tl))]
    ['() 0]))
```

Consider a list `xs` of `n` integer values `d1` to `dn`:

```scheme
'(d1 d2 ... dn)
```

Then unrolling the recursion of `sum` on `xs` yields the
following computation

```scheme
(+ d1 (+ d2 (+ ... (+ d2 0)...)))
```
That is, in the `i`-th recursive call, we add the current head `di` to
the sum of the values in the current tail. Here, we consider the sum
of an empty list `'()` to be `0`. If we represent this
computation as a tree, this tree looks as follows:

```scheme
      +
     / \
    d1  +
       / \
      d2 ... 
           \
            +
           / \
          dn  0
```

With this representation, it is easy to see how to generalize from the
specific computation performed by the represented expression. That is,
in the general case, instead of adding the current head to the sum of
the current tail of the list, we apply a generic operation `op` in
each step that combines the current head with the result of the
recursive computation on the tail. Moreover, instead of starting with
the specific initial value `0` for the empty list, we are given an
initial zero value `z`.  The resulting expanded recursive computation
is then represented by the following tree:

```scheme
      op
     / \
    d1  op
       / \
      d2 ... 
           \
            op
           / \
          dn  z
```
 
or using Scheme syntax, by the expression

```scheme
(op d1 (op d2 (... (op dn z) ...)))
```

We refer to this type of computation as a *fold* of the list
because the list is traversed and recursively folded into a single
value. Note that the tree is leaning towards the right. We therefore
refer to this type of fold operation as a *fold-right*. That is,
the recursive computation is performed in right-to-left order of the
values stored in the list.

The following higher-order function implements the fold-right operation:
```scheme
(define (foldr op z)
  (lambda (xs)
    (match xs
      [(cons hd tl) (op hd ((foldr op z) tl))]
      ['() z])))
```

We can now redefine `sumList` in terms of `foldr`:

```scheme
(define sumList (foldr + 0))
```

```scheme
> (sumList '(1 2 3))
6
```

Many of the other functions that we have seen before perform
fold-right operations on lists. In particular, we can define
`append` using `foldr` as follows:

```scheme
(define (append xs ys) ((foldr cons ys) xs))
```

Also the higher-order function `map` is just a special case of
a fold-right:

```scheme
(define (map op) (foldr (lambda (x ys) (cons (op x) ys)) '()))
```

All the above operations on lists have in common that they combine the
elements in the input list and the result of the recursive computation
in right-to-left order. We can also consider fold operations that
perform the computation in left-to-right order:

```scheme
(op (... (op (op z d1) d2) ...) dn)
```

The corresponding computation tree then looks as follows:
```scheme
        op
       /  \
     ...  dn
     /
    op 
   /  \
  op  d2
 /  \
z   d1
```

Note that the tree is now leaning towards the left and the elements
are combined in left-to-right order. We therefore refer to this type
of computation as a *fold-left*.

The following function implements the fold-left operation on lists:

```scheme
(define (foldl op z)
  (lambda (xs)
    (match xs
      [(cons hd tl) ((foldl op (op z hd)) tl)]
      ['() z])))
```

Since addition is associative and commutative, we can alternatively
define `sumList` using `foldl` instead of `foldr`:

```scheme
(define sumList (foldl + 0))
```

In fact, this definition of `sumList` is more efficient than our
previous implementations because `foldl` is tail-recursive, whereas
our implementation of `foldr` is not. Usually, only one of the two
types of fold operations can be used to implement a specific
computation on lists if `op` is not commutative and associative. For
example, we can express `reverse` in terms of a fold-left as follows:

```scheme
(define reverse (foldl (lambda (xs x) (cons x xs)) '()))
```

If we replaced `foldl` by `foldr` in this definition, we would not
obtain the correct result. The output list would be (structurally)
identical to the input list.

Again, since the functions `foldl` and `foldr` are so incredibly
useful, they are already predefined in Scheme.

To get a glimpse of the expressive power of these higher-order
functions, consider the following function, which computes the dot
product of two vectors `v1` and `v2` represented as lists of numbers.

```scheme
(define (dotProd v1 v2) (sumList (map * v1 v2)))
```

```scheme
> (dotProd '(3 2 1) '(1 2 3))
10
```

It is instructive to re-implement this code snippet in a language like
Java to appreciate how much more concise and comprehensive the
implementation with higher-order functions is.

The basic idea of higher-order functions such as `map`, `foldr`, and
`foldl` generalizes from lists to other data structures. So you will
find these kinds of functions in most implementations of common data
structures in the standard libraries of functional programming
languages.

The code can be found [here](https://github.com/nyu-pl-fa18/class06/blob/master/list-fun.scm).
