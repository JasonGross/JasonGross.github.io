
.PHONY: all clean

BIBTEX2HTML=bibtex2html-1.97/bibtex2html
BIBTEX2HTML_ARGS=-d -r -nodoc -nf videos videos -nf reviews reviews -nf full-bibliography "full bibliography" -nf code-v "code (.v)" -nf code-html "code (.html)"

COQBIN=$(shell readlink -f ~/.local64/coq/coq-trunk/bin)/

OUTPUTS := jason-gross-stripped.html presentations/coq-8.6-wishlist/jgross-coq-8-6-wishlist-no-pause.pdf presentations/csw-2013/jgross-presentation-no-pause.pdf presentations/popl-2013/jgross-student-talk.pdf presentations/popl-2013/minute-madness.pdf resume/resume.pdf papers/category-coq-experience.html jason-gross.html papers/category-coq-experience-filtered.bib presentations/coq-workshop-2014/coq-workshop-proposal-tactics-in-terms.pdf presentations/coq-workshop-2014/html/CoqWorkshop.tactics_in_terms_paper_examples.html

all: $(OUTPUTS)

clean:
	rm -f jason-gross_bib.html papers/category-coq-experience_bib.html $(OUTPUTS)

jason-gross-stripped.html: jason-gross.html Makefile
	sed s'/This file/This reference list/g' $< | sed s'/<hr>//g' | sed s'/h1/h2/g' > $@

jason-gross.html: %.html : %.bib $(BIBTEX2HMTL) Makefile
	$(BIBTEX2HTML) $(BIBTEX2HTML_ARGS) --title "Papers and Presentations" -o "$*" "$<"

papers/category-coq-experience.html: %.html : %-filtered.bib $(BIBTEX2HMTL) Makefile
	$(BIBTEX2HTML) $(BIBTEX2HTML_ARGS) --title "Experience Implementing a Performant Category-Theory Library in Coq: Complete List of References" -o "$*" "$<"

papers/category-coq-experience-filtered.bib: papers/category-coq-experience.bib Makefile
	@echo "FILTER $< > $@"
	@cat "$<" | \
	sed s'/@ELECTRONIC/@MISC/g' | \
	sed s'/-old = / = /g' | \
	sed s'/howpublished = {\\url{\([^}]\+\)}}/url = {\1}/g' | \
	sed s'/month = {1}/month = {January}/g' | \
	sed s'/month = {2}/month = {February}/g' | \
	sed s'/month = {3}/month = {March}/g' | \
	sed s'/month = {4}/month = {April}/g' | \
	sed s'/month = {5}/month = {May}/g' | \
	sed s'/month = {6}/month = {June}/g' | \
	sed s'/month = {7}/month = {July}/g' | \
	sed s'/month = {8}/month = {August}/g' | \
	sed s'/month = {9}/month = {September}/g' | \
	sed s'/month = {10}/month = {October}/g' | \
	sed s'/month = {11}/month = {November}/g' | \
	sed s'/month = {12}/month = {December}/g' > $@


bibtex2html-1.97/bibtex2html: bibtex2html-1.97/Makefile
	cd bibtex2html-1.97; $(MAKE)

bibtex2html-1.97/Makefile: bibtex2html-1.97/configure
	cd bibtex2html-1.97; ./configure --prefix "$(readlink -f .)"

resume/resume.pdf: resume/Makefile resume/Resume.tex
	cd resume; $(MAKE)

presentations/coq-8.6-wishlist/jgross-coq-8-6-wishlist-no-pause.pdf: presentations/coq-8.6-wishlist/jgross-coq-8-6-wishlist.tex presentations/coq-8.6-wishlist/Makefile presentations/coq-8.6-wishlist/appendixnumberbeamer.sty
	cd presentations/coq-8.6-wishlist; $(MAKE)

presentations/csw-2013/jgross-presentation-no-pause.pdf: presentations/csw-2013/jgross-presentation.tex presentations/csw-2013/Makefile
	cd presentations/csw-2013; $(MAKE)

presentations/popl-2013/%.pdf: presentations/popl-2013/%.tex presentations/popl-2013/Makefile
	cd presentations/popl-2013; $(MAKE) $(*:=.pdf)

presentations/coq-workshop-2014/%.pdf: presentations/coq-workshop-2014/%.tex presentations/coq-workshop-2014/Makefile
	cd presentations/coq-workshop-2014; $(MAKE) $(*:=.pdf)

presentations/coq-workshop-2014/html/CoqWorkshop.%.html: presentations/coq-workshop-2014/%.v presentations/coq-workshop-2014/Makefile
	cd presentations/coq-workshop-2014; $(MAKE) COQBIN="$(COQBIN)" html/CoqWorkshop.$(*:=.html)
