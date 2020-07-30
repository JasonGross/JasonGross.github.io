.PHONY: all paper packages

all: paper

paper: parsing-parse-trees.pdf

parsing-parse-trees.pdf: parsing-parse-trees.tex references.bib parsing-parses.tar.txt

include ../Makefile.common

OBERDIEK_PACKAGES := attachfile2 infwarerr ltxcmds pdftexcmds kvdefinekeys atveryend rerunfilecheck kvoptions auxhook uniquecounter ifluatex ifpdf gettitlestring

TEX_STY := mathtools.sty mhsetup.sty $(addsuffix .sty,$(OBERDIEK_PACKAGES))
INS_STY := hyperref.sty
HYPERREF_DTX := hyperref.dtx nameref.dtx backref.dtx

packages: $(TEX_STY) $(INS_STY)

$(TEX_STY) : %.sty : %.dtx
	tex $<

$(INS_STY) : %.sty : %.dtx %.ins $(HYPERREF_DTX)
	latex $*.ins

mathtools.dtx mhsetup.dtx:
	wget -N http://mirrors.ctan.org/macros/latex/contrib/mathtools/$@

$(addsuffix .dtx,$(OBERDIEK_PACKAGES)):
	wget -N http://www.ctan.org/tex-archive/macros/latex/contrib/oberdiek/$@

hyperref.ins $(HYPERREF_DTX):
	wget -N http://mirrors.ctan.org/macros/latex/contrib/hyperref/$@

parsing-parses.tar.txt: parsing-parses.tar.gz
	gunzip -c $< > $@
