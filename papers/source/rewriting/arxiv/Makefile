.PHONY: cache all clean zip remake-patch

all: bcprules.sty rewriting.tex rewriting.bib
	sed -i 's/finalizecache/frozencache/g' rewriting.tex
	pdflatex rewriting.tex
	bibtex rewriting.aux
	pdflatex rewriting.tex
	pdflatex rewriting.tex

cache: bcprules.sty
	sed -i 's/frozencache/finalizecache/g' rewriting.tex
	pdflatex -shell-escape rewriting.tex

rewriting.tex: ../rewriting.tex diff.patch
	cp ../rewriting.tex $@ && patch -p3 $@ diff.patch

rewriting.bib : % : ../%
	cp $< $@

remake-patch:
	{ diff -Naur ../rewriting.tex rewriting.tex; true; } > diff.patch

clean::
	rm -rf *~ \#* rewriting-for-split.tex rewriting.pdf *.pyg *.out *.aux *.auxlock *.log *.vtc *.blg _minted-rewriting-for-split/ rewriting-for-split.appendix.startpage *.dep *.dpth rewriting-for-split.supplement.onlyendpage rewriting-for-split.supplement.onlystartpage rewriting-main.pdf
	rm -f rewriting.appendix.startpage rewriting.supplement.onlyendpage rewriting.supplement.onlystartpage rewriting.supplement.startpage
	# bcprules.sty
	# rewriting-for-split.supplement.startpage rewriting-for-split.pdf

zip: clean
	rm -f ../arxiv.zip
	zip -r ../arxiv.zip .

bcprules.sty: ../bcprules.sty
	cp $< $@
