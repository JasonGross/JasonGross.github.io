---
layout: page
title: Projects
permalink: /projects/
---

## Current Projects

- [Compact Proofs of Model Performance via Mechanistic Interpretability]({{ "/publications/" | relative_url }}#compact-proofs) (2023--2024)
- [Numerical integration in toy transformers]({{ "/publications/" | relative_url }}#numerical-integration-mi-workshop-2024) (2024--)
- Fine-tuning toy transformers on differentiable proof bounds (2024--)
- Mech interp / AI R&D evals project

## Pending Projects

### 2024

- Extensions of numerical integration in toy transformers:
  - Building on [Not All Language Model Features Are Linear](https://arxiv.org/abs/2405.14860), do we find numerical integration in small LLMs, such as Lamma 7B / Mistral 8B?
  - What exactly is going on in the "clock" algorithm?
  - Building on [Unifying and Verifying Mechanistic Interpretations: A Case Study with Group Operations]({{ "/publications/" | relative_url }}wu2024unifyingverifyingmechanisticinterpretations), it seems that change of variables in integration corresponds to neuron reindexing, and that shift of integration limits corresponds to a symmetry of the MLP.
    Does this technique generalize to demonstrate how it might be relatively unimportant what non-linear activation is used?
    - In particular, we have $\int_{-\pi}^{\pi} \mathrm{d}\phi\,\cos(kc+2\phi)\mathrm{ReLU}\left[\cos({\textstyle \frac{k}{2}}(a-b))\cos({\textstyle \frac{k}{2}}(a+b) + \phi)\right]$ or, simplified, we are looking at $\int_{-\pi}^{\pi}\mathrm{d}\phi \,\cos(2\phi)\left|\cos(\phi + a+b)\cos(a-b)\right|$.
      Change of variables gives $\int_{a+b-\pi}^{a+b+\pi}\mathrm{d}\psi \,\cos(2\psi-2(a+b))\left|\cos(\psi)\cos(a-b)\right|$, and symmetry gives $\int_{-\pi}^{\pi}\mathrm{d}\psi \,\cos(2\psi-2(a+b))\left|\cos(\psi)\cos(a-b)\right|$.
      Here the dependence on $a+b$ has been taken out from under the activation, and the activation is now only a scaling factor varying over irrelevant axes.
- Arguing that fine-tuning should work even when we have multiple algorithms that are competing and therefore that we can't fully drive to zero without destroying behavior:
  - Insofar as we believe in something like linear representation, we should expect that distinct features / circuits are nearly orthogonal.
  - The easy case (as in the min&max model) is when we can have them be "fully orthogonal".
  - The thing that is hard for proofs in general seems to be when the random case is enough on average.
    (EVOU in Max-of-$K$ is already a good example of this)
  - If we can replace "random" with "systematically coded to be uniform", then we should be able to make a proof go through, and fine-tuning should not impact behavior too much.
  - Notes on targeting this via a linear-in-parameter-count proof of Max-of-$K$:
      - Counting should look at distinguishing based only on the max token, each max should have a largest permissible non-max token.
      - We drop the counting based on number of copies of non-max (or we fold it into proof search, having a # copies max table indexed on max token).
      - The query direction is approximated as uniform rather than just rank 1.
      - I'm not 100% sure how to get `d_vocab · d_model` instead of `d_vocab · d_model + d_model³`, but we can do this version by treating `E`,`VOU` (or `EVO`, `U`, or `EV`, `OU`) as transposed embeddings on hypercube corners.
      - I guess maybe the thing to do is to train orthogonal matrices to bring the output of `E` to be as close to hypercube corners as possible, and then modify the model by inserting this matrix and its inverse around `E`, `Q`, `K`, `V`, `O`, and `U`, so that the overall equation of the model is unchanged.
      - Then we can fine-tune this new model on a proof that computes divergence from the hypercube, represent `V` and `O` as scaled permutation + error?
      - And we'll probably start off with something that is basically vacuous, but the hope is that we'll get near 100% acc by the end of training.
- Proofy mech interp bounds as a metric on SAEs
- [Partial list of possible extensions to the proofy mech interp agenda](https://docs.google.com/document/d/1bt1Rj_K6PkT9fDTpZES9ctGPnyGSPephB00pbgoiuog/edit#heading=h.qskmoqbfj7mn)
- [Synthetic Proof-Repair Data Generation via Denoising](https://docs.google.com/document/d/1R4HkreEUVLn1_LavdkigXIthwZbs4unNEWCTibWuhOk/) (aka bootstrapping open-source AlphaProof)
- [Using mech interp / proofs / SAEs to suppress back doors](https://docs.google.com/document/d/1wX0yzpU0pi-CQN7KoImvIVLqN43WY-Kcsi89xmtDS1s/)
- In the path decomposition of a model, can we suppress the exponential in # of layers by clever sharing of irrelevant terms?

## Semi-abandoned Projects

- Using prediction markets for coordination in the prisoner's dilemma (2022) (draft available upon request)
- Generalizing Lawvere's Fixpoint Theorem to handle Löb's Theorem (2023) (draft available upon request) (code [here](https://github.com/JasonGross/lawvere) and [here](https://github.com/JasonGross/lob))
- Why Infinite Recursions Are At Most Three Levels Deep: A Löbian Analysis (2023) (draft available upon request)

## Past Projects

This section is very incomplete.

- [Reflective rewriting in Coq](https://github.com/mit-plv/rewriter/) (2016--2019, still sparsely maintained)
- [Fiat Cryptography](https://github.com/mit-plv/fiat-crypto/) (2016-- ≈2022, still sparsely maintained)
- [Coq Bug Minimizer](https://github.com/JasonGross/coq-tools) (2013-- ≈2021, still sparsely maintained and improved)
- [Category Theory and Homotopy Type Theory, in Coq](https://github.com/HoTT/Coq-HoTT/tree/master/theories/Categories) (2012--2014, still sparsely maintained)
- [Fiat − Deductive Synthesis of Abstract Data Types in a Proof Assistant](https://github.com/mit-plv/fiat) (2013--2017)

## Past Microprojects

- [Draft syllabus for "Universal Properties, Abstraction Barriers, Isomorphism Invariance, and Homotopy Type Theory"](https://web.mit.edu/jgross/Public/KTCP/2020-09-30-syllabus-and-unit.pdf) (2020 Fall)
- [Some very short essays](https://web.mit.edu/jgross/Public/stories/) (2010--2019, very occasionally added to)
- [Nonstandard musical composition](https://web.mit.edu/jgross/Public/21M.065/) (2012 Spring)
- [Vocabulary tester, a la Anki](https://scripts.mit.edu/~jgross/tester/) ([git](https://github.com/JasonGross/tester)) (2011--2013)
- [A writeup of the uncountability of the reals, targeted at three audiences of different levels](https://web.mit.edu/jgross/Public/18.100C_paper_newest.pdf) (2011 Nov)
- [Short definitions of various emotions and musings on social dynamics](https://web.mit.edu/jgross/Public/social-interactions/) (2011--2012, occasionally updated)
- [Writeup of quantum decoherence](https://web.mit.edu/jgross/Public/8_06-decoherence-paper.pdf) (2012 May)
- [Derivation of the Principle of Least Action](https://web.mit.edu/jgross/Public/least_action/Principle%20of%20Least%20Action%20with%20Derivation.html) ([pdf](https://web.mit.edu/jgross/Public/least_action/Principle%20of%20Least%20Action.pdf)) (2010 Dec)
- [A note on ADHD](https://web.mit.edu/jgross/Public/high-school-writing/most-important-event-adhd.txt) (2006 Nov)
- [A solver](https://web.mit.edu/jgross/Public/math24/) for [Math 24](https://www.24game.com/) (2005)