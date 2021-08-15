V = 0

Q_0 := @
Q_1 :=
Q = $(Q_$(V))

VECHO_0 := @echo
VECHO_1 := @true
VECHO = $(VECHO_$(V))

QECHO_0 := @true
QECHO_1 := @echo
QECHO = $(QECHO_$(V))

.PHONY: all dependencies

WGET ?= wget

BIBER = $(shell which ./biber 2>/dev/null || echo biber)

all: Resume.pdf JasonGross-curriculum-vitae.pdf

Resume-curriculum-vitae.pdf: Resume.pdf

JasonGross-curriculum-vitae.pdf: Resume-curriculum-vitae.pdf | Resume.pdf
	cp $< $@

# "-e '" + "' -e '".join(['s/month = {%s},/month = {%d},/g' % (datetime.date(2015, i, 1).strftime('%B'), i) for i in range(1,13)]) + "'"
jason-gross.bib: publications/jason-gross.bib
	sed -e 's/month\s*=\s*{January},/month = {1},/g' -e 's/month\s*=\s*{February},/month = {2},/g' -e 's/month\s*=\s*{March},/month = {3},/g' -e 's/month\s*=\s*{April},/month = {4},/g' -e 's/month\s*=\s*{May},/month = {5},/g' -e 's/month\s*=\s*{June},/month = {6},/g' -e 's/month\s*=\s*{July},/month = {7},/g' -e 's/month\s*=\s*{August},/month = {8},/g' -e 's/month\s*=\s*{September},/month = {9},/g' -e 's/month\s*=\s*{October},/month = {10},/g' -e 's/month\s*=\s*{November},/month = {11},/g' -e 's/month\s*=\s*{December},/month = {12},/g' -e s'/•/\$$\\bullet\$$/g' $< > $@

Resume.pdf: Resume.tex res.cls jason-gross.bib
	pdflatex --enable-write18 -synctex=1 Resume.tex
	$(BIBER) Resume
	pdflatex --enable-write18 -synctex=1 -interaction=nonstopmode Resume.tex 2>/dev/null >/dev/null
	pdflatex --enable-write18 -synctex=1 Resume.tex

clean:
	rm -f *.pdf Resume-*.tex *.log *.out *.mtx *.aux *.bbl *.blg *.run.xml *.bcf *-blx.bib jason-gross.bib

.PHONY: all clean

UNIS-LARGE = #$(patsubst %,uni-%.def,$(shell seq 0 762))
UNIS = #uni-global.def
INS_STY = #ifmtarg.sty
DTX_STY = kvoptions.sty letltxmacro.sty hycolor.sty etexcmds.sty infwarerr.sty kvsetkeys.sty bitset.sty intcalc.sty bigintcalc.sty atbegshi.sty hopatch.sty atveryend.sty kvdefinekeys.sty rerunfilecheck.sty uniquecounter.sty auxhook.sty pdfescape.sty refcount.sty gettitlestring.sty #etextools.sty
GENERIC_DTX_STY = ltxcmds.sty pdftexcmds.sty #xstring.sty
ALL_DTX_STY = $(DTX_STY) $(GENERIC_DTX_STY)
DTX_LATEX_STY =
ALL_DTX_LATEX_STY = $(DTX_LATEX_STY) #stmaryrd.sty
REQUIRED_GRAPHICS_DTX_INS_STY = #graphics.sty
GENERIC_TEX_INS_STY = #ifxetex.sty
ALL_TEX_INS_STY = $(GENERIC_TEX_INS_STY)
BASE_DTX_INS_STY = #ifthen.sty
BASE_DTX_INS_DOWNLOAD = $(BASE_DTX_INS_STY:.sty=.dtx) ltoutenc.dtx classes.dtx
DTX_INS_STY = #filecontents.sty polytable.sty xcolor.sty minted.sty ifplatform.sty
ALL_DTX_INS_STY = $(DTX_INS_STY) $(BASE_DTX_INS_STY)
SIMPLE_TEX = #ifmtarg.tex
SIMPLE_DEPENDENCIES = logreq.sty etoolbox.sty #xifthen.sty url.sty #ucs.sty lazylist.sty lineno.sty upquote.sty slashbox.sty
SIMPLE_DEFS = logreq.def
GENERIC_STY = #xstring.sty
GENERIC_TEX = #xstring.tex
IFTEX_STY = iftex.sty ifpdf.sty ifvtex.sty ifluatex.sty
REQUIRED_DTX_INS_ZIPS = #graphics.zip tools.zip
REQUIRED_ZIPS = $(REQUIRED_DTX_INS_ZIPS)
SIMPLE_CONTRIB_ZIPS = biblatex.zip #cmap.zip mmap.zip
SIMPLE_CONTRIB_DTX_INS_ZIPS = hyperref.zip
CONTRIB_ZIPS = $(SIMPLE_CONTRIB_ZIPS) $(SIMPLE_CONTRIB_DTX_INS_ZIPS)
SIMPLE_ZIPS = $(SIMPLE_CONTRIB_ZIPS) #tipa.zip
SIMPLE_DTX_ZIPS = #stmaryrd.zip
NORMAL_ZIPS = $(SIMPLE_CONTRIB_ZIPS)
ZIPS = $(SIMPLE_ZIPS) $(SIMPLE_DTX_ZIPS) $(REQUIRED_ZIPS) $(SIMPLE_CONTRIB_DTX_INS_ZIPS)
BUILD_INS_STY = $(INS_STY) $(GENERIC_TEX_INS_STY) $(DTX_INS_STY) $(SIMPLE_CONTRIB_DTX_INS_ZIPS:.zip=.sty) $(BASE_DTX_INS_STY)
BIBER_TAR_GZ = biber-linux_x86_64.tar.gz
PRE_DEPENDENCIES = $(INS_STY:.sty=.ins) $(ALL_DTX_STY:.sty=.dtx) $(ALL_DTX_LATEX_STY:.sty=.dtx) $(ZIPS) $(ZIPS:.zip=/) $(BASE_DTX_INS_DOWNLOAD:.dtx=.ins) $(BASE_DTX_INS_DOWNLOAD) #graphics.ins # boxchar.sty codelist.sty exaccent.sty extraipa.sty tipaman.sty tipaman.tex tipaman0.tex tipaman1.tex tipaman2.tex tipaman3.tex tipaman4.tex tipx.sty tone.sty vowel.sty vowel.tex
DEPENDENCIES = $(GENERIC_STY) $(GENERIC_TEX) $(ALL_DTX_INS_STY) $(ALL_TEX_INS_STY) $(ALL_TEX_INS_STY) $(INS_STY) $(ALL_DTX_STY) $(ALL_DTX_LATEX_STY) $(SIMPLE_DEPENDENCIES) $(SIMPLE_TEX) $(SIMPLE_DEFS) $(UNIS) $(REQUIRED_GRAPHICS_DTX_INS_STY) $(NORMAL_ZIPS:.zip=.sty) $(IFTEX_STY) $(BIBER_TAR_GZ) biber hyperref.sty #article.cls #graphics.sty verbatim.sty etex.sty fontenc.sty # utf8x.def ucsencs.def uni-34.def uni-33.def uni-3.def uni-32.def uni-37.def uni-35.def uni-0.def uni-32.def uni-39.def tipa.sty uni-29.def uni-37.def uni-2.def uni-3.def cmap.sty mmap.sty
EXTRA_CLEAN_FILES = .tex 01-introduction.tex 02-annotations.tex 03-localization-keys.tex 10-references-per-section.tex 11-references-by-section.tex 12-references-by-segment.tex 13-references-by-keyword.tex 14-references-by-category.tex 15-references-by-type.tex 16-numeric-prefixed-1.tex 17-numeric-prefixed-2.tex 18-numeric-hybrid.tex 19-alphabetic-prefixed.tex 20-indexing-single.tex 21-indexing-multiple.tex 22-indexing-subentry.tex 30-style-numeric.tex 31-style-numeric-comp.tex 32-style-numeric-verb.tex 40-style-alphabetic.tex 41-style-alphabetic-verb.tex 42-style-alphabetic-template.tex 50-style-authoryear.tex 51-style-authoryear-ibid.tex 52-style-authoryear-comp.tex 53-style-authoryear-icomp.tex 60-style-authortitle.tex 61-style-authortitle-ibid.tex 62-style-authortitle-comp.tex 63-style-authortitle-icomp.tex 64-style-authortitle-terse.tex 65-style-authortitle-tcomp.tex 66-style-authortitle-ticomp.tex 70-style-verbose.tex 71-style-verbose-ibid.tex 72-style-verbose-note.tex 73-style-verbose-inote.tex 74-style-verbose-trad1.tex 75-style-verbose-trad2.tex 76-style-verbose-trad3.tex 80-style-reading.tex 81-style-draft.tex 82-style-debug.tex 90-related-entries.tex 91-sorting-schemes.tex 92-bibliographylists.tex 93-nameparts.tex README.txt afterpage.dtx afterpage.ins afterpage.sty array.dtx array.sty atbegshi-example1.tex atbegshi-example2.tex atbegshi-test1.tex atbegshi-test2.tex atbegshi-test3.tex atbegshi.ins atbegshi.xml atveryend-test1.tex atveryend.ins atveryend.xml auxhook.ins auxhook.xml backref.dtx backref.sty biblatex.tex bigintcalc-test1.tex bigintcalc-test2.tex bigintcalc-test3.tex bigintcalc.ins bigintcalc.xml bit.tex bitset-test1.tex bitset-test2.tex bitset-test3.tex bitset.ins bitset.xml bk10.clo bk11.clo bk12.clo bm.dtx bm.ins bm.sty bmhydoc.sty book.cls calc.dtx calc.sty color.dtx color.sty dcolumn.dtx dcolumn.sty delarray.dtx delarray.sty drivers.dtx e.tex enumerate.dtx enumerate.sty epsfig.dtx epsfig.sty etexcmds-test1.tex etexcmds-test2.tex etexcmds-test3.tex etexcmds-test4.tex etexcmds.ins etexcmds.xml etextools-examples.tex etextools.ins example-mycolorsetup.sty fdl.tex fileerr.dtx fontsmpl.dtx fontsmpl.sty fontsmpl.tex ftnright.dtx ftnright.sty graphics-drivers.ins graphics.dtx graphicx.dtx graphicx.sty grfguide.tex h.tex hhline.dtx hhline.sty hopatch-test1.tex hopatch-test2.tex hopatch.ins hopatch.xml hycheck.tex hycolor-test-xcol1.tex hycolor-test-xcol2.tex hycolor-test-xcol3.tex hycolor-test-xcol4.tex hycolor-test1.tex hycolor-test2.tex hycolor-test3.tex hycolor.ins hycolor.xml hyperref.dtx hyperref.ins ifluatex-test1.tex ifluatex-test2.tex ifluatex-test3.tex ifluatex.ins ifluatex.xml ifpdf-test1.tex ifpdf.ins ifpdf.xml ifvtex-test1.tex ifvtex.ins ifvtex.xml ifxetex.ins ifxetex.tex indentfirst.dtx indentfirst.sty infwarerr-test1.tex infwarerr-test2.tex infwarerr-test3.tex infwarerr.ins infwarerr.xml intcalc-test1.tex intcalc-test2.tex intcalc-test3.tex intcalc-test4.tex intcalc.ins intcalc.xml keyval.dtx kvdefinekeys-test1.tex kvdefinekeys.ins kvdefinekeys.xml kvoptions-patch.sty kvoptions-test1.tex kvoptions-test2.tex kvoptions-test3.tex kvoptions-test4.sty kvoptions-test4.tex kvoptions.ins kvoptions.xml kvsetkeys-example.tex kvsetkeys-test1.tex kvsetkeys-test2.tex kvsetkeys-test3.tex kvsetkeys-test4.tex kvsetkeys.ins kvsetkeys.xml layout.dtx layout.sty letltxmacro-showcases.tex letltxmacro-test1.tex letltxmacro-test2.tex letltxmacro.ins letltxmacro.xml longtable.dtx longtable.ins longtable.sty lscape.dtx lscape.sty ltxcmds-test-carcdr.tex ltxcmds-test-gobble.tex ltxcmds-test-ifboxempty.tex ltxcmds-test-ifempty.tex ltxcmds-test-nextchar.tex ltxcmds-test-zapspace.tex ltxcmds-test1.tex ltxcmds.ins ltxcmds.xml manual.tex minitoc-hyper.sty multicol.dtx multicol.ins multicol.sty nameref.dtx nameref.sty nohyperref.sty ntheorem-hyper.sty oberdiek.pdftexcmds.lua options.tex pdfescape-test1.tex pdfescape-test2.tex pdfescape-test3.tex pdfescape-test4.tex pdfescape-test5.tex pdfescape-test6.tex pdfescape.ins pdfescape.xml pdftexcmds-test-escape.tex pdftexcmds-test-shell.tex pdftexcmds-test1.tex pdftexcmds-test2.tex pdftexcmds.bib pdftexcmds.ins pdftexcmds.lua pdftexcmds.xml q.tex r.tex rawfonts.dtx rawfonts.sty report.cls rerunfilecheck-test1.tex rerunfilecheck.ins rerunfilecheck.xml tabularx.dtx tabularx.ins tabularx.sty test-bm-pu-licr.tex test0.tex test1.tex test2.tex test3.tex test4.tex test6.tex test7.tex test8.tex testams.tex testbib.tex testbmgl.tex testbmu.tex testbookmark.tex testfor2.tex testform.tex testnb.tex testoz.tex testslide.tex testurl.tex textcomp.sty thb.sty thc.sty thcb.sty theorem.dtx theorem.sty thm.sty thmb.sty thp.sty tools-overview.tex tools.ins trace.dtx trace.sty trig.dtx trig.sty uniquecounter-example.tex uniquecounter-test1.tex uniquecounter-test2.tex uniquecounter-test3.tex uniquecounter.ins uniquecounter.xml varioref.dtx varioref.ins varioref.sty verbatim.dtx verbtest.tex x.tex xcolor-patch.sty xr-hyper.sty xr.dtx xr.sty xspace.dtx xspace.sty s.tex shellesc.dtx shellesc.sty showkeys.dtx showkeys.sty size10.clo size11.clo size12.clo somedefs.dtx somedefs.sty keyval.sty refcount-test1.tex refcount-test2.tex refcount-test3.tex refcount-test4.tex refcount-test5.tex refcount.ins refcount.xml refcount-test1.tex refcount-test2.tex refcount-test3.tex refcount-test4.tex refcount-test5.tex refcount.ins refcount.xml gettitlestring-test1.tex gettitlestring-test2.tex gettitlestring.ins gettitlestring.xml
EXTRA_CLEAN_FILES += biblatex_legacy.sty biblatex_.sty etextools.sty

FIND_ARGS = -name "*.sty" -o -name "*.tex" -o -name "*.map" -o -name "*.afm" -o -name "*.enc" -o -name "*.mf" -o -name "*.pfm" -o -name "*.pro" -o -name "*.tfm" -o -name "*.pfb" -o -name "*.fd" -o -name "*.def" -o -name "*.csf" -o -name "*.bst" -o -name "*.cfg" -o -name "*.cbx" -o -name "*.bbx" -o -name "*.lbx" -o -name "*.dtx" -o -name "*.ins" -o -name "*.600pk" -o -name "*.cmap" -o -name "*.drv"

$(BIBER_TAR_GZ):
	wget -N "https://mirrors.ctan.org/biblio/biber/binaries/Linux/$@"

biber: $(BIBER_TAR_GZ)
	tar -xzvf $< && touch $@

$(SIMPLE_ZIPS:.zip=.sty) : %.sty : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

$(SIMPLE_DTX_ZIPS:.zip=.dtx) : %.dtx : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

$(SIMPLE_CONTRIB_DTX_INS_ZIPS:.zip=.ins) $(REQUIRED_DTX_INS_ZIPS:.zip=.ins) : %.ins : %.zip
	unzip $< && (find $(<:.zip=) $(FIND_ARGS) | xargs touch && find $(<:.zip=) $(FIND_ARGS) | xargs mv -t ./)

etex.sty:
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/etex-pkg/$@"

tipa.zip:
	$(WGET) -N "https://mirrors.ctan.org/fonts/$(@:.zip=)/$@"

$(IFTEX_STY):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/iftex/$@"

stmaryrd.zip:
	$(WGET) -N "https://mirrors.ctan.org/fonts/$@"

$(CONTRIB_ZIPS):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$@"

$(REQUIRED_ZIPS):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/required/$@"

utf8x.def ucsencs.def:
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/ucs/$@"

$(GENERIC_STY):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$(@:.sty=)/$@"

$(GENERIC_TEX):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$(@:.tex=)/$@"

$(UNIS) $(UNIS-LARGE):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/ucs/data/$@"

ifmtarg.sty: ifmtarg.tex

$(SIMPLE_TEX):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.tex=)/$@"

$(GENERIC_TEX_INS_STY:.sty=.ins):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$(@:.ins=)/$@"

$(BASE_DTX_INS_DOWNLOAD:.dtx=.ins) $(BASE_DTX_INS_DOWNLOAD):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/base/$@"

$(INS_STY:.sty=.ins) $(DTX_INS_STY:.sty=.ins):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.ins=)/$@"

$(BUILD_INS_STY) : %.sty : %.ins
	latex $<

article.cls: classes.ins classes.dtx
	latex classes.ins

$(ALL_DTX_INS_STY) : %.sty : %.dtx
$(ALL_TEX_INS_STY) : %.sty : %.tex

$(DTX_STY:.sty=.dtx) $(DTX_INS_STY:.sty=.dtx):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.dtx=)/$@"

$(GENERIC_TEX_INS_STY:.sty=.tex):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$(@:.tex=)/$@"

$(GENERIC_DTX_STY:.sty=.dtx):
	$(WGET) -N "https://mirrors.ctan.org/macros/generic/$(@:.dtx=)/$@"

$(ALL_DTX_STY) $(OBERDIEK_DTX_STY) : %.sty : %.dtx
	tex $<

$(ALL_DTX_LATEX_STY) : %.sty : %.dtx
	latex $<

$(SIMPLE_DEPENDENCIES):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.sty=)/$@"

$(SIMPLE_DEFS):
	$(WGET) -N "https://mirrors.ctan.org/macros/latex/contrib/$(@:.def=)/$@"

graphics.sty: graphics.ins
	latex graphics-drivers.ins
	latex graphics.ins

verbatim.sty: tools.ins
	latex tools.ins

fontenc.sty: ltoutenc.ins ltoutenc.dtx
	latex $<

dependencies:: $(DEPENDENCIES)

clean-all:: clean
	$(VECHO) "RM *.PFM *.MF *.TFM *.PFB *.MAP *.DEF *.FD *.PRO *.LOX *.CSF *.BST *.CFG *.CBX *.BBX *.LBX *.600PK *.CMAP *.DRV"
	$(Q)rm -f *.pfm *.mf *.tfm *.pfb *.map *.def *.fd *.pro *.lox *.csf *.bst *.cfg *.cbx *.bbx *.lbx *.600pk *.cmap *.drv
	rm -rf $(DEPENDENCIES) $(PRE_DEPENDENCIES)
	$(VECHO) "RM EXTRA_CLEAN_FILES"
	$(Q)rm -rf $(EXTRA_CLEAN_FILES)
	@FILES="$$(git status | grep '^#\s' | sed s'/^#\s*//g' | grep '\.[a-z]\+$$' | tr '\n' ' ')"; \
	if [ ! -z "$$FILES" ]; then \
	echo "You might also want to remove the following files:"; \
	echo "$$FILES" | grep --color=auto '.'; \
	fi
