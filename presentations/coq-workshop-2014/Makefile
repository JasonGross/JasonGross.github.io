all: coq-workshop-proposal-tactics-in-terms.pdf html/CoqWorkshop.tactics_in_terms_paper_examples.html

%.pdf: %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<

html/CoqWorkshop.tactics_in_terms_paper_examples.html: tactics_in_terms_paper_examples.vo Makefile.coq
	$(MAKE) -f Makefile.coq html

%.vo: %.v Makefile.coq
	$(MAKE) -f Makefile.coq $@

Makefile.coq: tactics_in_terms_paper_examples.v Makefile
	coq_makefile tactics_in_terms_paper_examples.v -R . CoqWorkshop -o $@
