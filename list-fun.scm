#lang scheme

; Compute length of a list
(define (length xs)
  (match xs
    [(cons _ tl) (+ 1 (length tl))]
    ['() 0]))

; Concatenate two lists
(define (append xs ys)
  (match xs
    [(cons hd tl) (cons hd (append tl ys))]
    ['() ys]))

(append '(3 4 1) '(2 6))

; Reverse a list
(define (reverse xs)
  (letrec
      ((rev (lambda (xs rxs)
           (match xs
             [(cons hd tl) (rev tl (cons hd rxs))]
             ['() rxs]))))
    (rev xs '())))

(reverse '(3 4 1 2))

; Remove consecutive duplicate elements in a list
(define (removeDuplicates xs)
  (match xs
    [(cons hd (cons hd tl)) (removeDuplicates (cons hd tl))]
    [(cons hd tl) (cons hd (removeDuplicates tl))]
    ['() '()]))


(removeDuplicates '(1 1 1 2 2 3 4 4))

; Scaling the values in a list of numbers
(define (scale factor xs)
  (match xs
    [(cons hd tl) (cons (* factor hd) (scale factor tl))]
    ['() '()]))

; Incremening the values in a list of numbers by 1
(define (incr xs)
  (match xs
    [(cons hd tl) (cons (+ hd 1) (incr xs))]
    ['() '()]))

; Mapping an operation on elements over a list
(define (map op)
  (lambda (xs)
    (match xs
      [(cons hd tl) (cons (op hd) ((map op) tl))]
      ['() '()])))

; Alternative definitions of `scale` and `incr` using `map`
(define (scale-alt factor) (map (lambda (x) (* factor x))))
(define incr-alt (map (lambda (x) (+ x 1))))

((scale-alt 1.5) '(1 2 3))
(incr-alt '(1 2 3))

; Summing the values in a list of numbers
(define (sumList xs)
  (match xs
    [(cons hd tl) (+ hd (sumList tl))]
    ['() 0]))

(define (foldr op z)
  (lambda (xs)
    (match xs
      [(cons hd tl) (op hd ((foldr op z) tl))]
      ['() z])))

; Alternative definition of sumList using foldr
(define sumList-alt (foldr + 0))

(sumList-alt '(1 2 3))

; Alternative definitions of map, append using foldr
(define (append-alt xs ys) ((foldr cons ys) xs))
(define (map-alt op) (foldr (lambda (x ys) (cons (op x) ys)) '()))

(append-alt '(1 2 3) '(4 5 6))
((map-alt (lambda (x) (+ 1 x))) '(1 2 3))

; Fold-left
(define (foldl op z)
  (lambda (xs)
    (match xs
      [(cons hd tl) ((foldl op (op z hd)) tl)]
      ['() z])))

; Alternative definition of reverse using foldl
(define reverse-alt (foldl (lambda (xs x) (cons x xs)) '()))

(reverse-alt '(1 2 3))