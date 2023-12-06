---
layout: page
title: Projects Wishlist
permalink: /project-wishlist/
---

This is a list of projects that I would love to see happen.
Alas, lacking infinite time, I don't have any concrete plans to make them happen, but I'd be happy to advise others undertaking these projects.
Some of these might serve as good bachelor's or master's thesis projects, while others are likely too ambitious or not adequately ambitious.
I've included estimates of how much work I think each project would take *me*, so adjust accordingly for your greater or lesser experience with the domain.
The bottom of the list has some less ambitious projects.

<hr>

1. Proving well-typedness of quotation in MetaCoq

   - Context: Löb's theorem says `□(□X → X) → □X` where `□T` means `{ t : Ast.term & Σ ;;; [] |- t : <% T %> }`.
       The two biggest undertakings in getting such a theorem about a substantial AST are quotation (`□X → □□X`) and decidable equality of ASTs.
       MetaCoq largely has decidable equality of ASTs already, and this project is about completing quotation, and in particular the second projection, that the function `quote : { t : Ast.term & Σ ;;; [] |- t : T } → Ast.term` which adds a layer of quotation gives something that is well-typed, i.e., that we have `∀ v, Σ ;;; [] |- quote v : <% { t : Ast.term & Σ ;;; [] |- t : T } %>`.
   - Partial work: [`JasonGross/metacoq@coq-8.16+quotation-typing`](https://github.com/JasonGross/metacoq/tree/coq-8.16+quotation-typing), [`MetaCoq/metacoq/quotation/`](https://github.com/MetaCoq/metacoq/tree/coq-8.16/quotation)
   - Estimated commitment: 1--2 major design decisions + 8k--800k loc (defining [`quote`](https://github.com/MetaCoq/metacoq/blob/77234210ad9593d7304f9f0d453f70424b2c8f90/quotation/theories/ToPCUIC/All.v#L8-L9) took about 8k loc and 200 hours [![wakatime](https://wakatime.com/badge/user/0f006c2b-db7d-4bc9-ae89-c8cd8efd2076/project/76cf34bd-94cf-4e0c-b8f7-84a895b7af60.svg)](https://wakatime.com/badge/user/0f006c2b-db7d-4bc9-ae89-c8cd8efd2076/project/76cf34bd-94cf-4e0c-b8f7-84a895b7af60))
   - Notes:
     + There are two major blockers at the current state of this project:
       1. Having a version of the safechecker that produces unsquashed typing derivations.
          I believe [Théo Winterhalter may be working on this](https://coq.zulipchat.com/#narrow/stream/237658-MetaCoq/topic/Non-squashed.20typing.20judgments/near/348370245).
       2. Figuring out how to deal with universes / universe polymorphism of typing judgments.
          Roughly the problem is: given the definition of [`quote_prod : (A → Ast.term) → (B → Ast.term) → A × B → Ast.term`](https://github.com/MetaCoq/metacoq/blob/77234210ad9593d7304f9f0d453f70424b2c8f90/quotation/theories/ToPCUIC/Coq/Init.v#L36), how do we formulate the proof that whenever the two arguments always generate well-typed `Ast.term`s, the result of `quote_prod` is also well-typed, given that I may use this across different universes.
          (See also [`qpair_cps`](https://github.com/MetaCoq/metacoq/blob/77234210ad9593d7304f9f0d453f70424b2c8f90/quotation/theories/ToPCUIC/Coq/Init.v#L36) for a slightly simpler version of this problem.)
     + The next major issue after these is likely:
       3. Figuring out how to abstract over Gallina context variables so that we can adequately deduplicate work across safechecker invocations (probably we can turn external quantifications into internal ones and safecheck the abstracted term, but some details need to be worked out).
     + And finally if that's solved, the next two major issues I forsee are:
       4. The axioms used by the various parts of MetaCoq, and whether or not they cause problems when duplicated into the quoted Γ
       5. I'm worry about size of terms and performance a bit, things might be painful.
   <hr>

2. Löb's theorem in MetaCoq: For those who think the above project is not ambitious enough.
   [This Agda code](https://github.com/JasonGross/lawvere/blob/main/src/lob.agda) might be a good reference for how to build the abstractions.
   <hr>

3. Denotation in MetaCoq
   - On pain of inconsistency, we cannot write a function `denote : { T : Ast.term & { t : Ast.term & Σ ;;; [] |- t : T } → { T : Type & T }`.
     I argue in slides 23--28 and 38 of the presentation of [Accelerating Verified-Compiler Development with a Verified Rewriting Engine](https://jasongross.github.io/publications/#rewriting) that it should be possible to paramterize a denotation function over collections in a way that allows effectively having such a denotation function for any subset of the language.
     The domain of any given instantiation of the denotation function would not, of course, include its own quotation, only those of more restrictive families.
     MetaCoq's Template Coq automation could automatically emit specialized instantiations on-the-fly, though, allowing effective use of the denotation function.
     See [this Zulip thread](https://coq.zulipchat.com/#narrow/stream/237658-MetaCoq/topic/Soundness.20vs.20Strong.20Normalization/near/358498103) for some more discussion.
   - Estimated commitment: maybe a couple years?
     Probably PhD-thesis worthy if fully accomplished.
   <hr>

4. Reflective rewriting based on MetaCoq
   - My reflective rewriter ([GitHub](https://github.com/mit-plv/rewriter), [publication](https://jasongross.github.io/publications/#rewriting), [YouTube presentation](https://youtu.be/Ma6olMYe510)) [is very much a research prototype and needs to be rewritten from scratch](https://github.com/mit-plv/rewriter/issues/15).
     The ideas should be generalizable, though, and if MetaCoq can be given an on-the-fly-specializable family of denotation functions from the bullet above, this project could plausibly become a drop-in replacement for the default rewriting in Coq.
   - See slides 26 and 38 of the presentation of [Accelerating Verified-Compiler Development with a Verified Rewriting Engine](https://jasongross.github.io/publications/#rewriting).
   - Estimated commitment: maybe a month to a year on top of denotation in MetaCoq years?
     Very likely PhD-thesis worthy in combination with denotation, if fully accomplished.
   <hr>

5. Integrating abstract interpretation and reflective rewriting
   - See Appendix D, Fusing Compiler Passes, of [the paper](https://arxiv.org/pdf/2205.00862.pdf) [Accelerating Verified-Compiler Development with a Verified Rewriting Engine](https://jasongross.github.io/publications/#rewriting).
   - Estimated commitment: will probably require a rewrite of much of the [12k lines of rewriter code](https://github.com/mit-plv/rewriter/tree/master/src/Rewriter/Rewriter) ([![wakatime](https://wakatime.com/badge/user/0f006c2b-db7d-4bc9-ae89-c8cd8efd2076/project/12593c6a-d428-4f72-857f-025536acf529.svg)](https://wakatime.com/badge/user/0f006c2b-db7d-4bc9-ae89-c8cd8efd2076/project/12593c6a-d428-4f72-857f-025536acf529)) and [4.7k lines of abstract interpretation code](https://github.com/mit-plv/fiat-crypto/tree/master/src/AbstractInterpretation) + design decisions
   <hr>

6. Removing needless non-zero assumptions from Coq's [`ZArith` library](https://coq.inria.fr/library/Coq.ZArith.ZArith.html)
   - Many of the lemmas have premises of the form `x <> 0` even when the conclusion holds without such premises.
     Automating goals in `Z` is much nicer when the relevant lemmas don't require such assumptions.
   - Existing work: [coq/coq#16203](https://github.com/coq/coq/pull/16203) performs this reorganization for `N`, see also [this comment](https://github.com/coq/coq/pull/16203#issuecomment-1702300760)
   - Estimated commitment: the [work on `N`](https://github.com/coq/coq/pull/16203) was +765,-270, the work on `Z` should be 1×--2× as involved
   <hr>

7. Fill out Coq's theory of primitive integers.
   - There's some [work in progress on a theory of integers modulo `n`](https://github.com/coq/coq/pull/17043); I'd love to see this extended/completed and applied to Coq's `Uint63` and `Sint63`.
   - Additionally, it would be nice to have the basic order modules and relation structure (such as transitivity of comparison) filled out.
   - Finally, `zify`, `lia`, and `nia` don't work quite as well on `int` as on `Z`, `N`, `nat`, due to all the moduli.
     It would be nice to figure out an efficient strategy for deciding linear and nonlinear equations modulo a fixed modulus.
   <hr>

8. [Extending printing reduction effects to timing effects.](https://github.com/coq-community/reduction-effects/issues/18)
   - Estimated commitment: 10--100 loc, probably at most a couple days of work
   <hr>

9. [Extending reduction effects to the VM and native compiler.](https://github.com/coq-community/reduction-effects/issues/8)
   <hr>

10. Extending `rewrite_strat` with `cbv` and `lazy` reduction ordering strategies (currently it [supports only `topdown`, `bottomup`, `subterms`, `innermost`, `outermost`](https://coq.inria.fr/refman/addendum/generalized-rewriting.html#definitions)).
    - See [slide 32 of the presentation](https://jasongross.github.io/presentations/itp-2022-rewriting/rewriting.pdf#page=32) of [*Accelerating Verified-Compiler Development with a Verified Rewriting Engine*](https://jasongross.github.io/publications/#rewriting) ([15m50s into the presentation on YouTube](https://youtu.be/Ma6olMYe510?si=M7P99HzCt8rnqC3Q&t=950)) or [page 14 of *Towards a Scalable Proof Engine: A Performant Prototype Rewriting Primitive for Coq*](https://arxiv.org/pdf/2305.02521.pdf#page=14) for some explanation of why we want reduction-ordering for rewriting.
    - Estimated commitment: [the current implementation of `subterm`](https://github.com/coq/coq/blob/a2bf79287d63f437937f3086fe19a72eaae58d96/tactics/rewrite.ml#L990-L1231) is 241 loc, `lazy` is about [150 loc](https://github.com/coq/coq/blob/master/kernel/reduction.ml) + [1250 loc](https://github.com/coq/coq/blob/master/kernel/cClosure.ml), [`cbv` is about 550 loc](https://github.com/coq/coq/blob/master/pretyping/cbv.ml).
      Adapting `rewrite_strat` will probably take a 0.5--3 hours of designing how reduction ordering should work in theory, and then some amount of implementation time (depending on how much code can be reused, how much has to be redone from scratch, how long it takes to understand the existing code, etc).
    <hr>

11. [Explore the idea of proving that the image under denotation of the reduction relation of a dependently typed λ calculus satisfies K.](https://homotopytypetheory.org/2014/03/03/hott-should-eat-itself/#comment-198202)
    - Estimated commitment: maybe a week to a month of coding and exploration to determine whether or not there's an non-trivial obstacle?
    <hr>
