.PHONY: all packages

include PerfData.mk
PERF_DATA_MD5 := $(addsuffix .md5,$(PERF_DATA))

all: rewriting.pdf rewriting-split-with-links

TRUST_PDFS := trust1.pdf trust2.pdf trust3.pdf trust4.pdf

$(TRUST_PDFS) : % : %.orig
	cp $< $@

rewriting.pdf: rewriting.bib rewriting-lower.bib $(PERF_DATA) $(PERF_DATA_MD5) $(TRUST_PDFS)

rewriting-main.pdf rewriting-supplement.pdf: rewriting.pdf rewriting.supplement.startpage

rewriting-main.pdf rewriting-supplement.pdf: BIBTEX=\# disable bibtex

.PHONY: rewriting-split-with-links
rewriting-split-with-links: rewriting.pdf rewriting.supplement.onlystartpage rewriting.supplement.onlyendpage
	pdftk rewriting.pdf cat 1-$$(( $$(cat rewriting.supplement.onlystartpage)-1 )) output rewriting-main.pdf
	pdftk rewriting.pdf cat $$(( $$(cat rewriting.supplement.onlystartpage) ))-$$(( $$(cat rewriting.supplement.onlyendpage) )) output rewriting-supplement.pdf

rewriting-lower.bib: rewriting.bib
	sed -e s'/Title\(\s*=\)/title\1/g' -e s'/Author\(\s*=\)/author\1/g' $< > $@

.PHONY: remake-PerfData.mk
remake-PerfData.mk:
	(echo "PERF_DATA := \\"; (git ls-files "perf-*.txt" "perf-*.csv" | sed s'/\(.*\)/\t\1 \\/g' | sed s'/;/\\;/g'); echo '\t#') > PerfData.mk

LATEXFLAGS?=-shell-escape
PDFLATEX?=lualatex
MD5?=md5sum

include ../Makefile.common

clean::
	@ rm -f rewriting-figure*

%.md5: %
	$(MD5) '$<' | awk '{print $$1}' > '$@'

WGET ?= wget

DOWNLOAD_STY :=
DOWNLOAD_GENERIC_STY := iftex.sty
DTX_INS_STY := usebib.sty
DTX_LATEX_STY :=
ALL_DTX_LATEX_STY := stmaryrd.sty $(DTX_LATEX_STY)
ALL_INS_LATEX_CLS := acmart.cls
SIMPLE_DTX_ZIPS := stmaryrd.zip
SIMPLE_INS_ZIPS := acmart.zip
ZIPS := $(SIMPLE_DTX_ZIPS) $(SIMPLE_INS_ZIPS)

FIND_ARGS := -name "*.sty" -o -name "*.tex" -o -name "*.map" -o -name "*.afm" -o -name "*.enc" -o -name "*.mf" -o -name "*.pfm" -o -name "*.pro" -o -name "*.tfm" -o -name "*.pfb" -o -name "*.fd" -o -name "*.def" -o -name "*.csf" -o -name "*.bst" -o -name "*.cfg" -o -name "*.cbx" -o -name "*.bbx" -o -name "*.lbx" -o -name "*.dtx" -o -name "*.ins" -o -name "*.600pk" -o -name "*.cmap" -o -name "*.drv"

packages: $(DOWNLOAD_GENERIC_STY) $(DOWNLOAD_STY) $(DTX_INS_STY) $(ALL_DTX_LATEX_STY) $(ALL_INS_LATEX_CLS)

$(DTX_INS_STY) : %.sty : %.dtx

$(DTX_INS_STY) : %.sty : %.ins
	latex $<

$(ALL_DTX_LATEX_STY) : %.sty : %.dtx
	latex $<

$(ALL_INS_LATEX_CLS) : %.cls : %.ins
	latex $<

$(SIMPLE_DTX_ZIPS:.zip=.dtx) : %.dtx : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

$(SIMPLE_INS_ZIPS:.zip=.ins) : %.ins : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

$(DOWNLOAD_STY) : %.sty :
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$*/$@"

$(DOWNLOAD_GENERIC_STY) : %.sty :
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$*/$@"

$(DTX_INS_STY:.sty=.ins):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.ins=)/$@"

$(DTX_INS_STY:.sty=.dtx):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.dtx=)/$@"

stmaryrd.zip:
	$(WGET) -N "https://mirrors.ctan.org/fonts/$@"

acmart.zip:
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$@"
