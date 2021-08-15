.. _omega:

Omega: a solver for quantifier-free problems in Presburger Arithmetic
=====================================================================

:Author: Pierre Crégut

Description of ``omega``
------------------------

This tactic does not need any parameter:

.. tacn:: omega

``omega`` solves a goal in Presburger arithmetic, i.e. a universally
quantified formula made of equations and inequations. Equations may
be specified either on the type ``nat`` of natural numbers or on
the type ``Z`` of binary-encoded integer numbers. Formulas on
``nat`` are automatically injected into ``Z``.  The procedure
may use any hypothesis of the current proof session to solve the goal.

Multiplication is handled by ``omega`` but only goals where at
least one of the two multiplicands of products is a constant are
solvable. This is the restriction meant by "Presburger arithmetic".

If the tactic cannot solve the goal, it fails with an error message.
In any case, the computation eventually stops.

Arithmetical goals recognized by ``omega``
------------------------------------------

``omega`` applied only to quantifier-free formulas built from the
connectors::

   /\  \/  ~  ->

on atomic formulas. Atomic formulas are built from the predicates::

   =  <  <=  >  >=

on ``nat`` or ``Z``. In expressions of type ``nat``, ``omega`` recognizes::

   +  -  *  S  O  pred

and in expressions of type ``Z``, ``omega`` recognizes numeral constants and::

   +  -  *  Z.succ Z.pred

All expressions of type ``nat`` or ``Z`` not built on these
operators are considered abstractly as if they
were arbitrary variables of type ``nat`` or ``Z``.

Messages from ``omega``
-----------------------

When ``omega`` does not solve the goal, one of the following errors
is generated:

.. exn:: omega can't solve this system

  This may happen if your goal is not quantifier-free (if it is
  universally quantified, try ``intros`` first; if it contains
  existentials quantifiers too, ``omega`` is not strong enough to solve your
  goal). This may happen also if your goal contains arithmetical
  operators unknown from ``omega``. Finally, your goal may be really
  wrong!

.. exn:: omega: Not a quantifier-free goal

  If your goal is universally quantified, you should first apply
  ``intro`` as many time as needed.

.. exn:: omega: Unrecognized predicate or connective: @ident

.. exn:: omega: Unrecognized atomic proposition: ...

.. exn:: omega: Can't solve a goal with proposition variables

.. exn:: omega: Unrecognized proposition

.. exn:: omega: Can't solve a goal with non-linear products

.. exn:: omega: Can't solve a goal with equality on type ...


Using ``omega``
---------------

The ``omega`` tactic does not belong to the core system. It should be
loaded by

.. coqtop:: in

   Require Import Omega.

.. example::

  .. coqtop:: all

     Require Import Omega.

     Open Scope Z_scope.

     Goal forall m n:Z, 1 + 2 * m <> 2 * n.
     intros; omega.
     Abort.

     Goal forall z:Z, z > 0 -> 2 * z + 1 > z.
     intro; omega.
     Abort.


Options
-------

.. opt:: Stable Omega

This deprecated option (on by default) is for compatibility with Coq pre 8.5. It
resets internal name counters to make executions of ``omega`` independent.

.. opt:: Omega UseLocalDefs

This option (on by default) allows ``omega`` to use the bodies of local
variables.

.. opt:: Omega System

This option (off by default) activate the printing of debug information

.. opt:: Omega Action

This option (off by default) activate the printing of debug information

Technical data
--------------

Overview of the tactic
~~~~~~~~~~~~~~~~~~~~~~

 * The goal is negated twice and the first negation is introduced as an hypothesis.
 * Hypothesis are decomposed in simple equations or inequations. Multiple
   goals may result from this phase.
 * Equations and inequations over ``nat`` are translated over
   ``Z``, multiple goals may result from the translation of substraction.
 * Equations and inequations are normalized.
 * Goals are solved by the OMEGA decision procedure.
 * The script of the solution is replayed.

Overview of the OMEGA decision procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The OMEGA decision procedure involved in the ``omega`` tactic uses
a small subset of the decision procedure presented in :cite:`TheOmegaPaper`
Here is an overview, look at the original paper for more information.

 * Equations and inequations are normalized by division by the GCD of their
   coefficients.
 * Equations are eliminated, using the Banerjee test to get a coefficient
   equal to one.
 * Note that each inequation defines a half space in the space of real value
   of the variables.
 * Inequations are solved by projecting on the hyperspace
   defined by cancelling one of the variable.  They are partitioned
   according to the sign of the coefficient of the eliminated
   variable. Pairs of inequations from different classes define a
   new edge in the projection.
 * Redundant inequations are eliminated or merged in new
   equations that can be eliminated by the Banerjee test.
 * The last two steps are iterated until a contradiction is reached
   (success) or there is no more variable to eliminate (failure).

It may happen that there is a real solution and no integer one. The last
steps of the Omega procedure (dark shadow) are not implemented, so the
decision procedure is only partial.

Bugs
----

 * The simplification procedure is very dumb and this results in
   many redundant cases to explore.

 * Much too slow.

 * Certainly other bugs! You can report them to https://coq.inria.fr/bugs/.
