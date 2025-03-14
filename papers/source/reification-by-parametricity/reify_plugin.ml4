(*i camlp4deps: "parsing/grammar.cma" i*)
(*i camlp4use: "pa_extend.cmp" i*)

let contrib_name = "template-coq-derivative"

open Names

let rec unsafe_reify_helper_with_const
        (mkVar : Constr.t -> 'a)
        (mkConst : Constr.t -> 'a)
        (zOp : Constr.t)
        (mkOp : 'a -> 'a -> 'a)
        (idLetIn : Constr.t)
        (mkLetIn : 'a -> Name.t -> Constr.t -> 'a -> 'a)
        (term : Constr.t)
    =
      let reify_rec term = unsafe_reify_helper_with_const mkVar mkConst zOp mkOp idLetIn mkLetIn term in
      let kterm = Constr.kind term in
      begin match kterm with
      | Term.Rel _ -> mkVar term
      | Term.Var _ -> mkVar term
      | Term.Cast (term, _, _) -> reify_rec term
      | Term.App (f, args)
        ->
        if Constr.equal f zOp
        then let x = Array.get args 0 in
             let y = Array.get args 1 in
             let rx = reify_rec x in
             let ry = reify_rec y in
             mkOp rx ry
        else if Constr.equal f idLetIn
        then let x = Array.get args 2 (* assume the first two args are type params *) in
             let f = Array.get args 3 in
             begin match Constr.kind f with
             | Term.Lambda (idx, ty, body)
               -> let rx = reify_rec x in
                  let rf = reify_rec body in
                  mkLetIn rx idx ty rf
             | _ -> mkConst term
             end
         else mkConst term
      | _
        -> mkConst term
      end

let rec unsafe_reify_helper
        (mkVar : Constr.t -> 'a)
        (mkO : 'a)
        (mkS : 'a -> 'a)
        (mkOp : 'a -> 'a -> 'a)
        (mkLetIn : 'a -> Name.t -> Constr.t -> 'a -> 'a)
        (gO : Constr.t)
        (gS : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (unrecognized : Constr.t -> 'a)
        (term : Constr.t)
    =
      let reify_rec term = unsafe_reify_helper mkVar mkO mkS mkOp mkLetIn gO gS gOp gLetIn unrecognized term in
      let kterm = Constr.kind term in
      if Constr.equal term gO
      then mkO
      else begin match kterm with
      | Term.Rel _ -> mkVar term
      | Term.Var _ -> mkVar term
      | Term.Cast (term, _, _) -> reify_rec term
      | Term.App (f, args)
        ->
        if Constr.equal f gS
        then let x = Array.get args 0 in
             let rx = reify_rec x in
             mkS rx
        else if Constr.equal f gOp
        then let x = Array.get args 0 in
             let y = Array.get args 1 in
             let rx = reify_rec x in
             let ry = reify_rec y in
             mkOp rx ry
        else if Constr.equal f gLetIn
        then let x = Array.get args 2 (* assume the first two args are type params *) in
             let f = Array.get args 3 in
             begin match Constr.kind f with
             | Term.Lambda (idx, ty, body)
               -> let rx = reify_rec x in
                  let rf = reify_rec body in
                  mkLetIn rx idx ty rf
             | _ -> unrecognized term
             end
         else unrecognized term
      | _
        -> unrecognized term
      end

let unsafe_reify_PHOAS_with_const
        (cVar : Constr.t)
        (cConst : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (var : Constr.t)
        (term : Constr.t) : Constr.t =
    let mkApp1 (f : Constr.t) (x : Constr.t) =
        Constr.mkApp (f, [| var ; x |]) in
    let mkApp2 (f : Constr.t) (x : Constr.t) (y : Constr.t) =
        Constr.mkApp (f, [| var ; x ; y |]) in
    let mkVar (v : Constr.t) = mkApp1 cVar v in
    let mkConst (v : Constr.t) = mkApp1 cConst v in
    let mkOp (x : Constr.t) (y : Constr.t) = mkApp2 cOp x y in
    let mkcLetIn (x : Constr.t) (y : Constr.t) = mkApp2 cLetIn x y in
    let mkLetIn (x : Constr.t) (idx : Name.t) (ty : Constr.t) (fbody : Constr.t)
        = mkcLetIn x (Constr.mkLambda (idx, var, fbody)) in
    let ret = unsafe_reify_helper_with_const mkVar mkConst gOp mkOp gLetIn mkLetIn term in
    ret

let unsafe_reify_HOAS_with_const
        (cVar : Constr.t)
        (cConst : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (term : Constr.t) : Constr.t =
    let mkApp1 (f : Constr.t) (x : Constr.t) =
        Constr.mkApp (f, [| x |]) in
    let mkApp2 (f : Constr.t) (x : Constr.t) (y : Constr.t) =
        Constr.mkApp (f, [| x ; y |]) in
    let mkVar (v : Constr.t) = mkApp1 cVar v in
    let mkConst (v : Constr.t) = mkApp1 cConst v in
    let mkOp (x : Constr.t) (y : Constr.t) = mkApp2 cOp x y in
    let mkcLetIn (x : Constr.t) (y : Constr.t) = mkApp2 cLetIn x y in
    let mkLetIn (x : Constr.t) (idx : Name.t) (ty : Constr.t) (fbody : Constr.t)
        = mkcLetIn x (Constr.mkLambda (idx, ty, fbody)) in
    let ret = unsafe_reify_helper_with_const mkVar mkConst gOp mkOp gLetIn mkLetIn term in
    ret

let unsafe_reify_PHOAS
        (cVar : Constr.t)
        (cO : Constr.t)
        (cS : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gO : Constr.t)
        (gS : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (var : Constr.t)
        (term : Constr.t) : Constr.t =
    let mkApp0 (f : Constr.t) =
        Constr.mkApp (f, [| var |]) in
    let mkApp1 (f : Constr.t) (x : Constr.t) =
        Constr.mkApp (f, [| var ; x |]) in
    let mkApp2 (f : Constr.t) (x : Constr.t) (y : Constr.t) =
        Constr.mkApp (f, [| var ; x ; y |]) in
    let mkVar (v : Constr.t) = mkApp1 cVar v in
    let mkO = mkApp0 cO in
    let mkS (v : Constr.t) = mkApp1 cS v in
    let mkOp (x : Constr.t) (y : Constr.t) = mkApp2 cOp x y in
    let mkcLetIn (x : Constr.t) (y : Constr.t) = mkApp2 cLetIn x y in
    let mkLetIn (x : Constr.t) (idx : Name.t) (ty : Constr.t) (fbody : Constr.t)
        = mkcLetIn x (Constr.mkLambda (idx, var, fbody)) in
    let ret = unsafe_reify_helper mkVar mkO mkS mkOp mkLetIn gO gS gOp gLetIn (fun term -> term) term in
    ret

let unsafe_reify_HOAS
        (cVar : Constr.t)
        (cO : Constr.t)
        (cS : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gO : Constr.t)
        (gS : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (term : Constr.t) : Constr.t =
    let mkApp0 (f : Constr.t) =
        f in
    let mkApp1 (f : Constr.t) (x : Constr.t) =
        Constr.mkApp (f, [| x |]) in
    let mkApp2 (f : Constr.t) (x : Constr.t) (y : Constr.t) =
        Constr.mkApp (f, [| x ; y |]) in
    let mkVar (v : Constr.t) = mkApp1 cVar v in
    let mkO = mkApp0 cO in
    let mkS (v : Constr.t) = mkApp1 cS v in
    let mkOp (x : Constr.t) (y : Constr.t) = mkApp2 cOp x y in
    let mkcLetIn (x : Constr.t) (y : Constr.t) = mkApp2 cLetIn x y in
    let mkLetIn (x : Constr.t) (idx : Name.t) (ty : Constr.t) (fbody : Constr.t)
        = mkcLetIn x (Constr.mkLambda (idx, ty, fbody)) in
    let ret = unsafe_reify_helper mkVar mkO mkS mkOp mkLetIn gO gS gOp gLetIn (fun term -> term) term in
    ret

module Vars = (* Coq's API is stupid, so we have to copy code from the kernel to make use of things, because I can't interface with Ltac if I pass -bypass-API *)
struct
  open Vars
  let substn_vars p vars c =
  let _,subst =
    List.fold_left (fun (n,l) var -> ((n+1),(var,Constr.mkRel n)::l)) (p,[]) vars
  in replace_vars (List.rev subst) c
end

let unsafe_Reify_PHOAS_with_const
        (cVar : Constr.t)
        (cConst : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (idvar : Id.t)
        (varty : Constr.t)
        (term : Constr.t) : Constr.t =
    let fresh_set = let rec fold accu c = match Constr.kind c with
      | Constr.Var id -> Id.Set.add id accu
      | _ -> Constr.fold fold accu c
      in
      fold Id.Set.empty term in
    (*let idvar = Namegen.next_ident_away_from idvar (fun id -> Id.Set.mem id fresh_set) in*) (* stupid API *)
    let idvar = Namegen.next_ident_away_in_goal idvar fresh_set in
    let var = Constr.mkVar idvar in
    let rterm = unsafe_reify_PHOAS_with_const cVar cConst cOp cLetIn gOp gLetIn var term in
    let rterm = Vars.substn_vars 1 [idvar] rterm in
    Constr.mkLambda (Name.Name idvar, varty, rterm)

let unsafe_Reify_HOAS_with_const
        (cVar : Constr.t)
        (cConst : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (term : Constr.t) : Constr.t =
    unsafe_reify_HOAS_with_const cVar cConst cOp cLetIn gOp gLetIn term

let unsafe_Reify_PHOAS
        (cVar : Constr.t)
        (cO : Constr.t)
        (cS : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gO : Constr.t)
        (gS : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (idvar : Id.t)
        (varty : Constr.t)
        (term : Constr.t) : Constr.t =
    let fresh_set = let rec fold accu c = match Constr.kind c with
      | Constr.Var id -> Id.Set.add id accu
      | _ -> Constr.fold fold accu c
      in
      fold Id.Set.empty term in
    (*let idvar = Namegen.next_ident_away_from idvar (fun id -> Id.Set.mem id fresh_set) in*) (* stupid API *)
    let idvar = Namegen.next_ident_away_in_goal idvar fresh_set in
    let var = Constr.mkVar idvar in
    let rterm = unsafe_reify_PHOAS cVar cO cS cOp cLetIn gO gS gOp gLetIn var term in
    let rterm = Vars.substn_vars 1 [idvar] rterm in
    Constr.mkLambda (Name.Name idvar, varty, rterm)

let unsafe_Reify_HOAS
        (cVar : Constr.t)
        (cO : Constr.t)
        (cS : Constr.t)
        (cOp : Constr.t)
        (cLetIn : Constr.t)
        (gO : Constr.t)
        (gS : Constr.t)
        (gOp : Constr.t)
        (gLetIn : Constr.t)
        (term : Constr.t) : Constr.t =
    unsafe_reify_HOAS cVar cO cS cOp cLetIn gO gS gOp gLetIn term

DECLARE PLUGIN "reify"

open Ltac_plugin
open Stdarg
open Tacarg
open Names

(** Stolen from plugins/setoid_ring/newring.ml *)
open Tacexpr
open Misctypes
open Tacinterp
(* Calling a locally bound tactic *)
let ltac_lcall tac args =
  TacArg(Loc.tag @@ TacCall (Loc.tag (ArgVar(Loc.tag @@ Id.of_string tac),args)))

let ltac_apply (f : Value.t) (args: Tacinterp.Value.t list) =
  let fold arg (i, vars, lfun) =
    let id = Id.of_string ("x" ^ string_of_int i) in
    let x = Reference (ArgVar (Loc.tag id)) in
    (succ i, x :: vars, Id.Map.add id arg lfun)
  in
  let (_, args, lfun) = List.fold_right fold args (0, [], Id.Map.empty) in
  let lfun = Id.Map.add (Id.of_string "F") f lfun in
  let ist = { (Tacinterp.default_ist ()) with Tacinterp.lfun = lfun; } in
  Tacinterp.eval_tactic_ist ist (ltac_lcall "F" args)

let to_ltac_val c = Tacinterp.Value.of_constr c

open Pp

TACTIC EXTEND quote_term_cps_with_const
    | [ "quote_term_cps_with_const" "[" ident(idvar) "," constr(varty) "]" constr(cVar) constr(cConst) constr(cOp) constr(cLetIn) constr(gOp) constr(gLetIn) constr(term) tactic(tac) ] ->
      [ (** quote the given term, pass the result to t **)
  Proofview.Goal.enter begin fun gl ->
          let _ (*env*) = Proofview.Goal.env gl in
          let c = unsafe_Reify_PHOAS_with_const (EConstr.Unsafe.to_constr cVar) (EConstr.Unsafe.to_constr cConst) (EConstr.Unsafe.to_constr cOp) (EConstr.Unsafe.to_constr cLetIn) (EConstr.Unsafe.to_constr gOp) (EConstr.Unsafe.to_constr gLetIn) idvar (EConstr.Unsafe.to_constr varty) (EConstr.Unsafe.to_constr term) in
          ltac_apply tac (List.map to_ltac_val [EConstr.of_constr c])
  end ]
    | [ "quote_term_cps_with_const" constr(cVar) constr(cConst) constr(cOp) constr(cLetIn) constr(gOp) constr(gLetIn) constr(term) tactic(tac) ] ->
      [ (** quote the given term, pass the result to t **)
  Proofview.Goal.enter begin fun gl ->
          let _ (*env*) = Proofview.Goal.env gl in
          let c = unsafe_Reify_HOAS_with_const (EConstr.Unsafe.to_constr cVar) (EConstr.Unsafe.to_constr cConst) (EConstr.Unsafe.to_constr cOp) (EConstr.Unsafe.to_constr cLetIn) (EConstr.Unsafe.to_constr gOp) (EConstr.Unsafe.to_constr gLetIn) (EConstr.Unsafe.to_constr term) in
          ltac_apply tac (List.map to_ltac_val [EConstr.of_constr c])
  end ]
END;;

TACTIC EXTEND quote_term_cps
    | [ "quote_term_cps" "[" ident(idvar) "," constr(varty) "]" constr(cVar) constr(cO) constr(cS) constr(cOp) constr(cLetIn) constr(gO) constr(gS) constr(gOp) constr(gLetIn) constr(term) tactic(tac) ] ->
      [ (** quote the given term, pass the result to t **)
  Proofview.Goal.enter begin fun gl ->
          let _ (*env*) = Proofview.Goal.env gl in
          let c = unsafe_Reify_PHOAS (EConstr.Unsafe.to_constr cVar) (EConstr.Unsafe.to_constr cO) (EConstr.Unsafe.to_constr cS) (EConstr.Unsafe.to_constr cOp) (EConstr.Unsafe.to_constr cLetIn) (EConstr.Unsafe.to_constr gO) (EConstr.Unsafe.to_constr gS) (EConstr.Unsafe.to_constr gOp) (EConstr.Unsafe.to_constr gLetIn) idvar (EConstr.Unsafe.to_constr varty) (EConstr.Unsafe.to_constr term) in
          ltac_apply tac (List.map to_ltac_val [EConstr.of_constr c])
  end ]
    | [ "quote_term_cps" constr(cVar) constr(cO) constr(cS) constr(cOp) constr(cLetIn) constr(gO) constr(gS) constr(gOp) constr(gLetIn) constr(term) tactic(tac) ] ->
      [ (** quote the given term, pass the result to t **)
  Proofview.Goal.enter begin fun gl ->
          let _ (*env*) = Proofview.Goal.env gl in
          let c = unsafe_Reify_HOAS (EConstr.Unsafe.to_constr cVar) (EConstr.Unsafe.to_constr cO) (EConstr.Unsafe.to_constr cS) (EConstr.Unsafe.to_constr cOp) (EConstr.Unsafe.to_constr cLetIn) (EConstr.Unsafe.to_constr gO) (EConstr.Unsafe.to_constr gS) (EConstr.Unsafe.to_constr gOp) (EConstr.Unsafe.to_constr gLetIn) (EConstr.Unsafe.to_constr term) in
          ltac_apply tac (List.map to_ltac_val [EConstr.of_constr c])
  end ]
END;;
