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

Check (_ * _ + _ - _)%expr.
Check (_ * _)%expr.

Notation "- x" := (Opp x) : expr_scope.
Notation "'#' x"
  := (Literal x)
       (at level 10, format "'#' x")
     : expr_scope.
Open Scope expr_scope.
Check (#(Z.succ _))%expr.
Notation "'$' x"
  := (Var x)
       (at level 10, format "'$' x")
     : expr_scope.
Notation "'expr_let' x := y 'in' f"
  := (LetIn y (fun x => f))
       (at level 200, f at level 200,
        format "'[v' 'expr_let'  x  :=  y  'in' '//' f ']'")
     : expr_scope.

Notation "x" := (Var x) (only printing, at level 10) : expr_scope.
Notation "x" := (Literal x) (only printing, at level 10) : expr_scope.
Notation "'int' x = y ';' f"
  := (LetIn y (fun x => f))
       (at level 200, f at level 200,
        format "'[v' 'int'  x  =  y ';' '//' f ']'")
     : expr_scope.
Notation "( x , y , .. , z )"
  := (Pair .. (Pair x y) .. z) : expr_scope.
Notation "'int' x = y ';' f"
  := (LetIn y (fun x => f))
       (at level 200, f at level 200,
        format "'[v' 'int'  x  =  y ';' '//' f ']'")
     : expr_scope.
(*
Notation "'int' x = y ';' 'int' .. ';' 'int' z = w ';' 'return' f"
  := (LetIn y (fun x => .. (LetIn w (fun z => f)) .. ))
       (at level 200, f at level 200)
     : expr_scope.
*)
Definition foo {var} := (expr_let x := #1 in expr_let y := $x * $x in $y)%expr : @expr var _.
Print foo.
Close Scope expr_scope.
Print foo.
Undelimit Scope expr_scope.
Print foo.
About LetIn.
Close Scope expr_scope.
Arguments LetIn : clear scopes.
Arguments Mul : clear scopes.
Print foo.

Print Grammar constr.
