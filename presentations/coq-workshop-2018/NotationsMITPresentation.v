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

Check (_ + _ * _ - _)%expr.
(* M-x load-theme tango-dark *)
Notation "- x" := (Opp x) : expr_scope.
Print Grammar constr.
Notation "# x" := (Literal x) (at level 10, format "# x") : expr_scope.
Open Scope expr_scope.
Check fun x => #(Z.succ x).
Notation "$ x" := (Var x) (at level 10, format "$ x") : expr_scope.
Check #1 + #1.
Notation "'expr_let' x := y 'in' f"
  := (LetIn y (fun x => f%expr))
       (at level 200, right associativity,
        format "'[' 'expr_let'  x  :=  y  'in' '//' f ']'") : expr_scope.
Check (expr_let x := #1 in expr_let y := $x + #2 in $y + $x).

Module MorePretty.
  Notation "x" := (Literal x) (only printing, at level 10) : expr_scope.
  Notation "x" := (Var x) (only printing, at level 10) : expr_scope.
  Notation "T x = y ; f"
    := (LetIn (s:=T) y (fun x => f%expr))
         (only printing, at level 200, right associativity,
          format "'[' T  x  =  y ; '//' f ']'") : expr_scope.
  Notation int := Z.
  Fail Notation "T x = y ; .. ; T' x' = y' ;; 'return' f"
    := (LetIn (s:=T) y (fun x => .. (LetIn (s:=T') y' (fun x' => f%expr)) .. ))
         (only printing, at level 200, right associativity) : expr_scope.
  Check (expr_let x := #1 in expr_let y := $x + #2 in $y + $x).
End MorePretty.

Notation "( x , y , .. , z )" := (Pair .. (Pair x y) .. z) : expr_scope.
Print Grammar constr.
Notation "\ x .. y , f"
  := (Abs (fun x => .. (Abs (fun y => f%expr)) .. ))
       (at level 99, x binder, y binder, right associativity, f at level 200) : expr_scope.

(* Syntax of notations (e.g., \texttt{Infix "+" := add.}; \texttt{Notation "a + b" := (add a b).}) *)
(* Notation bodies must be parenthesized *)
(* How to use levels and associativity, how to pick levels, how to discover levels of existing notations (\texttt{Print Grammar constr}) *)
(* Controlling display: \texttt{format}, extra spaces, quoting symbols, boxes in \texttt{format} for display of indentation, newlines, and whitespace *)
(* Recursive notations: \texttt{..} for pair- and $\lambda$-like things *)
(* \texttt{Reserved Notation} and \texttt{only printing}, useful for ensuring that notations don't conflict *)
(* Using single-variable only-printing notations for hiding identifiers *)
(* Abbreviations vs notations (what it means when your \texttt{Notation} doesn't have quotes, and why you might want this) *)
(* Notation scopes, useful for overloading notations and selecting the right one automatically (\texttt{Bind Scope}, \texttt{Delimit Scope}, \texttt{Open Scope}) *)
(* Using binders for destructuring pairs *)
(* Parenthesizing notations: when to use parentheses, and when to use levels *)
(* Deliberate ordering of notations: how to express wildcard and negation in notation matching *)


(** Feeback: *)
(* Strange point on the spectrum between understand nothing and understand everything
- Who's the target audience? (ppl who don't read the manual?)
- Showing larger scale example (e.g., fiat-crypto pipeline Notations) for wow factor at the beginning
- Look into showing VST Notations in action
- Make sure to explain when you need 4000 lines of notations, when not
- Maybe do a proof with/with-out notations ("can you spot the bug now?")
- too much time typing "Infix" at the beginning
- don't use "things" ('the things need to be the same')
- if mention uniform inheritance ("too much polymorphism to explain")
- careful about mentioning fiat-crypto without explanation
- don't explain PHOAS
- print out outline, not in buffer
- too much time pitching scopes (more code, less talk)
- less time scrolling through tiny buffer of levels, give a couple more examples
*)
