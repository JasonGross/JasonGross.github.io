.PHONY: all paper packages

SPLIT_TARGETS := fiat-crypto-p1-13.pdf fiat-crypto-p14-end.pdf

paper: fiat-crypto.pdf
all: paper $(SPLIT_TARGETS)

fiat-crypto.pdf::  fiat-crypto.bib

$(SPLIT_TARGETS) : fiat-crypto-p%.pdf : fiat-crypto.pdf
	pdftk $< cat $* output $@

include ../Makefile.common

DOWNLOAD_STY := iftex.sty
TEX_STY := mathtools.sty mhsetup.sty
DOWNLOAD_DTX := mathtools.dtx

packages: $(DOWNLOAD_STY) $(TEX_STY) tkz-graph.sty

$(TEX_STY) : %.sty : %.dtx
	tex $<

$(DOWNLOAD_STY) : %.sty :
	wget -N "http://mirrors.ctan.org/macros/latex/contrib/$*/$@"

tkz-graph.sty:
	wget -N "http://mirrors.ctan.org/macros/latex/contrib/tkz/tkz-graph/latex/$@"

$(DOWNLOAD_DTX) : %.dtx :
	wget -N "http://mirrors.ctan.org/macros/latex/contrib/$*/$@"

mhsetup.dtx:
	wget -N "http://mirrors.ctan.org/macros/latex/contrib/mathtools/$@"
