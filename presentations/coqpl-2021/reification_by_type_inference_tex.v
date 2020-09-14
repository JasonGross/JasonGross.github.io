Inductive curry_types := ccons (A : Type) (rest : curry_types) | cnil.

Fixpoint denoteCurried (A : curry_types) : Type :=
  match A with
  | cnil => unit
  | ccons A As => A * denoteCurried As
  end.

Definition curry {A As B} (f : A -> denoteCurried As -> B)
  : denoteCurried (ccons A As) -> B
  := fun '(a, b) => f a b.

Fixpoint denoteCurried_rev' (A : curry_types) (so_far : Type) : Type
  := match A with
     | cnil => so_far
     | ccons A As => denoteCurried_rev' As (so_far * A)
     end.
Definition denoteCurried_rev (A : curry_types) : Type
  := match A with
     | cnil => unit
     | ccons A As => denoteCurried_rev' As A
     end.

Fixpoint curry_rev' {T} (A : curry_types) (so_far : Type)
  : denoteCurried_rev' A so_far -> (so_far * denoteCurried A -> T) -> T
  := match A with
     | cnil => fun v k => k (v, tt)
     | ccons A As => fun v k => curry_rev' As _ v (fun '(sf, a, v) => k (sf, (a, v)))
     end.
Definition curry_rev {T} (A : curry_types)
  : denoteCurried_rev A -> (denoteCurried A -> T) -> T
  := match A with
     | cnil => fun v k => k v
     | ccons A As => fun v k => curry_rev' As A v k
     end.

Definition rev_curry {A B} (f : denoteCurried A -> B) : denoteCurried_rev A -> B
  := fun v => curry_rev _ v f.
Notation "'->curry' x , .. , y => v"
  := (curry (fun x => .. (curry (fun y (_ : denoteCurried cnil) => v)) .. ))
       (at level 200, x closed binder, y closed binder, v at level 100).

Eval cbv -["+"] in ->curry x, y, z, w => x + y + z + w.
(* = fun '(a, (a0, (a1, (a2, _)))) => a + a0 + a1 + a2
   : denoteCurried (ccons nat (ccons nat (ccons nat (ccons nat cnil)))) -> nat *)
Eval cbv -["+"] in rev_curry (->curry x, y, z, w => x + y + z + w).
(* = fun '(sf1, a1, a0, a) => sf1 + a1 + a0 + a
   : denoteCurried_rev (ccons nat (ccons nat (ccons nat (ccons nat cnil)))) ->
     nat *)
