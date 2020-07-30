Thanks for the wealth of suggestions on improving the paper's presentation.  We'll be glad to consider reordering material or adding new information.  For now, we'd like to point out how a few of the requests for expansion can be addressed with existing material in the paper, possibly in the context of some brief new clarifications.

- Review A asks for more detailed comparison with other approaches.  First, on the side of performance of related code, competing approaches involve writing code by hand, and they generally copy quite faithfully from the best known implementations (e.g., OpenSSL), so our comparison with best-known versions is a strong proxy for the performance elements of HACL*, Jasmin, and Vale.  On the side of developer effort, we hope the message came across that, once a new algorithm is implemented in our framework, it becomes almost free to recompile for a new prime modulus or a new hardware-architecture class, while as far as we know, no high-performance past project had implemented/verified more than one configuration of that kind per algorithm.  Furthermore, we don't know of any prior high-performance verification of NISTP256 or Montgomery reduction, which are used by the vast majority of TLS connections today.
- Review B asks how developers use the tool and what comes out in the end.  We should perhaps have been clearer that our story involves at least three layers: the framework, generic implementations of algorithms, and instantiations of those algorithms to new parameters.  Targeting a new algorithm involves new coding and proving work (often nontrivial).  However, compiling an existing algorithm with new parameters really does only require the level of effort seen in the "Input" part of Figure 1 (no proving, etc.).  Much of the PLDI audience probably takes that sort of thing for granted, but as far as we know, all past approaches have required days of work to "recompile" an existing algorithm for new parameters.  And, yes, the "Output" part of Figure 1 is representative of what our tool produces.  It can be copied-and-pasted into a project, compiled and linked as a library, etc.
- Review C expresses skepticism that crypto-library authors will use this tool.  We're not sure what to say beyond our original (blinded) description of how one of the most used crypto libraries has already adopted our framework (and more has happened since paper submission).  It seems there is a nontrivial segment of the crypto world where stronger security guarantees can outweigh the last 10% of performance.
- Review D says that we failed to discuss side-channel resistance, though we believe the issue was treated fully (but perhaps the presentation deserves rearranging).  In addition to several other mentions throughout the paper, see the paragraph starting on line 951.  Essentially, our target language only exposes instructions that preserve constant time.
- Review D asks how the compiler chooses a representation.  The main part of our framework is designed to take the representation as a parameter, and it is hard to predict analytically which choice will perform best.  Thus, the experiments of Figure 3 involve heuristic generation of several representations per configuration (prime modulus and hardware target), compiling with each choice, and keeping the best-performing version.  Currently we only bother generating 2 representations per configuration, but it is easy to add new heuristics to the mix, with no new formal-methods work.
- Review E asks who performs CPS translation and makes important design choices.  Currently the programmer implementing a new generic algorithm codes and proves a CPS version manually.  We would like to apply CPS translation automatically, though our initial efforts were flummoxed by the dependent types used by our direct-style algorithms.  Design choices like data-representation changes for points are also made manually by the programmer implementing a new algorithm.  From this question and parts of other reviews, we see that one point we failed to make clearly is that nontrivial manual work goes into implementing a new verified, generic algorithm, while we then provide a good automation story for instantiating that algorithm with new parameters.

More responses past the 700-word limit
======================================

We see two main use cases for the artifact produced in this work.
First it can be used in a plug-and-play fashion to generate modular arithmetic code using the already-implemented strategies.
This use case is rather narrow but very expedient when it is applicable.
More importantly, we think there is a lot going for implementing new optimized algorithms in the style we propose.
In particular, the code reuse made possible by our library (relying on a predictable specializing compiler) allows new operations (e.g. polynomial multiplication) and tricks (e.g. Karatsuba's multiplication, interleaved carrying and reduction) to be added with less effort than using any other methodology we are aware of.
For example, we implemented (and proved correct) Goldilocks Karatsuba multiplication at a conference lunch break when the author of the technique inquired whether our framework could support it.

Review D
--------

We wholly agree that going from the C code our pipeline generates to speed-record-setting assembly code requires a whole new set of techniques in addition to those described in this paper.
In our opinion, our output language is a natural interface between domain-specific and microarchitecture-specific optimizations, so that the C-to-assembly translation would not need to understand modular arithmetic or limbed representations to produce the best assembly we know to wish for.
As the first reviewer points out, a simple translation validation should be sufficient to connect the assembly code that includes low-level optimizations to the output of our pipeline it was generated from.
In fact, as seen in libsecp256k-c64, it is even possible to improve on our performance within the C language by munging source code (at the same abstraction layer as our generated code) into a form that happens to persuade a particular compiler to produce the desired register allocation and instruction schedule.

Asymmetric cryptography implementations (ours and others') use very simple CPU instructions and cannot benefit from the AES/SHA implementations found on some popular CPUs.

We view producing straight-line code as a strength rather than a limitation.
Any conventional compiler (e.g., gcc, ocamlc) could turn code roughly at the same abstraction layer as our templates into machine code that uses loops and branches, but so far it has taken significant amounts of (duplicative) human effort to produce specialized constant-time code.
We do not generate loops or complicated control-flow logic (e.g., as seen in elliptic-curve scalar multiplication routines that use precomputed tables) because writing (and verifying) the code with loops in the first place is pleasant and reliable when compared to doing the same for specialized field-arithmetic implementations.
Our library already includes verified code with iteration and conditionals, and we have integrated it (with proofs) with our generated field arithmetic.
There is just nothing novel about it.

Review E
--------

The question "In Section 2.3, are we assuming $p < 2^{64}$?" may have been caused by our typo of $\mathbb N_p$ in place of plain $\mathbb N$ on line 333.  Sorry!

On guarantees throughout our pipline: each run of the entire pipeline, from a specification like "a * b mod m" to C code, generates a proof certificate for functional correctness.
For the early phases, the proof is generated anew using tactics on each execution.
The flattening and word-size-selection transformations (the "certified compiler") are proven correct once and for all, and this proof is appropriately linked into the end-to-end proof.

The hand-modified version in section 6.2 is proven equivalent to the generated code it replaces before word-size selection using the `ring` tactic from Coq's standard library.
It is indeed ad-hoc but has an end-to-end Coq-checkable correctness proof against the same specification as the rest of the library, and the proof is very automated, in the tradition of translation validation.
We also intended that manual transformation as an experiment to zero in on the nature of our performance gap with other code; we are not suggesting manual code tweaking as part of the intended usage of a future, improved version of our framework (and it is easily skipped now if being within 10% of best-known performance is acceptable).
