all: jgross-presentation.pdf jgross-presentation-no-pause.pdf

%.pdf: %.tex
	pdflatex $< && pdflatex $<

jgross-presentation-no-pause.tex: jgross-presentation.tex
	sed s'/\\pause//g' jgross-presentation.tex > jgross-presentation-no-pause.tex
