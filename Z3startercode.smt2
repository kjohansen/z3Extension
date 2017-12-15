;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  BEGIN HEADER  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-sort MyInt () (_ BitVec 8))
;; These represent the parameters to our method
(declare-const a MyInt)
(declare-const b MyInt)
(declare-const c MyInt)

;; Some bit-vector constants for convenience
(declare-const bv0 MyInt) ; 0000
(declare-const bv1 MyInt) ; 0001
(declare-const bv2 MyInt) ; 0010
(declare-const bv3 MyInt) ; 0011

;; Some more convenience constants representing sums of a, b, and c
(declare-const a-plus-b MyInt)
(declare-const a-plus-c MyInt)
(declare-const b-plus-c MyInt)

;; " ... "" relations of a, b, and c
(declare-const a-eq-b bool)
(declare-const a-eq-c bool)
(declare-const b-eq-c bool)

;; Assign our constants with an 'assert'
(assert (= bv0 #x00))             ; constant `bv0` := 0
(assert (= bv1 #x01))             ; constant `bv1` := 1
(assert (= bv2 #x02))             ; constant `bv2` := 2
(assert (= bv3 #x03))             ; constant `bv3` := 3

(assert (= a-plus-b (bvadd a b))) ; a-plus-b := a + b
(assert (= a-plus-c (bvadd a c))) ; a-plus=c := a + c
(assert (= b-plus-c (bvadd b c))) ; b-plus=c := b + c

(assert (= a-eq-b (= a b)))       ; a = b
(assert (= a-eq-c (= a c)))       ; a = c
(assert (= b-eq-c (= b c)))       ; b = c

;; Here we do some SSA style assignments to get the final value of trian
(declare-const trian1 Int)
(declare-const trian2 Int)
(declare-const trian3 Int)
(declare-const trian  Int)

; Conditionals in if statements given by their line numbers in the initial
; source code. Thus line-20-cond corresponds to 
; 
;       if (a <= 0 || b <= 0 || c <= 0) { ...
;
; This is provided for convenience

(declare-const line-20-cond bool) ; if (a <= 0 || b <= 0 || c <= 0)
(declare-const line-24-cond bool) ; if (a == b)
(declare-const line-27-cond bool) ; if (a == c)
(declare-const line-30-cond bool) ; if (b == c)
(declare-const line-33-cond bool) ; if (trian == 0)
(declare-const line-34-cond bool) ; if (a + b <= c || a + c <= b || b + c <= a)
(declare-const line-40-cond bool) ; if (trian > 3)
(declare-const line-43-cond bool) ; if (trian == 1 && a + b > c)
(declare-const line-45-cond bool) ; if (trian == 2 && a + c > b)
(declare-const line-47-cond bool) ; if (trian == 3 && b + c > a)

; Assign the values of the conditionals
(assert (=  line-20-cond (or  (bvslt a bv0)
                              (bvslt b bv0)
                              (bvslt c bv0))))
(assert (= line-24-cond a-eq-b))
(assert (= line-27-cond a-eq-c))
(assert (= line-30-cond b-eq-c))
(assert (= line-33-cond (= trian 0)))
(assert (= line-34-cond (or (bvsle a-plus-b c)
                            (bvsle a-plus-c b)
                            (bvsle b-plus-c a))))
(assert (= line-40-cond (> trian 3)))
(assert (= line-43-cond (and (= trian 1) (bvsgt a-plus-b c))))
(assert (= line-45-cond (and (= trian 2) (bvsgt a-plus-c b))))
(assert (= line-47-cond (and (= trian 3) (bvsgt b-plus-c a))))

;; Here we use the __definition__ of logical implication:
;;
;;      X ==> Y := !X \/ Y
;;
;; to set up our values for trian1, trian2, and trian3. Notice that we have to
;; write two implications:
;;
;;    cond-is-true  ==> trian1 = 1
;;    cond-not-true ==> trian1 = 0
;;
;; Justify to yourself why BOTH contstraints are needed!

(assert (or (not line-24-cond) (= trian1 1)))
(assert (or      line-24-cond  (= trian1 0)))

(assert (or (not line-27-cond) (= trian2 2)))
(assert (or      line-27-cond  (= trian2 0)))

(assert (or (not line-30-cond) (= trian3 3)))
(assert (or      line-30-cond  (= trian3 0)))

(assert (= trian (+ trian1 trian2 trian3)))

(declare-const initial-condition bool)
(declare-const mutated-condition bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  END HEADER  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; # MUTANT 76
;; @@ -35 +35 @@
;; -            if (a + b <= c || a + c <= b || b + c <= a) {
;; +            if ((a + b <= c != a + c <= b) || b + c <= a) {
;; NOTE: Parentheses are inserted above to clear up ambiguity

(push)
(echo "=================================== MUTANT 76 ==================================")

;;;;;;;;;;;;;;;;; START STUDENT CODE ;;;;;;;;;;;;;;;

(assert (not line-20-cond))
(assert line-33-cond)

(assert (= mutated-condition (or (or (and (not (bvsle a-plus-c b))
                                          (bvsle a-plus-b c))
                                     (and (bvsle a-plus-c b)
                                          (not(bvsle a-plus-b c))))
                                 (bvsle b-plus-c a))))

(assert (= initial-condition line-34-cond))

;;;;;;;;;;;;;;;;; END STUDENT CODE ;;;;;;;;;;;;;;;
(assert (not(= mutated-condition initial-condition)))

(check-sat)
(echo "-------------------------------- Getting model ---------------------------------")
(get-model)
(pop)



