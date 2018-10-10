#lang scheme

(define (sum f)
  (lambda (a b)
        (if (< a b) 
            (+ (f a) ((sum f) (+ a 1) b))
            0)))

(define sumInts (sum (lambda (a) a)))
(define sumSqrs (sum (lambda (a) (* a a))))

(sumInts 1 4)
(sumSqrs 1 4)