Require Import Coq.ZArith.BinInt.
Inductive type := Z | prod (A B : type) | arrow (s d : type).
Inductive expr {var:type -> Type} : type -> Type :=
| LetIn {s d} (x : expr s) (f : var s -> expr d) : expr d
| App {s d} (f : expr (arrow s d)) (x : expr s) : expr d
| Abs {s d} (f : var s -> expr d) : expr (arrow s d)
| Var {t} (v : var t) : expr t
| Pair {A B} (x : expr A) (y : expr B) : expr (prod A B)
| Fst {A B} (x : expr (prod A B)) : expr A
| Snd {A B} (x : expr (prod A B)) : expr B
| Add (x y : expr Z) : expr Z
| Mul (x y : expr Z) : expr Z
| Sub (x y : expr Z) : expr Z
| Opp (x : expr Z) : expr Z
| Literal (v : BinInt.Z) : expr Z
| AddWithGetCarry (x y c : expr Z) : expr (prod Z Z)
| CastToSize (lower upper : BinInt.Z) (v : expr Z) : expr Z.

Delimit Scope etype_scope with etype.
Delimit Scope expr_scope with expr.
Bind Scope etype_scope with type.
Bind Scope expr_scope with expr.
Infix "*" := prod : etype_scope.
Infix "*" := Mul : expr_scope.
Infix "->" := arrow : etype_scope.
Infix "-" := Sub : expr_scope.
Infix "+" := Add : expr_scope.
