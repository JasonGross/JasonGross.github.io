all: paper

paper: category-coq-experience.pdf category-coq-experience-noheads.pdf category-coq-experience-arxiv.pdf

category-coq-experience-noheads.tex: category-coq-experience.tex
	sed s'/\[runningheads\]//g' $< | sed s'/\\pagestyle{headings}//g' > $@

category-coq-experience-arxiv.tex: category-coq-experience.tex
	sed s'/%fullbib://g' $< | sed s'/category-coq-experience-no-urls.bib/category-coq-experience.bib/g' > $@

category-coq-experience.pdf category-coq-experience-noheads.pdf category-coq-experience-arxiv.pdf: category-coq-experience.tex category-coq-experience-no-urls.bib llncs.cls lncs.bbx lncs.dbx lncs.cbx

comparison-table.tex: make_comparison_table.py
	python make_comparison_table.py

category-coq-experience-no-urls.bib: category-coq-experience.bib keep_only_good_urls.py
	python keep_only_good_urls.py $< > $@

category-coq-experience.pdf category-coq-experience-noheads.pdf: comparison-table.tex

%.pdf: %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	bibtex ${<:.tex=}
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<
	@ echo
	@ if [ ! -z "$$(cat "category-coq-experience.bib" | grep -o '[^] %$[:space:]!"#$%&'"'"'()*+,\./0-9:;<=>?@A-Z[\\^_`a-z{|}~-]' | sort | uniq | tr '\n' ' ' | sed s'/ //g')" ]; then \
	echo "Unicode characters in .bib file:"; \
	cat "category-coq-experience.bib" | grep -o '[^] %$[:space:]!"#$%&'"'"'()*+,\./0-9:;<=>?@A-Z[\\^_`a-z{|}~-]' | sort | uniq | tr '\n' ' ' | sed s'/ //g'; \
	echo ; \
	cat "category-coq-experience.bib" | grep -C 2 '[^] %$[:space:]!"#$%&'"'"'()*+,\./0-9:;<=>?@A-Z[\\^_`a-z{|}~-]'; \
	echo ;\
	fi
	@ echo
	@ echo "Instances of 'you' in the file are:"
	@ grep -o "[^\.\!]\+ you [^\.\!]\+" $< | sed s'/^ \+//g'
	@ echo
	@ echo "Contractions in the file are:"
	@ grep -o "[a-zA-Z]\+'[a-zA-Z]\+" $<

clean:
	@ rm -f *.aux *.out *.nav *.toc *.vrb category-coq-experience.pdf category-coq-experience-noheads.pdf category-coq-experience-arxiv.pdf *.snm *.log *.bbl *.blg comparison-table.tex category-coq-experience-no-urls.bib
