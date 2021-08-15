(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2015     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

open Errors
open Pp

(* Dynamics, programmed with DANGER !!! *)

type t = int * Obj.t

let dyntab = ref (Int.Map.empty : string Int.Map.t)
(** Instead of working with tags as strings, which are costly, we use their
    hash. We ensure unicity of the hash in the [create] function. If ever a
    collision occurs, which is unlikely, it is sufficient to tweak the offending
    dynamic tag. *)

let create (s : string) =
  let hash = Hashtbl.hash s in
  let () =
    if Int.Map.mem hash !dyntab then
      let old = Int.Map.find hash !dyntab in
      let msg = str "Dynamic tag collision: " ++ str s ++ str " vs. " ++ str old in
      anomaly ~label:"Dyn.create" msg
  in
  let () = dyntab := Int.Map.add hash s !dyntab in
  let infun v = (hash, Obj.repr v) in
  let outfun (nh, rv) =
    if Int.equal hash nh then Obj.magic rv
    else
      anomaly (str "dyn_out: expected " ++ str s)
  in
  (infun, outfun)

let has_tag (s, _) tag =
  let hash = Hashtbl.hash (tag : string) in
  Int.equal s hash

let tag (s,_) =
  try Int.Map.find s !dyntab
  with Not_found ->
    anomaly (str "Unknown dynamic tag " ++ int s)

let pointer_equal (t1,o1) (t2,o2) = t1 = t2 && o1 == o2

let dump () = Int.Map.bindings !dyntab
