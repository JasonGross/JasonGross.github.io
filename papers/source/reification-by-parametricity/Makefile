all: paper

.PHONY: paper clean

CODE := \
	Common.v \
	PHOAS.v \
	ReifyCommon.v \
	PrimPair.v \
	CanonicalStructuresReifyCommon.v \
	TypeClasses.v \
	TypeClassesBodyFlatPHOAS.v \
	TypeClassesBodyHOAS.v \
	LtacPrimUncurry.v \
	LtacTCPrimPair.v \
	LtacTCGallinaCtx.v \
	LtacTCExplicitCtx.v \
	LtacTacInTermPrimPair.v \
	LtacTacInTermGallinaCtx.v \
	LtacTacInTermExplicitCtx.v \
	CanonicalStructuresFlatHOAS.v \
	CanonicalStructuresFlatPHOAS.v \
	CanonicalStructuresHOAS.v \
	CanonicalStructuresPHOAS.v \
	Mtac2.v \
	Ltac2Common.v \
	Ltac2.v \
	Ltac2LowLevel.v \
	OCamlReify.v \
	OCaml.v \
	TemplateCoq.v \
	QuoteFlat.v \
	Parametricity.v \
	ParametricityWithConst.v \
	PHOASUtil.v \
	BenchmarkUtil.v \
	ExampleSelfContainedParametricity.v \
	ExampleMoreParametricity.v

OCAML_CODE := #\
#	reify_plugin.ml4


GRAPHS := \
	big-actual-reif-2.pdf \
	big-actual-reif-loglog-2.pdf \
	big-actual-reif-loglog.pdf \
	big-actual-reif.pdf \
	big-flat-actual-reif-loglog.pdf \
	big-flat-actual-reif.pdf \
	big-flat-Stats-loglog.pdf \
	big-norm-reif-loglog.pdf \
	big-norm-reif.pdf \
	big-Stats-loglog.pdf \
	big-Stats.pdf \
	actual-reif-no-binders.pdf \
	actual-reif-with-binders.pdf \
	actual-reif-with-binders-log-log.pdf \
	actual-reif-with-binders-log-log-subset.pdf

paper: reification-by-parametricity.pdf

.PHONY: $(CODE:%.v=%.v.raw.tex)
$(CODE:%.v=%.v.raw.tex) : %.v.raw.tex : benchmark/%.v
	$(COQBIN)coqdoc --latex --body-only --short --output $@ $<

#.PHONY: $(OCAML_CODE:%=%.raw.tex)
#$(OCAML_CODE:%=%.raw.tex) : %.raw.tex : benchmark/%
#	ocamldoc -latex -o $@ -impl $<

.PHONY: code-tex
code-tex: $(CODE:%=%.raw.tex) $(OCAML_CODE:%=%.raw.tex)
	for i in $(CODE) $(OCAML_CODE); do cp $$i.raw.tex $$i.tex; done

EXTRA_DEPS := reification-by-parametricity.tex llncs.cls splncs04.bst reification-by-parametricity.bib coqdoc.sty
DEPS := $(EXTRA_DEPS) $(GRAPHS) $(CODE:%.v=%.v.tex)
reification-by-parametricity.pdf: $(DEPS)

reification-by-parametricity.pdf : %.pdf : %.tex
	pdflatex -interaction=batchmode -synctex=1 $< || true
	bibtex ${<:.tex=}
	pdflatex -interaction=batchmode -synctex=1 $< || true
	pdflatex -synctex=1 $<

clean::
	@ rm -f *.aux *.out *.nav *.toc *.vrb reification-by-parametricity.pdf *.snm *.log *.bbl *.blg

.PHONY: graphs
graphs: benchmark/bench.wl benchmark/reification-by-parametricity-graphs.wls
	(cd benchmark; wolframscript -script reification-by-parametricity-graphs.wls)
	$(MAKE) copy-graphs

.PHONY: copy-graphs
copy-graphs:
	(cd benchmark; cp -f -t ../ $(GRAPHS))

.PHONY: reification-by-parametricity.tar.gz
reification-by-parametricity.tar.gz:
	rm -rf $@ && ( git ls-files benchmark | grep -v bench.wl | grep -v extra-logs/bench-auto- | xargs tar -czvf $@ )

.PHONY: reification-by-parametricity.zip
reification-by-parametricity.zip:
	rm -rf $@ && ( git ls-files benchmark | grep -v bench.wl | grep -v extra-logs/bench-auto- | xargs zip -9 $@ )

.PHONY: supplementary.tar.gz
supplementary.tar.gz:
	wget "https://github.com/mit-plv/reification-by-parametricity/archive/v1.0.tar.gz" -O "$@"

.PHONY: camera-ready.zip
camera-ready.zip: $(DEPS)
	rm -rf camera-ready
	mkdir camera-ready
	cp -t camera-ready/ $(DEPS)
	test -f supplementary.tar.gz || $(MAKE) supplementary.tar.gz
	tar -xzf supplementary.tar.gz
	mv -f reification-by-parametricity-1.0 "camera-ready/Electronic Supplementary Material"
	(cd camera-ready && pdflatex -interaction=batchmode -synctex=1 reification-by-parametricity.tex || true)
	(cd camera-ready && bibtex reification-by-parametricity)
	(cd camera-ready && pdflatex -interaction=batchmode -synctex=1 reification-by-parametricity.tex || true)
	(cd camera-ready && pdflatex -synctex=1 reification-by-parametricity.tex)
	(cd camera-ready && zip -r ../$@ *)
