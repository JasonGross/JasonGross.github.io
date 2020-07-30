.PHONY: all packages

include PerfData.mk
PERF_DATA_MD5 := $(addsuffix .md5,$(PERF_DATA))

all: rewriting.pdf rewriting-main.pdf rewriting-supplement.pdf

TRUST_PDFS := trust1.pdf trust2.pdf trust3.pdf trust4.pdf

$(TRUST_PDFS) : % : %.orig
	cp $< $@

rewriting.pdf: rewriting.bib rewriting-lower.bib $(PERF_DATA) $(PERF_DATA_MD5) $(TRUST_PDFS)

rewriting-main.pdf rewriting-supplement.pdf: rewriting.pdf rewriting.supplement.startpage

rewriting-main.pdf rewriting-supplement.pdf: BIBTEX=\# disable bibtex

rewriting-lower.bib: rewriting.bib
	sed -e s'/Title\(\s*=\)/title\1/g' -e s'/Author\(\s*=\)/author\1/g' $< > $@

.PHONY: remake-PerfData.mk
remake-PerfData.mk:
	(echo "PERF_DATA := \\"; (git ls-files "perf-*.txt" | sed s'/\(.*\)/\t\1 \\/g' | sed s'/;/\\;/g'); echo '\t#') > PerfData.mk

LATEXFLAGS?=-shell-escape
PDFLATEX?=lualatex
MD5?=md5sum

include ../Makefile.common

clean::
	@ rm -f rewriting-figure*

%.md5: %
	$(MD5) '$<' | awk '{print $$1}' > '$@'

WGET ?= wget

DOWNLOAD_STY := iftex.sty
DTX_INS_STY := usebib.sty
DTX_LATEX_STY =
ALL_DTX_LATEX_STY = stmaryrd.sty $(DTX_LATEX_STY)
SIMPLE_DTX_ZIPS = stmaryrd.zip
ZIPS = $(SIMPLE_DTX_ZIPS)

FIND_ARGS = -name "*.sty" -o -name "*.tex" -o -name "*.map" -o -name "*.afm" -o -name "*.enc" -o -name "*.mf" -o -name "*.pfm" -o -name "*.pro" -o -name "*.tfm" -o -name "*.pfb" -o -name "*.fd" -o -name "*.def" -o -name "*.csf" -o -name "*.bst" -o -name "*.cfg" -o -name "*.cbx" -o -name "*.bbx" -o -name "*.lbx" -o -name "*.dtx" -o -name "*.ins" -o -name "*.600pk" -o -name "*.cmap" -o -name "*.drv"

packages: $(DOWNLOAD_STY) $(DTX_INS_STY) $(ALL_DTX_LATEX_STY)

$(DTX_INS_STY) : %.sty : %.dtx

$(DTX_INS_STY) : %.sty : %.ins
	latex $<

$(ALL_DTX_LATEX_STY) : %.sty : %.dtx
	latex $<

$(SIMPLE_DTX_ZIPS:.zip=.dtx) : %.dtx : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

$(DOWNLOAD_STY) : %.sty :
	$(WGET) -N "http://mirrors.ctan.org/macros/latex/contrib/$*/$@"

$(DTX_INS_STY:.sty=.ins):
	$(WGET) -N "http://mirrors.ctan.org/macros/latex/contrib/$(@:.ins=)/$@"

$(DTX_INS_STY:.sty=.dtx):
	$(WGET) -N "http://mirrors.ctan.org/macros/latex/contrib/$(@:.dtx=)/$@"

stmaryrd.zip:
	$(WGET) -N "http://mirrors.ctan.org/fonts/$@"
