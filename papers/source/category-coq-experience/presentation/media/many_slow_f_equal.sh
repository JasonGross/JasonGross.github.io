#!/bin/bash

if [ -z "$4" ]; then
    echo "Usage: $0 HEADER FILENAME TOTAL-ITERATIONS MIN-DUP MAX-DUP"
    exit 1
fi

if [ -z "$COQC" ]; then
    COQC=coqc
fi

HEADER="$1"
HEADER_FILENAME="$1.v"
OUT="$2"
FILENAME="$2.v"
TOTAL="$3"
MIN_DUP="$4"
MAX_DUP="$5"

#echo "$FILENAME"

rm -f "$HEADER_FILENAME" "$FILENAME"

for i in $(seq $MIN_DUP $MAX_DUP)
do
    echo -n "Axiom iter$i : " >> "$HEADER_FILENAME"
    for j in $(seq 1 $i)
    do
        echo -n "bool -> " >> "$HEADER_FILENAME"
    done
    echo "bool." >> "$HEADER_FILENAME"
    cat >> "$HEADER_FILENAME" <<EOF
Fixpoint do$i (n : nat) (A : bool) :=
  match n with
    | 0 => A
EOF
    echo -n "    | S n' => do$i n' (iter$i" >> "$HEADER_FILENAME"
    for j in $(seq 1 $i)
    do
        echo -n " A" >> "$HEADER_FILENAME"
    done
    echo ")" >> "$HEADER_FILENAME"
    echo "  end." >> "$HEADER_FILENAME"

    echo "Ltac display$i := match goal with |- let n := ?k in _ => "'idtac "['"$i"'][" k "] :="'" end; hnf; unfold do$i; cbv beta." >> "$HEADER_FILENAME"
done



for i in $(seq $MIN_DUP $MAX_DUP)
do
    TAC_I=0
    for tac in "apply f_equal" \
	"lazymatch goal with |- ?f ?a = ?g ?b => idtac end" \
	"lazymatch goal with |- ?f ?a = ?g ?b => let H := constr:(@f_equal bool bool f a b) in idtac end" \
	"lazymatch goal with |- ?f ?a = ?g ?b => let H := constr:(@f_equal bool bool f a b (@eq_refl bool a)) in idtac end" \
	"lazymatch goal with |- ?f ?a = ?g ?b => let H := constr:(@f_equal bool bool f a b (@eq_refl bool a)) in exact_no_check H end" \
	"lazymatch goal with |- ?f ?a = ?g ?b => let H := constr:(@f_equal bool bool f a b (@eq_refl bool a)) in exact H end" \
	"lazymatch goal with |- ?f ?a = ?g ?b => let H := constr:(@f_equal bool bool f a b (@eq_refl bool a)) in apply H end" \
        "destruct x" \
        "generalize x" \
	"set (y := x)" \
	"set (y := bool)" \
	"match goal with |- ?G => set (y := G) end" \
	"assert (z := true); destruct z" \
	"assert (z := true); revert z" \
	"assert (z := true); generalize z"
    do
	CUR_FILENAME="${OUT}_${i}_${TAC_I}.v"
	TAC_I="$(($TAC_I + 1))"

	echo "Making $CUR_FILENAME..."

	echo "Require Import $HEADER." > "$CUR_FILENAME"
	echo "Axiom x : bool." >> "$CUR_FILENAME"



	for k in $(seq 1 $TOTAL)
	do
	    cat >> "$CUR_FILENAME" <<EOF
Goal True. idtac "%Timings['$tac']". Admitted.
EOF

            echo "Goal let n := $k in do$i n x = do$i n x. display$i. Time ($tac). Admitted." >> "$CUR_FILENAME"
	    echo 'Goal True. idtac "". Admitted.' >> "$FILENAME"
	done
    done


#echo "$COQC $FILENAME > $OUT"

done

echo "$COQC" "$HEADER_FILENAME"
$COQC "$HEADER_FILENAME"

for i in $(seq $MIN_DUP $MAX_DUP)
do
    for TAC_I in $(seq 0 14)
    do
	CUR_FILENAME="${OUT}_${i}_${TAC_I}.v"

#    echo "$COQC" "$CUR_FILENAME"

	$COQC "$CUR_FILENAME" | sed s'/Finished transaction in [0-9\.]\+ secs (\([0-9\.]\+\)u.*/\1;/g' | tr "'" '"' | tr '\n' ' ' | tr '%' '\n' | sed s'/\s*\]\s*/]/g' | sed s'/\s*\[\s*/[/g' | sed s'/\.;/.0;/g'; echo
    done
done
