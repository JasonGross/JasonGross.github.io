all: coq-workshop-proposal-tactics-in-terms.pdf

%.pdf: %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<
