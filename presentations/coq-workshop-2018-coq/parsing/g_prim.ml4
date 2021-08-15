(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

open Names
open Libnames

open Pcoq
open Pcoq.Prim

let prim_kw = ["{"; "}"; "["; "]"; "("; ")"; "'"]
let _ = List.iter CLexer.add_keyword prim_kw


let local_make_qualid l id = make_qualid (DirPath.make l) id

let my_int_of_string loc s =
  try
    let n = int_of_string s in
    (* To avoid Array.make errors (that e.g. Undo uses), we set a *)
    (* more restricted limit than int_of_string does *)
    if n > 1024 * 2048 then raise Exit;
    n
  with Failure _ | Exit ->
    CErrors.user_err ~loc  (Pp.str "Cannot support a so large number.")

GEXTEND Gram
  GLOBAL:
    bigint natural integer identref name ident var preident
    fullyqualid qualid reference dirpath ne_lstring
    ne_string string lstring pattern_ident pattern_identref by_notation smart_global;
  preident:
    [ [ s = IDENT -> s ] ]
  ;
  ident:
    [ [ s = IDENT -> Id.of_string s ] ]
  ;
  pattern_ident:
    [ [ LEFTQMARK; id = ident -> id ] ]
  ;
  pattern_identref:
    [ [ id = pattern_ident -> CAst.make ~loc:!@loc id ] ]
  ;
  var: (* as identref, but interpret as a term identifier in ltac *)
    [ [ id = ident -> CAst.make ~loc:!@loc id ] ]
  ;
  identref:
    [ [ id = ident -> CAst.make ~loc:!@loc id ] ]
  ;
  field:
    [ [ s = FIELD -> Id.of_string s ] ]
  ;
  fields:
    [ [ id = field; (l,id') = fields -> (l@[id],id')
      | id = field -> ([],id)
      ] ]
  ;
  fullyqualid:
    [ [ id = ident; (l,id')=fields -> CAst.make ~loc:!@loc @@ id::List.rev (id'::l)
      | id = ident -> CAst.make ~loc:!@loc [id]
      ] ]
  ;
  basequalid:
    [ [ id = ident; (l,id')=fields -> local_make_qualid (l@[id]) id'
      | id = ident -> qualid_of_ident id
      ] ]
  ;
  name:
    [ [ IDENT "_"  -> CAst.make ~loc:!@loc Anonymous
      | id = ident -> CAst.make ~loc:!@loc @@ Name id ] ]
  ;
  reference:
    [ [ id = ident; (l,id') = fields ->
        CAst.make ~loc:!@loc @@ Qualid (local_make_qualid (l@[id]) id')
      | id = ident -> CAst.make ~loc:!@loc @@ Ident id
      ] ]
  ;
  by_notation:
    [ [ s = ne_string; sc = OPT ["%"; key = IDENT -> key ] -> (s, sc) ] ]
  ;
  smart_global:
    [ [ c = reference -> CAst.make ~loc:!@loc @@ Misctypes.AN c
      | ntn = by_notation -> CAst.make ~loc:!@loc @@ Misctypes.ByNotation ntn ] ]
  ;
  qualid:
    [ [ qid = basequalid -> CAst.make ~loc:!@loc qid ] ]
  ;
  ne_string:
    [ [ s = STRING ->
        if s="" then CErrors.user_err ~loc:!@loc (Pp.str"Empty string."); s
    ] ]
  ;
  ne_lstring:
    [ [ s = ne_string -> CAst.make ~loc:!@loc s ] ]
  ;
  dirpath:
    [ [ id = ident; l = LIST0 field ->
        DirPath.make (List.rev (id::l)) ] ]
  ;
  string:
    [ [ s = STRING -> s ] ]
  ;
  lstring:
    [ [ s = string -> (CAst.make ~loc:!@loc s) ] ]
  ;
  integer:
    [ [ i = INT      -> my_int_of_string (!@loc) i
      | "-"; i = INT -> - my_int_of_string (!@loc) i ] ]
  ;
  natural:
    [ [ i = INT -> my_int_of_string (!@loc) i ] ]
  ;
  bigint: (* Negative numbers are dealt with elsewhere *)
    [ [ i = INT -> i ] ]
  ;
END
