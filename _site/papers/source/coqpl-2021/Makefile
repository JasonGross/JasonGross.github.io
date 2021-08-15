.PHONY: all clean paper

all: paper

paper: reification-by-type-inference.pdf

reification-by-type-inference.pdf: reification_by_type_inference_tex.v

%.pdf: %.tex
	pdflatex -synctex=1 $<

clean:
	@ rm -f *.aux *.out *.nav *.toc *.vrb reification-by-type-inference.pdf *.snm *.log *.bbl *.blg
