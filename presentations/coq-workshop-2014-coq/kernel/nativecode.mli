(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2015     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)
open Term
open Names
open Declarations
open Pre_env
open Nativelambda

(** This file defines the mllambda code generation phase of the native
compiler. mllambda represents a fragment of ML, and can easily be printed
to OCaml code. *)

type mllambda
type global

val pp_global : Format.formatter -> global -> unit

val mk_open : string -> global

(* Precomputed values for a compilation unit *)
type symbol
type symbols

val empty_symbols : symbols

val clear_symbols : unit -> unit

val get_value : symbols -> int -> Nativevalues.t

val get_sort : symbols -> int -> sorts

val get_name : symbols -> int -> name

val get_const : symbols -> int -> constant

val get_match : symbols -> int -> Nativevalues.annot_sw

val get_ind : symbols -> int -> inductive

val get_meta : symbols -> int -> metavariable

val get_evar : symbols -> int -> existential

val get_level : symbols -> int -> Univ.Level.t

val get_symbols : unit -> symbols

type code_location_update
type code_location_updates
type linkable_code = global list * code_location_updates

val clear_global_tbl : unit -> unit

val empty_updates : code_location_updates

val register_native_file : string -> unit

val compile_constant_field : env -> string -> constant ->
  global list -> constant_body -> global list

val compile_mind_field : string -> module_path -> label ->
  global list -> mutual_inductive_body -> global list

val mk_conv_code : env -> evars -> string -> constr -> constr -> linkable_code
val mk_norm_code : env -> evars -> string -> constr -> linkable_code

val mk_library_header : dir_path -> global list

val mod_uid_of_dirpath : dir_path -> string

val link_info_of_dirpath : dir_path -> link_info

val update_locations : code_location_updates -> unit

val add_header_comment : global list -> string -> global list
