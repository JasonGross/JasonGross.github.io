(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(** The Coq main module. The following function [start] will parse the
   command line, print the banner, initialize the load path, load the input
   state, load the files given on the command line, load the resource file,
   produce the output state if any, and finally will launch [Coqloop.loop]. *)

val init_toplevel : string list -> Vernac.State.t option * Coqargs.coq_cmdopts

val start : unit -> unit

(* For other toploops *)
val toploop_init : (Coqargs.coq_cmdopts -> string list -> string list) ref
val toploop_run : (Coqargs.coq_cmdopts -> state:Vernac.State.t -> unit) ref
