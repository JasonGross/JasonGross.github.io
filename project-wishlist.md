---
layout: page
title: Projects Wishlist
permalink: /project-wishlist/
---

This is a list of projects that I would love to see happen.
Alas, lacking infinite time, I don't have any concrete plans to make them happen, but I'd be happy to advise others undertaking these projects.
Some of these might serve as good bachelor's or master's thesis projects, while others are likely too ambitious or not adequately ambitious.
I've included estimates of how much work I think each project would take *me*, so adjust accordingly for your greater or lesser experience with the domain.

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

2. Löb's theorem in MetaCoq: For those who thing the above project is not ambitious enough.
   [This Agda code](https://github.com/JasonGross/lawvere/blob/main/src/lob.agda) might be a good reference for how to build the abstractions.

3. [Denotation in MetaCoq](https://coq.zulipchat.com/#narrow/stream/237658-MetaCoq/topic/Soundness.20vs.20Strong.20Normalization/near/358498103)

4. Reflective rewriting based on MetaCoq.
   See slides 26 and 38 of the presentation of [Accelerating Verified-Compiler Development with a Verified Rewriting Engine](https://jasongross.github.io/publications/#rewriting).

5. Integrating abstract interpretation and reflective rewriting.
   See Appendix D, Fusing Compiler Passes, of [the paper](https://arxiv.org/pdf/2205.00862.pdf) [Accelerating Verified-Compiler Development with a Verified Rewriting Engine](https://jasongross.github.io/publications/#rewriting).

6. [Removing needless non-zero assumptions from Coq's `ZArith` library.](https://github.com/coq/coq/pull/16203#issuecomment-1702300760)

7. Fill out Coq's theory of primitive integers.
   There's some [work in progress on a theory of integers modulo `n`](https://github.com/coq/coq/pull/17043); I'd love to see this extended and applied to Coq's `Uint63` and `Sint63`.
   Additionally, it would be nice to have the basic order modules and relation structure (such as transitivity of comparison) filled out.

8. [Extending printing reduction effects to timing effects.](https://github.com/coq-community/reduction-effects/issues/18)
<!--   - Estimated commitment: -->

9. [Extending reduction effects to the VM and native compiler.](https://github.com/coq-community/reduction-effects/issues/8)

10. Extending `rewrite_strat` with `cbv` and `lazy` reduction ordering strategies.

11. Extending the Ltac Profiler to Ltac2.
