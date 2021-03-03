# Global variables {{{1
# ================
# Where make should look for things
VPATH = lib
vpath %.csl _csl
vpath %.yaml .:_spec
vpath default.% lib/templates
vpath reference.% lib/templates

# Branch-specific targets and recipes {{{1
# ===================================

PAGES_SRC     = $(wildcard *.md)
PAGES_OUT    := $(patsubst %,docs/%, $(PAGES_SRC))
ENANPARQ_SRC  = $(wildcard 6enanparq-*.md)
ENANPARQ_TMP := $(patsubst %.md,%.tmp, $(ENANPARQ_SRC))

build : _config.yaml | _csl
	@bundle install && bundle exec jekyll build

docs/%.md : %.md jekyll.yaml _data/biblio.yaml
	pandoc -o $@ -d _spec/jekyll.yaml $<
	rm docs/README.md

_site/slides/%.html : %.md revealjs.yaml | _csl _site/slides
	pandoc -o $@ -d _spec/revealjs.yaml $<

.INTERMEDIATE : $(ENANPARQ_TMP) _book/6enanparq.odt

_book/6enanparq.docx : _book/6enanparq.odt
	libreoffice --invisible --convert-to docx --outdir _book $<

_book/6enanparq.odt : $(ENANPARQ_TMP) 6enanparq-sl.yaml \
	6enanparq-metadata.yaml default.opendocument reference.odt | _csl
	pandoc -o $@ -d _spec/6enanparq-sl.yaml \
		6enanparq-toc.md 6enanparq-intro.md \
		6enanparq-palazzo.tmp 6enanparq-florentino.tmp \
		6enanparq-duany.tmp 6enanparq-gil_cornet.tmp \
		6enanparq-craveiro.tmp 6enanparq-metadata.yaml

%.tmp : %.md concat.yaml _data/biblio.yaml
	pandoc -o $@ -d _spec/concat.yaml $<

# Install and cleanup {{{1
# ===================

_csl :
	@git clone --depth=1 \
		https://github.com/citation-style-language/styles.git _csl

_site/slides :
	@mkdir -p $@

serve :
	@bundle exec jekyll serve

# `make clean` will clear out a few standard folders where only compiled
# files should be. Anything you might have placed manually in them will
# also be deleted!
clean :
	-rm -rf _site *.tmp

# vim: set foldmethod=marker tw=72 :
