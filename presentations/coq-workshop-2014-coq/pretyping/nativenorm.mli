(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2015     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)
open Term
open Environ
open Evd
open Nativelambda

(** This module implements normalization by evaluation to OCaml code *)

val native_norm : env -> evar_map -> constr -> types -> constr

(** Conversion with inference of universe constraints *)
val native_infer_conv : ?pb:conv_pb -> env -> evar_map -> constr -> constr ->
  evar_map * bool
