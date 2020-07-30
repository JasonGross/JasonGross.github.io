(* -*- mode: coq; coq-prog-args: ("-emacs"); coq-prog-name: "./coqtop-trunk.bat" -*- *)
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

Definition I_am_exactly_two : nat := S $(let x := constr:(2 - 1) in
                                         let y := (eval compute in x) in
                                         exact y)$.
Print I_am_exactly_two.

(** * Recursing under binders *)
(** Tactics in terms allow one to recurse under binders. *)

(** * Recursive Tactics *)
(** Simple example that demos the feature, returning the left branch of a conjunction *)

(*forall a b, a /\ b.*)
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

(** ** [hnf] *)
(** Have you ever wished that [hnf] didn't stop at function abstraction? *)

Ltac do_under_binders tac term := constr:(fun y => $(let z := tac (term y) in exact z)$).
(*
Ltac rewrite_under_binders term lem := constr:(fun y =>
                                                 $(let H := fresh in
                                                   pose (term y) as H;
                                                   rewrite lem in H;
                                                   exact H)$).

Goal (forall x : nat, x + 1 = 1 + x) -> False.
  intro H.
  re
*)

Ltac hnf_under_binders term := do_under_binders ltac:(fun x => eval hnf in x) term.
Ltac hnf_under_all_binders term :=
  match term with
    | _ => do_under_binders hnf_under_all_binders term
    | _ => eval hnf in term
  end.

Definition unfold_me := 1.
Definition unfold_me_too := unfold_me.

Goal True.
  let x := hnf_under_binders (fun x : Type => unfold_me_too) in
  pose x.
  let x := hnf_under_binders (fun x y z w : Type => unfold_me_too) in
  pose x.
  let x := hnf_under_all_binders (fun x y z w : Type => unfold_me_too) in
  pose x.
Abort.

(** We could have done this in 8.4, using typeclasses, but it's more verbose, has more boilerplate, and is less general *)

Class hnf_under_binders_helper {T P} (y : T) (z : P y)
  := make_hnf_under_binders_helper : P y.
Arguments hnf_under_binders_helper {T P} y z / .
Hint Extern 0 (hnf_under_binders_helper ?y ?z)
=> let z' := (eval hnf in z) in exact z' : typeclass_instances.

Ltac hnf_under_binders_84 x :=
  let x' := constr:(fun y => _ : hnf_under_binders_helper y (x y)) in
  let x'' := (eval unfold hnf_under_binders_helper in x') in
  constr:(x'').

Goal True.
  let x := hnf_under_binders_84 (fun x : Type => unfold_me_too) in
  pose x.
Abort.


(** ** Apply under binders *)

Ltac make_apply_under_binders_in lem H :=
  let tac := make_apply_under_binders_in in
  match type of H with
    | forall x : ?T, @?P x
      => let ret := constr:(fun x' : T =>
                              let Hx := H x' in
                              $(let ret' := tac lem Hx in
                                exact ret')$) in
         let ret' := (eval cbv zeta in ret) in
         constr:(ret')
    | _ => let ret := constr:($(let H' := fresh in
                                pose H as H';
                                apply lem in H';
                                exact H')$) in
           let ret' := (eval cbv beta zeta in ret) in
           constr:(ret')
  end.

Tactic Notation "binder_apply" open_constr(lem) "in" hyp(H) :=
  let H' := make_apply_under_binders_in lem H in
  let H'' := fresh in
  pose proof H' as H'';
    clear H;
    rename H'' into H.

Require Import FunctionalExtensionality.

Goal forall A B P (f g : forall (x : A) (y : B x), P x y), (forall x y, f x y = g x y) -> f = g.
Proof.
  intros A B P f g H.
  eapply @functional_extensionality_dep in H.
  Undo.
  binder_apply @functional_extensionality_dep in H.
  binder_apply @functional_extensionality_dep in H.
  exact H.
Defined.

(** We can do this, too, in 8.4, with some specialized typeclasses and verbosity *)
Class make_apply_under_binders_in_helper {T} (lem : T) {T'} (H : T') {T''} := do_make_apply_under_binders_in_helper : T''.

Class make_apply_under_binders_in_helper_helper {T} (H : T) {T'} (lem : T') {T''} := do_make_apply_under_binders_in_helper_helper : T''.

Hint Extern 0 (make_apply_under_binders_in_helper_helper ?H ?lem)
=> let H' := fresh in
   pose H as H';
     apply lem in H';
     exact H'
           : typeclass_instances.

Ltac make_apply_under_binders_in_84 lem H :=
  match type of H with
    | forall x : ?T, @?P x
      => let ret := constr:(fun x' : T =>
                              let Hx := H x' in
                              _ : make_apply_under_binders_in_helper lem Hx) in
         let ret' := (eval cbv zeta beta delta [do_make_apply_under_binders_in_helper make_apply_under_binders_in_helper] in ret) in
         let retT := type of ret' in
         let retT' := (eval cbv zeta beta delta [do_make_apply_under_binders_in_helper make_apply_under_binders_in_helper] in retT) in
         constr:(ret' : retT')
    | _ => let ret := constr:(_ : make_apply_under_binders_in_helper_helper H lem) in
           let ret' := (eval cbv beta zeta delta [make_apply_under_binders_in_helper_helper do_make_apply_under_binders_in_helper_helper] in ret) in
           let retT := type of ret' in
           let retT' := (eval cbv beta zeta delta [make_apply_under_binders_in_helper_helper do_make_apply_under_binders_in_helper_helper] in retT) in
           constr:(ret' : retT')
  end.

Hint Extern 0 (make_apply_under_binders_in_helper ?lem ?H) =>
let ret := make_apply_under_binders_in_84 lem H
in exact ret
   : typeclass_instances.

Ltac apply_under_binders_in_84 lem H :=
  let H' := make_apply_under_binders_in lem H in
  let H'' := fresh in
  pose proof H' as H'';
    clear H;
    rename H'' into H.

Goal forall A B P (f g : forall (x : A) (y : B x), P x y), (forall x y, f x y = g x y) -> f = g.
Proof.
  intros A B P f g H.
  apply_under_binders_in_84 @functional_extensionality_dep H.
  apply_under_binders_in_84 @functional_extensionality_dep H.
  exact H.
Defined.



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
Check (fun x => % x). (** [fun x : T₁ => F x : T₁ -> T₂] *)
Fail Check (% _). (** Error: Cannot infer an internal placeholder of type "Type". *)
Fail Check (% 1). (** Error:
Unable to satisfy the following constraints:

?96 : "Type"
?97 : "?96"
?98 : "MyNotation 1 ?97" *)

(** Or we can get better error messages *)
Ltac pick_percent x :=
  let T := type of x in
  let T1 := constr:(T₁) in
  let T2 := constr:(T₂) in
  first [ unify T T₁; exact (F x)
        | unify T T₂; exact (G x)
        | fail 1 "The typeof" x ":" T "is neither" T1 "nor" T2 ].

Notation "%% x"
  := ($(pick_percent x)$)
       (at level 40, only parsing).
Goal True.
  Check (%% t₁). (** F t₁ : T₃ *)
  Check (%% t₂). (** G t₂ : T₃ *)
  Check (fun x => %% x). (** [fun x : T₁ => F x : T₁ -> T₂] *)
  Fail Check (%% _). (** Error: Cannot infer an internal placeholder of type "Type". *)
  Fail pose (%% 1). (** Error: Tactic failure: The type of 1 : nat is neither T₁ nor T₂. *)
Abort.


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

(** * Debug logging *)
(** In tactics that return constrs, we can do debugging without changing to cps *)
Ltac head x :=
  match x with
    | ?f ?a => let log := constr:($(idtac x; exact I)$) in head f
    | _ => x
  end.

Goal True.
  let k := head (1 + 1 + 1 + 1) in
  pose k. (* (1 + 1 + 1 + 1)
(plus (1 + 1 + 1)) *)
Abort.

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
  Fail apply x. (** universe inconsistency *)
  admit.
Abort.

Goal forall x y : NaiveFunext, funext_downward_closed x = funext_downward_closed y.
Proof.
  intros x y; hnf in x, y.
  apply x. (** success *)
  admit.
(*Defined.*)
Abort.
