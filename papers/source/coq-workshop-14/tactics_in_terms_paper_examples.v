(* -*- mode: coq; coq-prog-args: ("-emacs"); coq-prog-name: "coqtop-trunk" -*- *)
(** * Tactics in terms: *)
Definition I_am_one : nat := $(let x := constr:(2 - 1) in
                               exact x)$.
Print I_am_one.
(** I_am_one = 2 - 1
      : nat *)
Definition I_am_exactly_one : nat := $(let x := constr:(2 - 1) in
                                       let y := (eval compute in x) in
                                       exact y)$.
Print I_am_exactly_one.
(** I_am_exactly_one = 1
      : nat *)

(** * Recursive Tactics *)
Ltac ret_and_left f :=
  let tac := ret_and_left in
  let T := type of f in
  match eval hnf in T with
    | ?a /\ ?b => exact (proj1 f)
    | ?T' -> _ =>
      let ret := constr:(fun x' : T' => let fx := f x' in
                                        $(tac fx)$) in
      let ret' := (eval cbv zeta in ret) in
      exact ret'
  end.

Goal forall A B : Prop, (A -> A -> A -> A /\ B) -> True.
  intros A B H.
  pose $(ret_and_left H)$.
  (** [fun x' x'0 : A => proj1 (H x' x'0) : A -> A -> A] *)
Admitted.

(** * Overloading Notations *)
(** ** Simple example *)
Parameters T₁ T₂ T₃ : Type.
Parameter F : T₁ -> T₃.
Parameter G : T₂ -> T₃.
Parameters (t₁ : T₁) (t₂ : T₂).

Class MyNotation {A R} (a : A) (r : R) := {}.
Definition mynotation A R a r `{@MyNotation A R a r} := r.
Instance MyF x : MyNotation x (F x) | 10.
Instance MyG x : MyNotation x (G x) | 100.

Notation "% x"
  := ($(let ret := constr:(@mynotation _ _ x _ _) in
        let ret' := (eval cbv beta delta [mynotation] in ret) in
        exact ret')$)
       (at level 40, only parsing).
Check (% t₁). (** F t₁ : T₃ *)
Check (% t₂). (** G t₂ : T₃ *)


(** ** Composition *)
Parameter Compose11 : T₁ -> T₁ -> T₁.
Parameter Compose12 : T₁ -> T₂ -> T₁.
Parameter Compose21 : T₂ -> T₁ -> T₁.
Parameter Compose22 : T₂ -> T₂ -> T₂.

(** Represents the assertion that [a ∘ b = c] *)
Class ComposeTo {A B C} (a : A) (b : B) (c : C) := {}.
Definition composition A B C a b c `{@ComposeTo A B C a b c} := c.
Instance ComposeTo11 x y : ComposeTo x y (Compose11 x y) | 10.
Instance ComposeTo12 x y : ComposeTo x y (Compose12 x y) | 100.
Instance ComposeTo21 x y : ComposeTo x y (Compose21 x y) | 100.
Instance ComposeTo22 x y : ComposeTo x y (Compose22 x y) | 1000.

Reserved Infix "∘" (at level 40, left associativity).
(** Uncomment these for displaying the notations *)
(**
Infix "∘" := Compose11.
Infix "∘" := Compose12.
Infix "∘" := Compose21.
Infix "∘" := Compose22.
*)
Notation "x ∘ y"
  := ($(let ret := constr:(@composition _ _ _ x y _ _) in
        let ret' := (eval cbv beta delta [composition] in ret) in
        exact ret')$)
       (only parsing).

Check (t₁ ∘ t₁). (** Compose11 t₁ t₁ : T₁ *)
Check (t₁ ∘ t₂). (** Compose12 t₁ t₂ : T₁ *)
Check (t₂ ∘ t₁). (** Compose21 t₁ t₁ : T₁ *)
Check (t₂ ∘ t₂). (** Compose22 t₂ t₂ : T₂ *)

(** * Universe Polymorphism *)

Set Universe Polymorphism.
Set Printing Universes.
Inductive eq {A} (x : A) : A -> Set := eq_refl : eq x x.
Notation "x = y :> A" := (@eq A x y) : type_scope.
Notation "x = y" := (x = y :> _) : type_scope.
Definition Lift
: $(let U1 := constr:(Type) in
    let U0 := constr:(Type : U1) in
    let U0' := (eval simpl in U0) in
    exact (U0' -> U1))$
  := fun A => A.
Check Lift. (**
Lift (* Top.5 Top.6 Top.7 *)
     : Type (* Top.7 *) -> Type (* Top.6 *)
(* Top.7
   Top.5
   Top.6 |= Top.7 < Top.5
             Top.7 < Top.6
             Top.6 < Top.5
              *) *)
Definition lift_eq {T x y} (p : x = y :> T) : x = y :> Lift T
  := match p with eq_refl _ => eq_refl _ end.

Definition NaiveFunext := forall A P (f g : forall x : A, P x),
                            (forall x, f x = g x :> P x) -> f = g.

Definition funext_downward_closed
: NaiveFunext -> NaiveFunext
  := fun fs A P f g H
     => lift_eq (fs (Lift A) (fun x => Lift (P x))
                    f g
                    (fun x => lift_eq (H x))).

Goal forall x y : NaiveFunext, x = y.
Proof.
  intros x y; hnf in x, y.
  (*Fail*) apply x. (** universe inconsistency *)
  admit.
Abort.

Goal forall x y : NaiveFunext, funext_downward_closed x = funext_downward_closed y.
Proof.
  intros x y; hnf in x, y.
  apply x. (** success *)
  admit.
(*Defined.*)
Abort.
