Thank you all for the feedback; we really appreciate it.

It's now clear that one of the most subtle parts of Lӧb's theorem is distinguishing between semantics, syntax, quoted syntax, and doubly-quoted syntax, and that our paper does not make it easy enough to make these distinctions; we will edit the paper to do far more hand-holding here, and will drop the cute notations that blur this distinction.  The points about cute notations and magic tricks, and about consistently using the same words for the same concepts, are well-taken, and we will fix these things.

The suggestion to begin with the Y combinator is a good one; thank you reviewers B and C!

We now realize that the traditional presentation of Curry-Howard is classical and identifies provability with truth; to extend it neatly to talking about provability logic in a computational manner, we've presented it in from within the lens of Brouwer’s intuitionism; we will clarify our use of the word "truth".

Reviewer-specific responses, followed by an appendix of reviewer-specific responses that didn't fit in the first 500 words.

========================

Reviewer A:
------------------------

Indeed, it seems impossible at first glance to prove Lӧb's theorem without some sort of `QUINE` primitive.  But it turns out it is possible!  Section 10 sketches how to do this, and we flesh it out for those interested in the supplemental material.

Your point about cute names is well-taken, and the use of capitalization to distinguish the syntax for types from the syntax for terms, and using names rather than symbols to distinguish syntax from semantics, are both great ideas.

========================

Reviewer B:
------------------------

- The Y combinator is unsound in a proof assistant; non-termination leads to proofs of false.  Indeed, Lӧb's theorem is nothing but a variant of the Y combinator with (un)quoting, *which implicitly forbids infinite loops*.  We will make clear that this paper is implementing this variant of the Y combinator in varying degrees of detail, in a way that is terminating-by-construction.

- The type `□ (‘□’ X ‘→’ X) → □ X` corresponds to the deduction rule "from `⊢ □ X → X`, we deduce `⊢ X`".  An alternative would be "`⊢ □ (□ X → X) → □ X`".


========================

Reviewer C:
------------------------

If we understand correctly, you want to see us separate the proof of Lӧb's theorem from its semantics, using a variant of S4.

This is a good idea, and we may replace the section that assumes a quine with this formalization (see the appendix to this note for a 40 line version).

- We assumed that for those unfamiliar with encodings of type theory in type theory, working with strings and string replacement and quotation in Python would be more familiar than working with quotation and substitution on abstract syntax trees.  We acknowledge that it might be clearer to present the quotation operation from scratch, rather than relying on intuition from Python.  (Note that internally implementing quotation on well-typed syntax trees is, as far as we are aware, still an open problem, implementation-wise.)

========================
Appendix
========================

========================

Reviewer A:
------------------------

I'm a bit confused by your second bit of code; the type of `LÖB` should be `EXP → EXP`, and `löb` should have type

```
löb : {T : TYP} {interp : EXP} → interp ∶ (ARR (BOX T) T) → (LÖB interp ∶ T)
```

Your hole can be filled with `Σ EXP (λ e → e ∶ T)`, and the denotation function for `EXP` is the same as in your first block of code.

What you are doing here, I think, is separating raw terms from their typing judgments.  What we do is remove the `LÖB` primitive and reimplement it using a `QUINE` primitive, and then sketch how that can be removed entirely.


We'd be curious to see these references in the context of quantum computation; I've not seen any physical interpretation of the modal □ operator.


========================

Reviewer B:
------------------------

- The proof of Lӧb's theorem uses self-reference in an essential way; it results from analyzing the self-referential sentence "If this sentence is provable, then A".  We explain that this is used to prove Lӧb's theorem in the second-to-last paragraph in the introduction, containing "This, in a nutshell, is Löb’s theorem."  We'd very much appreciate suggestions on what made this unclear.

- Thank you for the suggestions about unifying the synonyms and clarifying types where they are not obvious; we'll do this.

- The relation between the program `Lob(X)` on page 2 and `□(□A → A) → □A` is that `Lob(X)` is the key ingredient of the proof of Löb’s theorem; it is the type corresponding to the sentence "If this sentence is provable, then A" which is mentioned above.

- Interpreting `□A` as `1 → A` does not fix the termination problem.  It is possible to have a total language with a Löbian combinator `(□A → A) → A` if we interpret `□A` as syntax, but if we interpret it as `1 → A`, we get `((1 → A) → A) → A`, which is just the Y combinator.  Said another way, `1 → A` suspends computation at *runtime*, but to make Lӧb's theorem work, we must suspend computation at *compile-time*.

- Regarding `repr`, we can *add* a level of quotation to anything that's already quoted.  We plan to make it easier to see at a glance the distinction between semantics, (singly-quoted) syntax, and (doubly) quoted syntax.

- Regarding "There is no syntactic proof of absurdity", we again need to make clearer the distinction between syntax and semantics.  Agda has no proof of absurdity.  If we build our syntax in a stupid way, we might permit a syntactic proof of absurdity in the object language (which is not the full extent of Agda, and which we have no guarantee is identical to a subset of Agda); we must prove that it is impossible to derive contradictions in our object language.

- Regarding the footnote, `□(□X → X) → □X` is a valid expression of the type of Lӧb's theorem, but it's not a valid type for a constructor of an inductive datatype `□`, again for termination (positivity) reasons.

- Thank you for the feedback on the Prisoner's dilemma section; we will add a bit more exposition to make it more self-contained.

- Agda does not have a notion of truth distinct from provability; this is what we meant by "banish [the word] 'truth'".  We will add more hand-holding here; the reason to talk about "provability" is that it is extremely confusing to say "P is false, and 'P is false' is false" while it is only mildly confusing to say "we can prove that P is absurd, but we can also prove that proving "WE CAN PROVE THAT P IS ABSURD" is absurd".


========================

Reviewer C:
------------------------

The formalization and semantics of S4, specializing the quine/fixed-point theorem to the Lӧbian sentence.  We may use this to replace the formalization based on the Quine primitive (obviously with added explanation of the Lӧb′s-Theorem proof term).

```
data TYP : Set where
  ARR : TYP → TYP → TYP -- the type of implications, or function types
  BOX : TYP → TYP -- the modal □ operator, denoted to TERM
  LӦB-SENTENCE : TYP → TYP -- the Lӧbian sentence "If this sentence is provable, then A"
                           -- this is the modal fixpoint of λ Ψ. □ Ψ → A

data TERM : TYP → Set where
  nec : {A : TYP} → TERM A → TERM (BOX A)                                             -- from A, we deduce □ A
  distr : {A B : TYP} → TERM (ARR (BOX (ARR A B)) (ARR (BOX A) (BOX B)))              -- we deduce □ (A → B) → □ A → □ B
  s4 : {A : TYP} → TERM (ARR (BOX A) (BOX (BOX A)))                                   -- we deduce □ A →  □ □ A
  app : {A B : TYP} → TERM (ARR A B) → TERM A → TERM B                                -- from A → B, and A, we deduce B
  lӧb→ : {A : TYP} → TERM (ARR (LӦB-SENTENCE A) (ARR (BOX (LӦB-SENTENCE A)) A))       -- LӦB-SENTENCE A is Ψ such that Ψ → (□ Ψ → A)
  lӧb← : {A : TYP} → TERM (ARR (ARR (BOX (LӦB-SENTENCE A)) A) (LӦB-SENTENCE A))       -- LӦB-SENTENCE A is Ψ such that (□ Ψ → A) → Ψ
  compose : {A B C : TYP} → TERM (ARR A B) → TERM (ARR B C) → TERM (ARR A C)          -- from A → B and B → C, we deduce A → C
  compose2 : {A B C : TYP} → TERM (ARR A B) → TERM (ARR A (ARR B C)) → TERM (ARR A C) -- from A → B and A → B → C, we deduce A → C

Lӧb′s-Theorem : {A : TYP} → TERM (ARR (BOX A) A) → TERM A -- from □ A → A, we deduce A
Lӧb′s-Theorem {A} refl-rule = app prog (nec (app lӧb← prog))
  where prog : TERM (ARR (BOX (LӦB-SENTENCE A)) A)
        prog = compose (compose2 s4 (compose (app distr (nec lӧb→)) distr)) refl-rule

⟦_⟧ᵀ : TYP → Set
⟦ ARR A B ⟧ᵀ = ⟦ A ⟧ᵀ → ⟦ B ⟧ᵀ
⟦ BOX T ⟧ᵀ = TERM T
⟦ LӦB-SENTENCE A ⟧ᵀ = TERM (LӦB-SENTENCE A) → ⟦ A ⟧ᵀ

⟦_⟧ᵗ : {T : TYP} → TERM T → ⟦ T ⟧ᵀ
⟦ nec e ⟧ᵗ = e
⟦ distr ⟧ᵗ box-a-b box-a = app box-a-b box-a
⟦ s4 ⟧ᵗ = nec
⟦ app f x ⟧ᵗ = ⟦ f ⟧ᵗ ⟦ x ⟧ᵗ
⟦ lӧb→ ⟧ᵗ = λ x → x -- this implication is true because on denotation, the two are judgmentally equal
⟦ lӧb← ⟧ᵗ = λ x → x -- this implication is true because on denotation, the two are judgmentally equal
⟦ compose f g ⟧ᵗ = λ x → ⟦ g ⟧ᵗ (⟦ f ⟧ᵗ x)
⟦ compose2 f g ⟧ᵗ = λ x → ⟦ g ⟧ᵗ x (⟦ f ⟧ᵗ x)
```


- Section 3 is intended to be a crash course in formalizing the syntax and semantics of type theory for those who have not seen it before.  Perhaps your point is that it does not provide enough explanation for those unfamiliar with it, that it is (intentionally) irrelevant for those familiar with formalizing type theory in type theory, and that what little content in the section falls into neither category should be merged into the other sections, to improve flow.  This is a good point.
