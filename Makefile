CSS 		:= theme/app.scss

IMAGES 	:= $(wildcard theme/img/*)

SCRIPTS := theme/js/lib/jquery.js \
					 $(wildcard theme/js/*.js) \
					 $(wildcard theme/js/lib/*.js) \
					 $(wildcard theme/js/lib/ace/*.js)

SCRIPTS_OUT	:= static/lib/app.min.js

IMAGES_OUT 	:= $(patsubst theme/img/%,static/img/%,$(IMAGES))

CSS_OUT			:= $(patsubst theme/%.scss,static/lib/%.css,$(CSS))

.PHONY: test all static syncdb

all: static syncdb

static: scss images scripts

syncdb:
	./manage.py db syncdb

test:
	nosetests --with-coverage

docker_test:
	pip install nose
	nosetests --with-coverage

lint:
	pylint -f html *.py | tee linter.html

submodules:
	git submodule update --init

clean:
	rm -f $(CSS_OUT) $(IMAGES_OUT) $(SCRIPTS_OUT)

scss: $(CSS_OUT)

images: static/img $(IMAGES_OUT)

static/img static/lib:
	mkdir -p $@

scripts: $(SCRIPTS_OUT)

static/img/%.png: theme/img/%.png
	pngcrush $< $@

static/img/%.gif: theme/img/%.gif
	gifsicle < $< > $@

static/img/%.svg: theme/img/%.svg
	cp $< $@

$(SCRIPTS_OUT): $(SCRIPTS)
	uglifyjs $^ -o $@

static/lib/%.css: theme/%.scss static/lib theme/lib/foundation
	sass --scss -I theme/lib/foundation/scss/ $< $@

theme/lib/foundation: submodules
