WATCH_FILE = .watch-pid
MANAGE_SCRIPT = ./bin/manage.py
SITE_DIR = ./_site
STATIC_DIR = ./src/static
COFFEE_DIR = ${STATIC_DIR}/scripts/coffeescript
JAVASCRIPT_DIR = ${STATIC_DIR}/scripts/javascript
JAVASCRIPT_SRC_DIR = ${JAVASCRIPT_DIR}/src
JAVASCRIPT_MIN_DIR = ${JAVASCRIPT_DIR}/min

SASS_DIR = ${STATIC_DIR}/stylesheets/scss
CSS_DIR = ${STATIC_DIR}/stylesheets/css

COMPILE_SASS = `which sass` \
	--scss \
	--style=compressed \
	-r ${SASS_DIR}/bourbon/lib/bourbon.rb \
	${SASS_DIR}:${CSS_DIR}

COMPILE_COFFEE = `which coffee` -b -o ${JAVASCRIPT_SRC_DIR} -c ${COFFEE_DIR}
WATCH_COFFEE = `which coffee` -w -b -o ${JAVASCRIPT_SRC_DIR} -c ${COFFEE_DIR}

REQUIRE_OPTIMIZE = `which node` ./bin/r.js -o ${JAVASCRIPT_DIR}/app.build.js

all: collect

setup: init-submodules build-deps

build: build-deps sass coffee optimize

dist: build
	@echo 'Creating a source distributions...'
	@python setup.py sdist > /dev/null

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
	@${WATCH_COFFEE} &> /dev/null & echo $$! > ${WATCH_FILE}
	@${COMPILE_SASS} --watch &> /dev/null & echo $$! >> ${WATCH_FILE}

unwatch:
	@if [ -f ${WATCH_FILE} ]; then \
		echo 'Watchers stopped'; \
		for pid in `cat ${WATCH_FILE}`; do kill -9 $$pid; done; \
		rm ${WATCH_FILE}; \
	fi;

init-submodules:
	@echo 'Initializing submodules...'
	@if [ -d .git ]; then \
		git submodule update --init --recursive; \
	fi;

# note: html5-boilerplate is not included here since it may overwrite
# custom settings
build-deps: clean-deps r.js jquery backbone underscore \
	requirejs backbone-common sass-twitter-bootstrap

# Removes all code copied from submodule repos
clean-deps:
	@rm -rf bin/r.js \
		src/static/stylesheets/scss/bootstrap \
		src/static/scripts/coffeescript/common \
		src/static/scripts/coffeescript/common.coffee \
		src/static/scripts/javascript/src/{order,require,jquery,underscore,backbone}.js

# Backward compatible aliases
build-submodules: build-deps
clean-submodules: clean-deps

# WARNING: this should be run only once since this could overwrite existing
# customized files
html5-boilerplate:
	@echo 'Setting up HTML5 boilerplate...'
	@cp -r ./modules/html5-boilerplate/*.{png,xml,ico,txt} \
		./modules/html5-boilerplate/.htaccess ${SITE_DIR}

r.js:
	@echo 'Setting up r.js...'
	@cd ./modules/r.js && node dist.js
	@mkdir -p ./bin
	@cp ./modules/r.js/r.js ./bin

sass-twitter-bootstrap:
	@echo 'Setting up Sass Twitter Bootstrap...'
	@rm -rf ${SASS_DIR}/bootstrap
	@cp -r ./modules/sass-twitter-bootstrap/lib ${SASS_DIR}/bootstrap

backbone-common:
	@echo 'Setting up Backbone-common...'
	@rm -rf ${COFFEE_DIR}/common ${COFFEE_DIR}/common.coffee
	@cp -r ./modules/backbone-common/src/* ${COFFEE_DIR}

requirejs:
	@echo 'Setting up RequireJS...'
	@cp ./modules/requirejs/require.js ${JAVASCRIPT_SRC_DIR}/require.js
	@cp ./modules/requirejs/order.js ${JAVASCRIPT_SRC_DIR}/order.js

jquery:
	@echo 'Setting up jQuery...'
	@cd ./modules/jquery && make update_submodules jquery
	@cp ./modules/jquery/dist/jquery.js ${JAVASCRIPT_SRC_DIR}/jquery.js

backbone:
	@echo 'Setting up Backbone...'
	@cp ./modules/backbone/backbone.js ${JAVASCRIPT_SRC_DIR}/backbone.js

underscore:
	@echo 'Setting up Underscore...'
	@cp ./modules/underscore/underscore.js ${JAVASCRIPT_SRC_DIR}/underscore.js

optimize: r.js
	@echo 'Optimizing JavaScript...'
	@rm -rf ${JAVASCRIPT_MIN_DIR}
	@mkdir -p ${JAVASCRIPT_MIN_DIR}
	@${REQUIRE_OPTIMIZE} > /dev/null

secret-key:
	@echo Generating unique secret key...
	@echo Copy and paste the below setting into your local_settings.py file:
	@echo
	@echo 'SECRET_KEY = \c'; python ./bin/secret_key.py

.PHONY: all sass coffee watch unwatch build dist optimize
