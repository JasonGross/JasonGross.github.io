all: coq-workshop-proposal-tactics-in-terms.pdf html

.PHONY: all html

%.pdf: %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<

html: tactics_in_terms_paper_examples.vo tactics_in_terms_presentation.vo Makefile.coq
	$(MAKE) -f Makefile.coq html

%.vo: %.v Makefile.coq
	$(MAKE) -f Makefile.coq $@

Makefile.coq: tactics_in_terms_paper_examples.v tactics_in_terms_presentation.v Makefile
	coq_makefile tactics_in_terms_paper_examples.v tactics_in_terms_presentation.v -R . CoqWorkshop -o $@
