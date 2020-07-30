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

(* Notation scopes, useful for overloading notations and selecting the right one automatically (\texttt{Bind Scope}, \texttt{Delimit Scope}, \texttt{Open Scope}) *)
Delimit Scope expr_scope with expr.
Bind Scope expr_scope with expr.
Delimit Scope etype_scope with etype.
Bind Scope etype_scope with type.
Open Scope expr_scope.
(* Syntax of notations (e.g., \texttt{Infix "+" := add.}; \texttt{Notation "a + b" := (add a b).}) *)
Infix "*" := prod : etype_scope.
Infix "->" := arrow : etype_scope.
Infix "*" := Mul : expr_scope.
Infix "+" := Add : expr_scope.
Infix "-" := Sub : expr_scope.
(* Notation bodies must be parenthesized *)
Notation "- x" := (Opp x) : expr_scope.
(* How to use levels and associativity, how to pick levels, how to discover levels of existing notations (\texttt{Print Grammar constr}) *)
(* Controlling display: \texttt{format}, extra spaces, quoting symbols, boxes in \texttt{format} for display of indentation, newlines, and whitespace *)
Fail Notation "# v" := (Literal v) : expr_scope.
Notation "# v" := (Literal v) (at level 10, format "# v") : expr_scope.
Notation "$ v" := (Var v) (at level 10, format "$ v") : expr_scope.
(* Recursive notations: \texttt{..} for pair- and $\lambda$-like things *)
Notation "( x , y , .. , z )" := (Pair .. (Pair x y) .. z) : expr_scope.
Notation "\ x .. y , f"
  := (Abs (fun x => .. (Abs (fun y => f%expr)) .. ))
       (at level 200, x binder, y binder, right associativity, format "'[  ' \  x  ..  y ']' ,  f") : expr_scope.
Notation "'expr_let' x := y 'in' f"
  := (LetIn y (fun x => f%expr))
       (at level 200, right associativity, format "'[' 'expr_let'  x  :=  y  'in' '//' f ']'") : expr_scope.
Check (expr_let x := #1 in expr_let y := $x + $x in $y + $y).
(* \texttt{Reserved Notation} and \texttt{only printing}, useful for ensuring that notations don't conflict *)
(* Using single-variable only-printing notations for hiding identifiers *)
Module ExtraPretty.
  Notation "x" := (Var x) (only printing, at level 10) : expr_scope.
  Notation "x" := (Literal x) (only printing, at level 10) : expr_scope.
  Notation "T x = y ; f"
    := (LetIn (s:=T) y (fun x => f%expr))
         (at level 200, right associativity, format "'[' T  x  =  y ; '//' f ']'") : expr_scope.
  (* Abbreviations vs notations (what it means when your \texttt{Notation} doesn't have quotes, and why you might want this) *)
  Notation int := Z.
  Check (expr_let x := #1 in expr_let y := $x + $x in $y + $y).
End ExtraPretty.
(* Using binders for destructuring pairs *)
(* Parenthesizing notations: when to use parentheses, and when to use levels *)
(* Deliberate ordering of notations: how to express wildcard and negation in notation matching *)
