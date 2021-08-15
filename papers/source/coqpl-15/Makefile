.PHONY: all clean paper

all: paper

paper: coq-bug-minimizer.pdf

%.pdf: %.tex
	pdflatex -synctex=1 $<

clean:
	@ rm -f *.aux *.out *.nav *.toc *.vrb coq-bug-minimizer.pdf *.snm *.log *.bbl *.blg
