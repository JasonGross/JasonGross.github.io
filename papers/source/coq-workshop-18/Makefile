all: proposal

.PHONY: proposal clean

proposal: proposal.pdf

proposal.pdf : %.pdf : %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<

clean::
	@ rm -f *.aux *.out *.nav *.toc *.vrb proposal.pdf *.snm *.log *.bbl *.blg
