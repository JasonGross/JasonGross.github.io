# General Clarifications

## "Synthesis"

It's true that our pipeline is "synthesis" in only a limited sense, and that
was evidently an unfortunate choice of wording for a PLDI audience. We process
code in two steps: (1) verifying optimizations in a generic way and (2)
compiling code (with specific parameters instantiated) that applies those
optimizations. The first is done mostly manually, but is done once for wide
classes of curves. The second is done mostly automatically, with minimal human
input (specifically, a JSON file like the one shown in section 6.3). There is
no search process involved. 

## Haskell

Our output was a syntax tree of simple, assembly-like operations[0]. The
performance-critical leaf functions could easily be pretty-printed to C or
any other language that supports fixed-size integers. The final product does not
depend on any specifics of Haskell or GHC, though for convenience we used them
for the performance experiments reported in the paper. Writing a verified compiler that
performs efficient register allocation and produces code for a sufficient subset
of architectures would be another project in itself.

## Scope

We'd like to clarify which formal claims we aim to establish for particular
generated pieces of code.  Given a cryptography implementation, there are two main
kinds of security vulnerabilities to worry about.

1. The protocol being implemented might not have the properties it claims.
2. The implementation may fail to correctly implement the protocol.

We are focused entirely on the second question. Implementation correctness is a
significant source of bugs and, due to intense optimization efforts, contains
complex reasoning. However, there is no real "attacker model" needed for this
problem.

## "Side channels"

We do not currently verify that our code runs in constant time, or that it does
not expose its secret inputs through some other means. Such verification would
be fundamentally different from ours, primarily because it would heavily depend
on the details of the deployment scenario. For example, processors implementing
the same instruction set can differ in which instructions leak their inputs
into timing, and CPU vendors as a rule do not publish documentation regarding
this. However, pretty-printing our low-level functions as C instead of Haskell
and running ct-verif to analyze that output would indeed clear it as "constant
time" in a common timing model.

## Performance

Some reviewers pointed out an 80x gap between our ed25519 signing implementation
and the best manual ones, which is much larger than the 6x gap for the handshake
benchmark that we focused on. This is because our ed25519 code consisted of
plugging our optimized code for subroutines into a verified but completely naive
implementation of the high-level signature scheme. We included the ed25519
implementation to show that the formal specifications of our code allow for
verified generic composition; we did not make any attempt at optimizing the
signature-specific high-level code. That said, the missing optimizations are
conceptually very similar to the ones we did implement, and we believe that it
would be rather straightforward to extend our library to include them.

Another comment was that the 6x gap for the handshake benchmark is still too big
for practical use. This is true for some cases of "practical use," but we are
very confident that our approach has not hit a wall at this speed. There are
clear improvements to make that would close this gap. Furthermore, the 6x gap is
between our implementation and the very fastest of the handwritten ones. Our
code is only 40% slower than the code used in Chrome, in part because the
developers have significantly more confidence in the correctness of that code
compared to the fastest assembly code, whose slight variant "64-24k" contained
an elusive arithmetic bug as shown in table 1.

# Answers to Remaining Questions

**What reusable insights does this paper provide for similar future tools?**

We believe our strategy generalizes to any arithmetic-heavy domain (including
those listed in the end of section 8), but as we have no evidence, just an
(informed) guess, we leave the determination of whether our method would suit
some particular application to the reader interested in that application. 

**What exactly is the TCB?**

Coq and our whiteboard-level specs. As explained above, we require some kind
of tool that does register allocation and does the final translation to a
machine-specific assembly. So, if the tool used for that task is unverified,
it is part of the TCB for that particular instantiation of code. Although we
use GHC for this purpose in our benchmarks, it's not the case in general that
GHC is part of our TCB. For a realistic use of our code, we would recommend
pretty-printing it into the language used by the overall project.

**How often do curve parameters change, and would they change more often if
there were a lower cost to reimplement high-performance implementations?**

The mathematical parameters have changed once in TLS (from a set of 4 to a set
of 2), and gaining adoption required the proposer to write optimized
implementations for every conceivable platform. The performance-oriented
parameters like carry chains and word size change when code is ported from one
CPU microarchitecture to another -- OpenSSL currently contains several different
implementations of arithmetic modulo P256.


[0] Full definition of output syntax tree as found in the submitted code
tarball (the type variable `tZ` is instantiated with a type representing
machine words in the final output):

In `src/Reflection/Syntax.v`, lines 186-191:
~~~
Inductive exprf : flat_type -> Type :=
| Const {t : flat_type} : interp_type t -> exprf t
| Var {t} : var t -> exprf t
| Op {t1 tR} : op t1 tR -> exprf t1 -> exprf tR
| LetIn : forall {tx}, exprf tx -> forall {tC}, (interp_flat_type_gen var tx -> exprf tC) -> exprf tC
| Pair : forall {t1}, exprf t1 -> forall {t2}, exprf t2 -> exprf (Prod t1 t2).
~~~

In `src/Reflection/Z/Syntax.v`, lines 34-44:
~~~
Inductive op : flat_type base_type -> flat_type base_type -> Type :=
| Add : op (tZ * tZ) tZ
| Sub : op (tZ * tZ) tZ
| Mul : op (tZ * tZ) tZ
| Shl : op (tZ * tZ) tZ
| Shr : op (tZ * tZ) tZ
| Land : op (tZ * tZ) tZ
| Lor : op (tZ * tZ) tZ
| Neg (int_width : Z) : op tZ tZ
| Cmovne : op (tZ * tZ * tZ * tZ) tZ
| Cmovle : op (tZ * tZ * tZ * tZ) tZ.
~~~
