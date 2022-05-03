.PHONY: all clean zip remake-patch

all: bcprules.sty rewriting.tex rewriting.bib
	pdflatex -shell-escape rewriting.tex
	bibtex rewriting.aux
	pdflatex -shell-escape rewriting.tex
	pdflatex -shell-escape rewriting.tex

rewriting.tex: ../rewriting.tex diff.patch
	cp ../rewriting.tex $@ && patch -p3 $@ diff.patch

rewriting.bib : % : ../%
	cp $< $@

remake-patch:
	{ diff -Naur ../rewriting.tex rewriting.tex; true; } > diff.patch

clean::
	rm -rf *~ \#* rewriting-for-split.tex rewriting.pdf *.pyg *.out *.aux *.auxlock *.log *.vtc *.blg _minted-rewriting-for-split/ _minted-rewriting/ rewriting-for-split.appendix.startpage *.dep *.dpth *.bbl rewriting-for-split.supplement.onlyendpage rewriting-for-split.supplement.onlystartpage rewriting-main.pdf
	rm -f rewriting.appendix.startpage rewriting.supplement.onlyendpage rewriting.supplement.onlystartpage rewriting.supplement.startpage
	# bcprules.sty
	# rewriting-for-split.supplement.startpage rewriting-for-split.pdf

zip: clean
	rm -f ../source.zip
	zip -r ../source.zip .

bcprules.sty: ../bcprules.sty
	cp $< $@
