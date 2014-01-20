
.PHONY: all clean

BIBTEX2HTML=bibtex2html-1.97/bibtex2html

all: jason-gross-stripped.html

clean:
	rm -f jason-gross.html jason-gross_bib.html jason-gross-stripped.html

jason-gross-stripped.html: jason-gross.html Makefile
	sed s'/This file/This reference list/g' $< | sed s'/<hr>//g' | sed s'/h1/h2/g' > $@

jason-gross.html: jason-gross.bib $(BIBTEX2HMTL)
	$(BIBTEX2HTML) -d -nodoc --title "Papers" $<

bibtex2html-1.97/bibtex2html: bibtex2html-1.97/Makefile
	cd bibtex2html-1.97; $(MAKE)

bibtex2html-1.97/Makefile: bibtex2html-1.97/configure
	cd bibtex2html-1.97; ./configure --prefix "$(readlink -f .)"
