(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2015     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

val process_expr :
  Environ.env -> Vernacexpr.section_subset_expr -> Constr.types list ->
    Names.Id.t list

val name_set : Names.Id.t -> Vernacexpr.section_subset_expr -> unit

val to_string : Vernacexpr.section_subset_expr -> string

val get_default_proof_using : unit -> string option
