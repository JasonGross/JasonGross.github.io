
.PHONY: all

BIBTEX2HTML=bibtex2html-1.97/bibtex2html

all: jason-gross.bib.html

jason-gross.bib.html: jason-gross.bib $(BIBTEX2HMTL)
	$(BIBTEX2HTML)

bibtex2html-1.97/bibtex2html: bibtex2html-1.97/Makefile
	cd bibtex2html-1.97; $(MAKE)

bibtex2html-1.97/Makefile: bibtex2html-1.97/configure
	cd bibtex2html-1.97; ./configure --prefix "$(readlink -f .)"
