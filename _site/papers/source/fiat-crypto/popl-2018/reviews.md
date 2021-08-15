POPL '18 Paper #2 Reviews and Comments
===========================================================================
Paper #118 Systematic Generation of Fast Elliptic Curve Cryptography
Implementations


Review #118A
===========================================================================

Overall merit
-------------
3. Weak reject - will not argue against

Reviewer expertise
------------------
X. Expert

Paper summary
-------------
The paper proposes to generate fast ECC implementations using the Coq
proof assistant.

+ Generating correct and fast ECC implementations is an important and
difficult problem

+ new tactic fsatz for reasoning about field equalities

- no clear methodological novelty

- no clear explanation of output. generated code is in C, rather than
  assembly

The paper contributes to an important and active area of research.  It
develops a method for building certified implementations using the Coq
proof assistant, following a style successfully developed by Chlipala
and co-workers. Moreover the approach is used for two curves: Ed25519
and P256, with reasonable performance. The two main problems with the
paper is that its methodological contributions are unclear and that it
is unclear why the proposed approach would be would be an acceptable
alternative to write directly at assembly level---which provides much
stronger control and ways to accounf for all low-level architectural
details (instruction scheduling, pipelining, branch prediction, etc)
that have a critical impact on performance.

Comments for author
-------------------
The paper addresses an important problem: develop fast and correct ECC
implementations. However, the methodological novelty is unclear, and
so is the overall story. The paper should improve in the following
two directions:

- it should make a clear case why the proposed approach might become
  acceptable for use in cryptographic libraries, accounting for the
  current needs of library developers---covering many architectures,
  being integrated into their development process, dealing with side
  channels, etc. Currently, the approach generates C code, so the TCB
  must include a C compiler, and does not make any provision for side
  channel attacks. The paper should also tone down some of its claims
  (eg, distress signal l33, one hour process l230, and many others)

- it should clarify the technical steps taken to generate code. As it
  stands the paper reads more like a tutorial on ECC, and does not do
  a good job of explaining how the approach works. For instance, it is
  hard to anticipate which code will be generated for Ed25519 or P256
  from reading the paper (and I was not able to find the generated C or
  assembly code in the supplementary material).

Detailed comments:

- the 3-coordinate representation discussed l240 is rather common in
  ECC. Why present it as counterintuitive? You may also comment on
  dealing with other representations.

- fsatz: can you deal with 1/(1/ x)?

- bounds inference: can you please give more explanations on how it
  works?

- evaluation: the overhead wrt the fastest implementation seems too
  high to be taken up in practice. Can you comment? How do you prove
  equivalence between the tweaked and normal version?

- related work: there are several recent projects about verified
  crypto implementations, at Usenix Security and CCS this year. If
  possible, they should eventually be mentioned in Section 7.

Reaction to author response
---------------------------
Thanks for the response. It was helpful to clarify my understanding of your work, but does not change my overall opinion.



Review #118B
===========================================================================

Overall merit
-------------
6. Strong accept - a clear accept

Reviewer expertise
------------------
X. Expert

Paper summary
-------------
# Summary

The authors provide a framework for generating correct and fast implementations of modular arithmetic for cryptographic applications.  The paper gently guides the reader through the design space, highlighting the numerous potential correctness pitfalls and subtle performance tradeoffs.  The framework enables an engineer to (1) implement a cryptographic primitive at a high level, in terms of the abstractions of the domain (e.g. Z_p) and (2) specify parameters (e.g. carrying strategy) that guide synthesis toward a verified, high performance implementation of that primitive that only uses low-level machine abstractions.  A key enabler is a certified compiler backend which performs bounds analysis to fit limbs (digits of a bignum) to machine words.

# Strengths

+ Automatically generates correct, high performance implementations of primitives in a critical domain, making the domain accessible to a more diverse class of engineers.

+ Serves as a template for high-level programming in terms of application domain abstractions without high memory and performance costs.

+ "Extensible" in the sense that experts can still drop in and tweak when the framework doesn't exploit some optimization opportunity (as in "donna" case in eval).

+ Details design decisions necessary to make framework effective, e.g., the fsatz tactic and CPS + Coq Eval.

+ Smaller TCB than past related work. Clearly outlines interesting future work (e.g., verified domain-specific register allocation)

# Issues

- Some desirable properties still unverified (constant-time ops, compilation from C).

- Good carrying strategies still require user guidance.

# Details

Traditional verification research has focused on core infrastructure where experts root out fiddly corner case bugs with herculean effort.  However,  the most compelling case for verification is the promise of enabling non-verification-expert engineers to develop code which would otherwise be too complex.  The submission supports this more compelling argument.

Instead of only a handful of elite "rock star" programmers being capable of working on the implementations of critical primitives primitives, a much broader class of programmers (roughly any competent engineer familiar with the domain) can use this submission's framework to confidently experiment with new primitives or optimizations of existing primitives without fear they will inadvertently introduce major (functional-correctness-related) security vulnerabilities.

The authors framed this submission to focus on the particular task of generating implementations of cryptographic primitives, and in that light it serves as yet another nail in the coffin of verification skeptics.  However, it also serves as a interesting case study in "high-level programming without regret".  Engineers today are still typically stuck with programming against low-level machine abstractions like hardware integers and floating point.  Hiding the gory details of these hazardous abstractions is expensive in terms of memory and performance, and so popular applications still use them.  This paper gives a compelling story for how we can have the best of both worlds: program directly in terms of domain abstractions and get performance comparable to the best expert-hand-coded assembly.

Comments for author
-------------------
What was meant by "Our initial implementation, misguided by types, ..." (p19:920)?  Did typeclasses somehow mis-infer an instance?

The phrasing "... length, and in basic arithmetic operations we ..." (p17:823) was difficult for me to parse.

Reaction to author response
---------------------------
The reviewers had a long discussion about this submission which divided us roughly into two camps: (1) the paper's goal is to automate the work of current elite crypto engineers and (2) the paper is for verification engineers who would like to enable domain experts to generate high quality implementations without requiring assembly-level expertise.

Overall, it was felt that the paper is written primarily for (1) and that, from such a perspective, the paper does not live up to its claims. In particular, it seems unlikely that the approach will be able to squeeze out every last ounce of performance which is the primary task of elite crypto engineers. Furthermore, some reviewers felt that relative to recent competing work, this paper does not provide sufficient additional insights. In particular, the advantages over HACL and Jasmin must be further clarified.

From the perspective of (2), the reviewers were more excited about the paper. Most papers on program synthesis struggle for 20 pages to produce code that a competent programmer would have written on their first try. Here, we have an example where the synthesized code is way beyond the reach of the average competent programmer, as it builds on a great body of mathematical knowledge and data representation tricks that were successfully mechanized by the synthesis tool. Plus, it achieves 50% or more of the performance of the best hand-written implementations, which is also way beyond the reach of the average competent programmer. However, even from this perspective, the reviewers were divided as the paper did not crisply clarify how the design insights sprinkled throughout the paper add up to a clear contribution over past work in Bedrock and Fiat. Furthermore, the reviewers felt that the paper should tighten the ECC background and devote more space to describing the compiler (e.g., expanding the discussion around the challenges of abstract interpretation over programs in PHOAS, and further detail the compiler theorems).

Ultimately, it was decided that reworking the paper to be squarely from the perspective of (2) and to crisply articulating the new, reusable insights was beyond the scope of shepherding. The reviewers greatly appreciated the supplementary Coq development and referred to it several times during discussion, though there were requests for a README which outlines the structure of the code base.



Review #118C
===========================================================================

Overall merit
-------------
3. Weak reject - will not argue against

Reviewer expertise
------------------
X. Expert

Paper summary
-------------
The paper presents a framework to automatically generate correct and efficient implementations of elliptic curve operations from their high-level specifications. The paper develops the framework in Coq and the methodology is as follows. For a curve, the programmer first picks an optimized point format, writes the curve operations using the optimized point format, and proves their equivalence with the operations on the unoptimized format. To facilitate these proofs, the paper develops a Coq tactic fsatz, that extends nsatz with more operations (division, inequalities, etc.). The next step is to pick the modular arithmetic representation for the numbers in the point format. The paper develops a generic, verified modular arithmetic library that abstracts out details like number of limbs, base system, etc. Having picked the parameters, the toolchain then partially evaluates the curve operations to yield assembly-like code. Finally, a certified compiler does range analysis on the code to assign appropriate bit-width types to the variables. At this point, a trusted code converts the AST to C code, to be dropped in rest of the code. The paper evaluates the framework on X25519 scalar multiplication, and NIST256 addition. The performance is found to be better than corresponding OpenSSL C implementations.

Comments for author
-------------------
Pros:

-- The paper considers a very relevant problem, and presents a methodology for generating efficient and correct-by-construction implementations of elliptic curve operations.

-- The performance of a couple of operations evaluated in the paper is better than hand-written, unverified OpenSSL C code, and somewhat close to the asm code.

Cons:

While the paper seems like a good start, the contributions and evaluation seems a bit premature to me.

-- The contribution of the paper is a methodology that generates fast implementations of elliptic curve operations. But that's one part of the cryptographic routines, what about the code that uses it such as the signatures and ciphers? Right now the paper drops in the generated code in the context written in C, but what would be the long-term plan here?

-- For each curve, the proofs about optimized data format (Section 3.1) need to be done again, but the bignum library can be reused with different parameters, is that right?

-- The evaluation is done only on two operations: scalar multiplication on X25519, and addition on NIST256. Why not evaluate more operations? With only these two evaluation points, it is not clear if the efficiency claims would generalize to more operations.

-- It is also unsatisfying that the paper does not prove side-channel resistance or cryptographic security of these operations.

The paper should also look at recent progress in various tools in the area: "Jasmin: High-Assurance and High-Speed Cryptography" and "HACL*: A Verified Modern Cryptographic Library", both appearing in CCS'17. These tools seem much ahead in terms of the state-of-the-art of verified cryptography.

Minor points:

-- The TCB comparison on line 173 seems a bit unfair, corresponding to the trust in F*, the paper also trusts Coq (which is indeed clarified on line 199 later).

-- It would be useful to show the theorem statements, some library code, etc. Right now the paper is heavy on low-level mathematical details of curve operations, that are not even the main contribution of the paper.

-- In the future work section, generating TLS protocol seems highly speculative.

Reaction to author response
---------------------------
Thanks to the authors for their response. It helped me understand the contributions better.



Response1 Response by Jade Philipoom <jadep@mit.edu>
===========================================================================
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
