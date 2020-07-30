We're very glad to have reviews from 3 experts!
The comments point out some perspective issues that we're eager to address by revising the paper.
We'll mention those before returning to answer some more specific questions, after the 600-word limit.

Most importanly, we want to emphasize what we see as the main novelty of the paper: encapsulation of intricate machine arithmetic and its proofs in libraries, so that not only is there no significant manual proof effort for each new prime modulus; we don't even need to do something like call an SMT solver to prove each new suite of code.  Rather, we have proved the whole family of algorithms correct once and for all, in a way that still lets us generate pretty fast, idiomatic low-level code.

Next, there's a perspective summed up well in Reviewer C's comment that other recent work seems "much ahead [of us] in terms of the state-of-the-art of verified cryptography."
However, none of that work presents higher-level abstractions like we called out in the prior response paragraph.
We tried to sketch out our bigger-picture plan in the paper, where we do plan to connect to proofs of cryptographic security, of constant-time execution, and with a trusted base that ends in assembly language.
Those connections have not been made yet, but we felt that our main novelty (described in the prior response paragraph) is valuable and interesting enough on its own.

We appreciate the pointers to 3 papers (on HACL*, Jasmin, and Vale) that weren't published as of the POPL deadline.
As far as we know, none of those demonstrate almost-complete code or proof reuse across prime moduli for machine arithmetic, as we do.
(We should point out that the mainstream assembly-generating scripts that the Vale paper mentions are operating at a much lower level of abstraction than for our work, not coming close to abstracting out a prime modulus.)
However, as the reviewers point out, those other projects include complementary parts of a verification stack, so we plan to look into ways to connect to these systems, rather than building our own alternatives.
For instance, our pipeline is a perfect match with Jasmin: the final terms that we produce are effectively in a subset of the Jasmin input language.
We aren't aware of any duplication of functionality between our respective tools: every one of our phases is needed to produce code low-level enough for Jasmin or Vale to accept as input.

It seems worth reiterating that generation of C code is just an element of our current experimental setup: our formal development actually bottoms out in a simple straightline-code language (with a subset of the features of Jasmin), and we do not intend to use C in any way in the extensions we sketch as important future work.

Finally, multiple reviewers commented on the amount of space we spend in the paper on reviewing material well-known to experts on ECC.
We tried to negotiate the balance between keeping those experts interested and keeping a general POPL audience engaged; we will think about tweaking the balance based on the reviewers' remarks.
However, we do think that our presentation of key strategies often includes ideas that are "obvious in retrospect," but that were not known in this form to crypto experts.
Formulating the ideas in this way was crucial to making our Coq proofs tractable.
One example is the question we consider in Section 4.3, on flexible representation of multi-digit numbers.

# Further detailed responses (past word limit)

## How to prove equivalence between our initial generated version of a routine and another version where we have done some optimizations manually?

With straightline low-level code like is involved here, we just need to evaluate the two versions as functional programs and use Coq's `ring` tactic to prove equivalence of results.
In other words, naive symbolic execution suffices.

## Avoiding timing side channels

By design, our output AST type can *only* represent constant-time code; there are no branches, loops, or divisions.
(We do assume that the processor actually implements these instructions in a constant-time fashion, but checking that must be done experimentally as long as we do not have access to a precise specification or implementation that captures this timing behavior.)
We only mention timing analysis as part of future work that would extend our derivation pipeline to higher-level cryptographic code.

## Where is the generated code in the supplementary material?

The generated code is in `src/Specific/NISTP256/AMD64/` and `src/Specific/X25519/C64/`; to see output in our AST format, look at the files ending in `.log`.
To see C, run `make c` to generate `.c` files.

## fsatz: can we deal with 1/(1/x)?

Yes, and it is not a special case for the algorithm.
`src/Algebra/Field_test.v` contains several more complicated examples; adding `Lemma inv_inv x (H:x <> 0) : 1/(1/x) = x. fsatz. Qed.` passes.

## Effort to choose good carrying strategies

Selecting a carry chain is a complex problem; choices depend heavily on the target architecture, and there is not really a good way to evaluate them other than empirical testing.
Some general heuristics exist but may not provide optimal choices.
However, we could easily integrate any heuristic into our build process, with no effect on proofs.

## Meaning of "Our initial implementation, misguided by types, ..."

We are referring to a classic sort of mistake when programming with dependent types: calling it a day when a routine type-checks, even before it has been proven correct.
We were lulled into a false sense of security by the width-tracking dependent types of bitvectors, in a tricky loop with a surprising design space that the crypto literature hadn't spelled out.

## Extending our results to cover signatures and cyphers, not just lower-level ECC operations

Actually, we have composed the operations into more complex schemes (ed25519) in Gallina, but we haven't formalized extracting C function calls because we eventually plan to cut out C and output straight to assembly.
Still, we used our generated field-arithmetic code as subroutines in complete Gallina (Coq) programs for signing and signature verification, which we proved equivalent to their simple specifications.
So carrying out this exercise ensures that we chose the right formal interface for the code that makes up the main novelty of our project.
(We mention this aspect in the paragraph with line 397.)

## New work that needs to be done for each new curve

For each new *point format*, it is necessary to write a new correctness proof, although the proof would almost certainly be a single invocation of `fsatz`.
The library already includes code and equivalence proofs for affine, XYZT, and Niels variants of Edwards coordiantes; affine, Jacobian, and Projective Weierstrass coordinates; and affine and XZ Montgomery coordinates.
When reusing an existing point format for a new curve or a new hardware architecture for an existing curve, the new implementation work is roughly just in the configuration snippets shown near the beginning of our Experimental Results section.

## Why not implement and benchmark more operations than just for 25519 and P256?

P256 and X25519 make up the vast majority of ECC usage on the Internet.
For example TLS ECDHE was measured to be 97% P256 in 2015[1]; since then X25519 has been deployed, reaching around 30% of connections established by Google Chrome.
We find it much more valuable to increase the depth of our verification (we already use higher-level specs than in any other work we know of, but there is still room to extend towards assembly) and performance of the code (fixing up the low-level inefficiencies pointed out by the reviewers and ourselves) than work on less commonly used curves.
If we wanted to further demonstrate the flexibility of the framework, it would be more meaningful to create different implementations of X25519 and P256, because that is where the performance engineering research is focused.
We could, of course, use the existing library to generate code for other curves (e.g. P384), but since we (and most libraries we know) would not prioritize their performance, the benchmarks would be less revealing.
Once we have a functioning pipeline to assembly code, we might seek to imitate the x25519-amd64-64 implementation that is fastest in our benchmarks but awkward to represent as C code.
However, since we intentionally chose our implementation strategies for X25519 and P256 to be as different as possible, every technique we know for implementing these curves (or any curves at a similar security level) would be an interpolation between the tricks used in our saturated-Montgomery-multiplication P256 code and unsaturated-Solinas-reduction X25519 code (e.g. x25519-amd64-64 uses saturated arithmetic with Solinas reduction).
New optimizations like specialized Karatsuba multiplication used for Goldilocks primes (e.g. X448) would need to be added and proven once as high-level optimizations, but again, we see expanding the work in other ways as more practically valuable at this moment.

[1]: "TLS in the wild: An Internet-wide analysis of TLS-based protocols for electronic communication" https://www.net.in.tum.de/fileadmin/bibtex/publications/papers/2016-tls-ndss.pdf

## Explanation of local-variable bitwidth inference

Sorry for the possibly cryptic description "abstract interpretation with intervals"!
We do think that (with the exception of bitwise operators and their sometimes-not-obvious conservative rules) we follow the abstract-interpretation literature pretty closely, even avoiding the complexities of code with interesting control flow, since we only analyze straightline code.
Here's another try at a summary: the analysis starts with some lower and upper bound for each variable, and applies sound (but not necessarily complete) operation-specific rules to derive bounds for further variables defined in the program, computing each's bound as a simple function of bounds for its operands.
Each variable is assigned the fastest integer type that encompasses its full computed interval.
This transformation and analysis is proven to preserve the output value for all code.
