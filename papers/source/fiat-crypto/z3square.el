the following (sat) does not work (timeout):
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 57896044618658097711785492504343953926634992332820282019728792003956564819949) (- 0 1)) (* sqrt sqrt)))
(check-sat)

the following (sat) works:
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 65521) (- 0 1)) (* sqrt sqrt)))
(check-sat)

the following (sat) does not work (timeout):
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 16777213) (- 0 1)) (* sqrt sqrt)))
(check-sat)

the following (unsat) does not work (unknown):
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 3) (- 0 1)) (* sqrt sqrt)))
(check-sat)

this (sat) works:
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 5) 4) (* sqrt sqrt)))
(check-sat)

this trivial (sat) does not work (timeout):
(declare-const wrapcount Int)
(declare-const sqrt Int)
(assert (= (+ (* wrapcount 2147483647) 4) (* sqrt sqrt)))
(check-sat)
