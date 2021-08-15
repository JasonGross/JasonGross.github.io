(* -*- proof-three-window-mode-policy: hybrid -*- *)
(** A Limited Case for Reification by Type Inference *)
(** By Jason Gross *)

(** Outline:
1. Goal:
     Perform some operation which requires a structured
     representation of curried types, e.g., reversal
2. notation for reified currying + operation
3. notation for normal currying
4. implementation of normal currying notation
5. implementation of reified currying
(6. implementation of reversal *)

(***************************************************************)

(** 1. Goal: Perform some operation which requires a structured
     representation of curried types, e.g., reversal *)

(** 2. notation for reified currying + operation *)

(**
<<
Notation "'->uncurryR' x , .. , y => v" := ⋯

Eval cbv -["+"] in
    rev_uncurry (->uncurryR x, y, z, w => x + y + z + w).
(*   = fun '(v2, a1, a0, a) => a + a0 + a1 + v2 *)
>> *)

(** 3. notation for normal currying *)

(**
<<
Notation "'->uncurry' x , .. , y => v" := ⋯ .
>> *)

(** 4. implementation of normal currying notation *)

Definition uncurry2 {A B C} (f : A -> B -> C) : A * B -> C
  := fun '(a, b) => f a b.

Check uncurry2 Nat.add. (* uncurry2 Nat.add : nat * nat -> nat *)
Eval cbv [uncurry2] in uncurry2 Nat.add.
(*   = fun '(a, b) => a + b
     : nat * nat -> nat
 *)

Eval cbv [uncurry2] in
    uncurry2 (fun a b c d e => a + b + c + d + e).
(*   = fun '(a, b) (c d e : nat) => a + b + c + d + e
     : nat * nat -> nat -> nat -> nat -> nat *)

Notation "'->uncurry3' x , y , z => v" :=
  (uncurry2 (fun x => uncurry2 (fun y => (fun z => v))))
    (at level 200, v at level 100, only parsing).

Check ->uncurry3 x, y, z => x + y + z.
Eval cbv -["+"] in ->uncurry3 x, y, z => x + y + z.

Notation "'->uncurry3' x , y , z => v" :=
  (uncurry2 (fun x => uncurry2 (fun y => uncurry2 (fun z (_ : unit) => v))))
    (at level 200, v at level 100, only parsing).

Check ->uncurry3 x, y, z => x + y + z.
Eval cbv -["+"] in ->uncurry3 x, y, z => x + y + z.

Notation "'->uncurry' x , .. , y => v" :=
  (uncurry2 (fun x => .. (uncurry2 (fun y (_ : unit) => v)) .. ))
    (at level 200, x closed binder, y closed binder,
     v at level 100, only parsing).

Check ->uncurry x, y, z, w => x + y + z + w.
Eval cbv [uncurry2] in ->uncurry x, y, z, w => x + y + z + w.

(***************************************************************)
(* 5. implementation of reified currying *)
Inductive uncurry_types :=
| ccons (A : Type) (rest : uncurry_types) | cnil.

Fixpoint denoteUncurried (A : uncurry_types) : Type :=
  match A with
  | cnil => unit
  | ccons A As => A * denoteUncurried As
  end.

Eval cbv [denoteUncurried] in
    denoteUncurried (ccons nat (ccons bool (ccons Set cnil))).

Definition uncurry {A As B} (f : A -> denoteUncurried As -> B)
  : denoteUncurried (ccons A As) -> B
  := fun '(a, b) => f a b.

Notation "'->uncurryR' x , .. , y => v" :=
  (uncurry (fun x => .. (uncurry (fun y (_ : unit) => v)) .. ))
    (at level 200, x closed binder, y closed binder,
     v at level 100, only parsing).

Fail Eval cbv [uncurry] in ->uncurryR x, y, z, w => x + y + z + w.
(* The command has indeed failed with message:
Found type "unit" where "denoteUncurried ?As2" was expected.
*)

Notation "'->uncurryR' x , .. , y => v" :=
  (uncurry (fun x => .. (uncurry (fun y (_ : denoteUncurried cnil) => v)) .. ))
    (at level 200, x closed binder, y closed binder,
     v at level 100, only parsing).

Eval cbv [uncurry] in ->uncurryR x, y, z, w => x + y + z + w.
(* = fun '(a, (a0, (a1, (a2, _)))) => a + a0 + a1 + a2
   : denoteUncurried (ccons nat (ccons nat (ccons nat (ccons nat cnil)))) -> nat
 *)

(***************************************************************)
(* (6. implementation of reversal *)
(* Example of a cool thing to be done: reversing uncurrying *)
Fixpoint denoteUncurried_rev (A : uncurry_types) : Type
  := match A with
     | cnil => unit
     | ccons A As => denoteUncurried_rev As * A
     end.
Fixpoint uncurry_rev (A : uncurry_types)
  : denoteUncurried_rev A -> denoteUncurried A
  := match A with
     | cnil       => fun   v     => v
     | ccons A As => fun '(v, a) => (a, uncurry_rev As v)
     end.
Definition rev_uncurry {A B} (f : denoteUncurried A -> B)
  : denoteUncurried_rev A -> B
  := fun v => f (uncurry_rev _ v).

Eval cbv -["+"] in rev_uncurry (->uncurryR x, y, z, w => x + y + z + w).
(*     = fun v : unit * nat * nat * nat * nat =>
       let
       '(a, (a0, (a1, (a2, _)))) :=
        let
        '(v0, a) := v in
         (a,
         let
         '(v1, a0) := v0 in
          (a0,
          let
          '(v2, a1) := v1 in
           (a1, let '(v3, a2) := v2 in (a2, v3)))) in
        a + a0 + a1 + a2
     : denoteUncurried_rev
         (ccons nat (ccons nat (ccons nat (ccons nat cnil)))) ->
       nat
 *)

Fixpoint denoteUncurried_rev_nounit (A : uncurry_types) : Type
  := match A with
     | cnil         => unit
     | ccons A cnil => A
     | ccons A As   => denoteUncurried_rev_nounit As * A
     end.
Fixpoint uncurry_rev_cps {T} (A : uncurry_types)
  : denoteUncurried_rev_nounit A -> (denoteUncurried A -> T) -> T
  := match A with
     | cnil         => fun v k => k v
     | ccons A As
       => match As return (denoteUncurried_rev_nounit As -> (denoteUncurried As -> T) -> T) -> denoteUncurried_rev_nounit (ccons A As) -> _ with
          | cnil => fun _ v k => k (v, tt)
          | _ => fun uncurry_rev_cps v k
                 => let '(v, a) := v in
                    uncurry_rev_cps v (fun v => k (a, v))
          end (uncurry_rev_cps As)
     end.

Definition rev_uncurry_by_cps {A B} (f : denoteUncurried A -> B)
  : denoteUncurried_rev_nounit A -> B
  := fun v => uncurry_rev_cps _ v f.

Eval cbv -["+"] in
    rev_uncurry_by_cps (->uncurryR x, y, z, w => x + y + z + w).
(*   = fun '(v2, a1, a0, a) => a + a0 + a1 + v2
     : denoteUncurried_rev_nounit
         (ccons nat (ccons nat (ccons nat (ccons nat cnil)))) ->
       nat
*)
