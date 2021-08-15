% Efficient and Verified Finite-Field Operations
% Speaker: Jason Gross

We discuss new advances that allow us to generate efficient finite-field
operations in C, including machine-checked proofs of their correctness. The
work is built on [fiat-crypto](http://adam.chlipala.net/papers/FiatCryptoSP19/)
(accepted to IEEE S&P 2019), a project which formalizes many of the
optimization techniques used by applied cryptographers and proves that they are
correct in general using Coq, a theorem-proving software package. That is, any
compilation generates a mathematical proof that efficient C-like code computes
the same mathematical function as a simple algorithm in number theory, and the
Coq software checks the proof automatically. We will demonstrate the current
functionality, talk about the recent integration of our work into Google's
BoringSSL, and explain the interesting process by which we formalized
optimization strategies so they could be verified.

## Performance and Effort

Our C implementations are competitive with handwritten C implementations for
common curves, although not competitive with handwritten assembly. However,
unlike handwritten and bit-fiddly C, our work requires *no* per-curve effort to
produce code. We automatically generated efficient field operations for 80
different primes, for both 32- and 64-bit architectures. In order to have a
basis for comparison, we used the GNU Multiple Precision Arithmetic Library to
create reasonably intelligent implementations for each prime, and let it
"cheat" by using the variable-time API. Depending on the prime/architecture
combination, our speedup over this implementation was between 1.25x and 10x,
hovering around 6-9x for smaller primes and 3-5x for larger ones.

In short, we produce competitive code with zero human effort and
computer-checked proofs of correctness. We find that this is appealing to
industry partners, who are limited by the time constraints of sufficiently
skilled implementers and the uncheckability of lengthy, low-level code.

## Project Structure

Writing high-performance code for finite-field operations requires two
categories of optimization. One category is micro-optimization--for instance,
grouping constant multiplications to use smaller registers, or removing
multiplications by one.  The second category is those optimizations that are,
in some sense, reusable--although they appear specialized to a particular prime
field and computer architecture, one could use the same ideas to generate a
strategy for any field/architecture combination. Our system supports both of
these categories.

First, within Coq, we have defined mathematical structures like elliptic curves
and finite fields. This includes writing simple mathematical definitions of
finite-field operations (e.g. addition, multiplication) as functional programs.
Then, we write a second set of functional programs that perform finite-field
operations using reusable optimization techniques like pseudo-Mersenne
reduction, Montgomery reduction, constant-time conditional subtraction, and
interleaving carry chains. We prove the techniques correct in general and thus
prove that the second set of programs is equivalent to the finite-field
operations in the mathematical model. 

Next, we specialize to a particular prime and architecture. This involves, for
instance, choosing an efficient (and potentially complex) representation
strategy for finite-field elements, choosing whether to use Montgomery or
pseudo-Mersenne reduction, and choosing a carry chain. Somewhat surprisingly,
we can make good heuristic guesses automatically based only on the prime, and
just try a couple of combinations.

Finally, we run the specialized functional program through a verified
"compiler" that first switches to finite-sized integers by tracking variables'
bounds, then applies known micro-optimization strategies, and finally outputs
the program in a constant-time-only intermediate language made up of hardware
instruction equivalents such as `ADDC` and `CMOV`. All of these passes are
proven correct for all parameters, so proofs of correctness for a particular
curve require no parameter-specific effort.

At this point the program can be converted to C by inserting type casts and
replacing operations with C equivalents. Since we are only using basic
constructs like addition, bitshifting, and multiplication, we don't need a
fancier model of C than, for example, that C multiplication is equivalent to
our intermediate-language multiplication.

## Talk Focus

For RWC, our talk would focus primarily on the practical aspects of integrating
this project with BoringSSL and how to connect something as academic as
"general forms of optimization techniques" to something as practical as
"efficient and proven-correct C that doesn't require knowing how to use a proof
assistant". We would also show some of the formalized optimization techniques
and explain how they correspond to individual implementations, since we expect
that these general forms (not written anywhere else, to our knowledge) might be
of interest to people who are familiar with the specialized versions.
