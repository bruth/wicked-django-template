WATCH_FILE = .watch-pid
MANAGE_SCRIPT = ./bin/manage.py
SITE_DIR = ./_site
STATIC_DIR = ./{{ project_name }}/static
COFFEE_DIR = ${STATIC_DIR}/scripts/coffeescript
JAVASCRIPT_DIR = ${STATIC_DIR}/scripts/javascript
JAVASCRIPT_SRC_DIR = ${JAVASCRIPT_DIR}/src
JAVASCRIPT_MIN_DIR = ${JAVASCRIPT_DIR}/min

SASS_DIR = ${STATIC_DIR}/stylesheets/scss
CSS_DIR = ${STATIC_DIR}/stylesheets/css

COMPILE_SASS = `which sass` \
	--scss \
	--style=compressed \
	-r ${SASS_DIR}/lib/bourbon/lib/bourbon.rb \
	${SASS_DIR}:${CSS_DIR}

COMPILE_COFFEE = `which coffee` -b -o ${JAVASCRIPT_SRC_DIR} -c ${COFFEE_DIR}
WATCH_COFFEE = `which coffee` -w -b -o ${JAVASCRIPT_SRC_DIR} -c ${COFFEE_DIR}

REQUIRE_OPTIMIZE = `which node` ./bin/r.js -o ${JAVASCRIPT_DIR}/app.build.js

all: build collect

setup:
	@if [ ! -f ./{{ project_name }}/conf/local_settings.py ] && [ -f ./{{ project_name }}/conf/local_settings.py.sample ]; then \
	    echo 'Creating local_settings.py...'; \
	    cp ./{{ project_name }}/conf/local_settings.py.sample ./{{ project_name }}/conf/local_settings.py; \
	fi;

build: sass coffee optimize

collect:
	@echo 'Symlinking static files...'
	@${MANAGE_SCRIPT} collectstatic --link --noinput > /dev/null

sass:
	@echo 'Compiling Sass/SCSS...'
	@mkdir -p ${CSS_DIR}
	@${COMPILE_SASS} --update

coffee:
	@echo 'Compiling CoffeeScript...'
	@${COMPILE_COFFEE}

watch: unwatch
	@echo 'Watching in the background...'
	@${WATCH_COFFEE} > /dev/null 2>&1 & echo $$! > ${WATCH_FILE}
	@${COMPILE_SASS} --watch > /dev/null 2>&1 & echo $$! >> ${WATCH_FILE}

unwatch:
	@if [ -f ${WATCH_FILE} ]; then \
		echo 'Watchers stopped'; \
		for pid in `cat ${WATCH_FILE}`; do kill -9 $$pid; done; \
		rm ${WATCH_FILE}; \
	fi;

optimize: clean
	@echo 'Optimizing JavaScript...'
	@mkdir -p ${JAVASCRIPT_MIN_DIR}
	@${REQUIRE_OPTIMIZE} > /dev/null

clean:
	@rm -rf ${JAVASCRIPT_MIN_DIR}


.PHONY: all build sass coffee watch unwatch optimize
