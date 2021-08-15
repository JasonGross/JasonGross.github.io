===========================================================================
                           ICFP 2016 Review #14A
---------------------------------------------------------------------------
Paper #14: Lӧb's Theorem: A functional pearl of dependently typed quining
---------------------------------------------------------------------------

                      Overall merit: B. OK paper, but I will not champion
                                        it
                         Confidence: Y. I am knowledgeable in this area,
                                        but not an expert

                         ===== Paper summary =====

The paper is about self-reference but in a very specific computational way distinguishing truth and provability. The main results are various variations on proofs of Lob's theorem.

                      ===== Comments for author =====

The paper is a pearl: it can be read in a semi-casual way that still provides some thought-provoking insights. I feel the more detailed technical reading is somewhat inaccessible: even though I am fairly conversant in language semantics, logic, Curry-Howard, and Agda, I found the presentation to be difficult to follow. In fact, I initially thought I would be able to rate my confidence as X but after reading and re-reading the paper, I downgraded to Y to reflect my understanding of this specific paper.

The traditional presentation of the Curry-Howard isomorphism does not distinguish truth from provability. I think it would be beneficial to have a few sentences discussing this. For example, in the traditional presentation, boolean conjunction would correspond to \x.\y.(x,y) where we have blurred the distinction between truth and provability. In this paper, we would use some encoding of ASTs and separately evaluate it to get \x.\y.(x,y). I would have find this introductory approach more suitable than the Python presentation which has to rely on hypothetical Python pi-types etc.

In the last line of [[_]]t (sec. 3) it would be clearer to have an explicit lambda in the rhs.

I spent some time trying to reconstruct the 'trivial' encoding in a way that would be understandable to me. I started with using less 'cute' names:

```
  data TYP : Set where
    ARR : TYP → TYP → TYP
    BOX : TYP → TYP

  data □ : TYP → Set where
    Löb : {T : TYP} → □ (ARR (BOX T) T) → □ T

  ⟦_⟧ᵀ : TYP → Set
  ⟦ ARR A B ⟧ᵀ = ⟦ A ⟧ᵀ → ⟦ B ⟧ᵀ
  ⟦ BOX T ⟧ᵀ = □ T

  ⟦_⟧ᵗ : {T : TYP} → □ T → ⟦ T ⟧ᵀ
  ⟦ Löb ABT ⟧ᵗ = ⟦ ABT ⟧ᵗ (Löb ABT)

  löb : {T : TYP} → □ (ARR (BOX T) T) → ⟦ T ⟧ᵀ
  löb f = ⟦ Löb f ⟧ᵗ
```

which was a bit easier to read. My next step was to try to interpret Box as Terms as mentioned in the paper. I started working as follows:

```
 data EXP : Set where
    LÖB : EXP
    QUO : EXP → EXP
    APP : EXP → EXP → EXP

  data _∶_ : EXP → TYP → Set where
    löb : {T : TYP} → (LÖB ∶ ARR (BOX T) T)
    quo : {T : TYP} {e : EXP} → (e ∶ T) → (QUO e ∶ BOX T)
    app : {T₁ T₂ : TYP} {e₁ e₂ : EXP} → (e₁ ∶ ARR T₁ T₂) → (e₂ ∶ T₁) → (APP e₁ e₂ ∶ T₂)

  ⟦_⟧ᵀ : TYP → Set
  ⟦ ARR A B ⟧ᵀ = ⟦ A ⟧ᵀ → ⟦ B ⟧ᵀ
  ⟦ BOX T ⟧ᵀ = {!!}
```

and after thinking about it for a while, I think I understood that I was trying to reconstruct the rest of the paper. Sure enough I think the rest of the paper is essentially trying to do what I was trying to do above and it does indeed appear impossible without some primitive like QUINE.

I might be completely missing the point but if what I am saying is sensible, PLEASE make an effort to rewrite the paper in a way that minimizes the mental jumps.

Finally since the paper is partly philosophical in some sense, may I ask if Lob's theorem has any physical interpretations? I have seen reference to it in the context of quantum computing which may be relevant and/or interesting.






===========================================================================
                           ICFP 2016 Review #14B
---------------------------------------------------------------------------
Paper #14: Lӧb's Theorem: A functional pearl of dependently typed quining
---------------------------------------------------------------------------

                      Overall merit: C. Weak paper, though I will not fight
                                        strongly against it
                         Confidence: Y. I am knowledgeable in this area,
                                        but not an expert

                         ===== Paper summary =====

This is a functional pearl about quotation, self-returning programs,
and Loeb's theorem, in Agda.

Loeb's theorem has the form []([]A -> A) -> []A, where the modal type
[]A (box A) is interpreted to mean "A is provable". Thus, if we can
prove A under the assumption of its provability, then we can dispense
with the assumption. Alternatively, if we want to prove A, we can
assume in our proof that A is provable, and go on from there. The
point is (I guess), that from the assumption that A is provable, we
won't be able to derive much about A, so we won't end up using the
assumption.

Inspired by Curry-Howard isomorphism, this paper is attempting to
interpret the provability modality in computational terms, and
consider []A as type of terms representing "syntax" of type A.

It considers some applications of this idea, e.g., to the problem of
Prisoner's Dilemma.

                      ===== Comments for author =====

I think this material has a potential for a pearl, but the writing is
still not quite there. The explanations are not very clear, or at
least not as clear as they should be for a topic of this subtlety. The
paper also lacks examples, beyond Agda definitions. The definitions
are not really properly explained (e.g., the tricky cases discussed),
so I was never quite clear what the given Agda code really achieves in
terms of its relationship to Loeb's theorem. Also, Agda notation needs
explanation for non-Agda users. Either that, or go with some more
intuitive (and less cute) mathematical notation.

Let me list below the places where I could have used more explanation
and hand holding.

- Initially, it doesn't come off very clearly just what is the
  connection between Loeb's theorem and self-reference. We do see that
  it captures Goedel's incompleteness theorem by instantiating A with
  false, so, yes, something is afoot. But, it's not clear just what. I
  found myself having that question throughout later sections as well.

- It would be useful to put types into the self-returning Python
  program. Maybe that will deviate from Python's syntax, but it's
  helpful to see them. E.g.,

  (\t : string. t % repr t) "\t : string. t % repr t (%s)"

  indeed evaluates to a string quotation of itself:

  "(\t : string. t % repr t) "\t : string. t % repr t (%s)""

  In general, maybe it would be somewhat clearer to use the phrase "a
  string quotation of the program", instead of "outputing it's own
  source code". I mean, in ML, if I type 3 at the prompt, I will get 3
  at the output, so, strictly speaking, the program 3 *is* outputing
  its own source code. But that program wouldn't qualify here, since
  we actually want to get a string back. So maybe just use the word
  "string" explicitly to put the reader into the right mindset.

- In general, the paper uses many synonyms for syntax (e.g., source
  code, string), and many synonyms for semantics (e.g., evaluation,
  representation, etc.) This can get confusing, so please fix one word
  for each and stick with it.

- Also, maybe give a definition, or at least the type of repr; i.e.,
  it's a function that takes a string, and returns the same string,
  but with one layer of quotes around it. I saw later on in Section 6,
  that repr will have the type []A -> [][]A (i.e., axiom 4 of modal
  logic). So maybe mention that too.

- It wasn't described in Section 2 why give the name Lob(X) to the
  program on page 2. What does this program have to do with the type
  [] ([]A -> A) -> [ ]A? (I guess this repeats my first question from
  above). Also, I wasn't clear why Lob(\bottom) returns the
  consistency proofs of Martin-Loef's type theory? Why couldn't the
  returned type just be equivalent to false?

- The program Tarski is supposed to illustrate how we loop forever if
  we work with "truth" instead of "provability". But, I wasn't quite
  clear what was it in provability (i.e., quotation) that prevented
  the infinite loop? Is it just that quotes operationally suspend
  execution? Could we then interpret []A to just mean 1 -> A? Why
  bother with syntax? In general, it wasn't clear that []A *has* to be
  syntax, and if it is, what is it that we should ve doing with it to
  connect to Loeb? For example, what we can do with syntax, but can't
  do with general terms, is pattern match over syntax? But, that
  wasn't illustrated in the first 6 sections, so I couldn't tell if
  that's the essence of Loeb's theorem?

  A related question, also related to repr, is: can we make syntax out
  of anything? I.e., what's the distinction between repr t and "t"? Is
  there a type system that will tell us which terms t can be quoted?

- On a related note, self-reference in programming is usually achieved
  using fixed points, and the main example in Section 2 looks *very*
  similar to the Y combinator, only with quotation and unquoting (i.e. repr) thrown in, and
  (self-)substitution instead of (self-)application. But erase those coercions, and you get Y. That makes one
  wonder: is the reliance on syntax to achieve self-reference just an
  unnecessary complication here? If so, what does it tell us
  about Loeb's theorem? I guess it should be clear from Loeb's type (if one just
  removes the boxes from it) that it should act like a fixed point
  combinator. But I didn't really see it explained what exactly Loeb
  gives us that's more than the ordinary fixed point combinator.

- I couldn't really make heads or tails of the statement on page 4,
  second column that:

  -- There is no syntactic proof of absurdity

  I expected absurdity to have no proof whatsoever, syntactic or
  otherwise. This point needs clarification, so it would be good to
  see an example that has no syntactic proof, but that has an ordinary
  proof (or however one's supposed to call the non-syntactic
  entities). How does that chime with Agda, where what's true is identical to what's provable?

- The Section 6 on the Trivial Encoding starts to use two boxes, one
  quoted, one plain. Then it gives a version of Loeb's theorem with
  the form:

   [] ('[]' X '->' X) -> []X

  which mixes up the two. I wasn't clear why we're allowed to mix the
  two, and still name the result Loeb? Then, there's a mysterious
  footnote on page 4, which says that "In conversation with Matt Brown
  [on self-interpreter for F_omega], we found that... the type of
  Loeb's theorem becomes either [] ([]X -> X) -> []X, or ...". I was
  at this point confused why the above would *not* be the type of
  Loeb's theorem (I mean, that's Loeb's theorem, no).

  Also, as I already mentioned before, it doesn't help the explanation
  that the paper uses very liberally the power of Agda notation. For
  example, I can see in Agda one can quote variables (e.g., definition
  of [[_]]^t on page 4). Was that quotation intended to be around X,
  instead of around ->?

- The connection to Prisoner's Dilemma was very unclear to me. The
  author(s) cite a related work (Barasz et al. 2014) which presumably
  explains it all, but I think portions of that other paper ought to
  be included here, to make the presentation self-contained and
  readable.

In summary, the paper is working with a very subtle subject, which is
almost esoteric, as the penultimate paragraph of Section 7
recognizes. The paper does let on (also mentioned in the same
paragraph), that in fact all of the esotery *can* be made very
concrete, by reducing it to programming. But then, it doesn't quite
commit itself to doing such concretization faithfully, and proceeds to
use esoteric and confusing phrases (such as "banishing truth" in the
same paragraph). There is something in this paper, but it needs a lot
of rewriting to make it come out.







===========================================================================
                           ICFP 2016 Review #14C
---------------------------------------------------------------------------
Paper #14: Lӧb's Theorem: A functional pearl of dependently typed quining
---------------------------------------------------------------------------

                      Overall merit: C. Weak paper, though I will not fight
                                        strongly against it
                         Confidence: X. I am an expert in this area

                         ===== Paper summary =====

This paper presents a proof Loeb's theorem formalized in Agda.  The
proof is specialized to the case of syntax trees and
self-representation, which is represented using indexed datatypes to
capture terms well–typed in context.

                      ===== Comments for author =====

Loeb's theorem has been the victim of mystification for a very long
time, and so I hoped that a presentation in type theory could show off
the real simplicity and elegance of the proof. Unfortunately, I do not
think this paper did so.

Fundamentally, the proof of Loeb's theorem has the same structure as
Curry's paradox (i.e., the proof term for Loeb's theorem is a variant
of the Y combinator). Recall that the axioms of provability logic
correspond to an S4 box operator, *minus* the reflexivity axiom □A ⊢
A. If this axiom were valid, then you could take a modal fixed point
(i.e, μa.X(a) ≃ X[□μa.X(a)/a]) and then follow the derivation of the Y
combinator exactly, using a recursive type like μa. a → X, plus a
little massaging to manage the boxes. Loeb's theorem then amounts to
saying that if the reflexivity rule is valid for a type (i.e., □(□X →
X)), then you can use the fixed point operator to pick out an X.  This
works for any functorial modal operator □A which is a monoidal wrt to
the Cartesian product, which also has modal fixed points.  Then you
could instantiate □ with many possibilities, including syntax, with
Loeb's theorem separated from questions of representation.

Overall, I thought that (a) this paper tried too hard to present
Loeb's theorem as a magic trick, rather than presenting its proof as
cleanly as possible, and (b) it failed to factor the proof well
enough for me to be comfortable calling it a pearl.


Notes:

- Section 2 is a mess. It needs to be rewritten to be much more
  focused on how quotation works. It is also on a tangent to the
  main development in the paper, which uses syntax trees rather
  than strings.

- Section 3 is basically irrelevant to the development in the paper.
  It could be deleted without affecting the readability at all.

- The "trivial encoding" in section 6 is indeed trivial -- the
  datatype Type has no inhabitants! You need at least one base type
  to make the datatype inhabited....

- Section 9 is very nice; it should not be a digression, but the
  punchline of the paper.
