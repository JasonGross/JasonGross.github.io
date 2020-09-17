all: coq-workshop-proposal-notations.pdf html

.PHONY: all html

%.pdf: %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<

VFILES := NotationsCheatSheet.v NotationsCoqWorkshop.v NotationsMITPresentation.v Notations.v

html: $(VFILES:.v=.vo) Makefile.coq
	$(MAKE) -f Makefile.coq html

%.vo: %.v Makefile.coq
	$(MAKE) -f Makefile.coq $@

Makefile.coq: $(VFILES) Makefile
	$(COQBIN)coq_makefile $(VFILES) -R . CoqWorkshop -o $@
