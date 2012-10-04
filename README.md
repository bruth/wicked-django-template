# Bada$$ Django Template

## Install

The preferred environment for the template is creating a virtual environment:

```bash
$ virtualenv myproject-env
$ cd myproject-env
$ source bin/activate
$ pip install django
```

Now run the `startproject` command:

```bash
$ django-admin.py startproject --template https://github.com/bruth/badass-django-template/zipball/master -e py,ini,gitignore,in,conf,md,sample -n Makefile myproject .
```

Since Github puts the contents in a sub-directory, explicity set the target
directory, e.g. `.`. You can then rename the output directory to whatever
you want (the example directory name below most likely won't be the same
as yours).

```bash
$ mv bruth-badass-django-template-705b8f2 myproject
$ cd myproject
```

Ensure Ruby and the Sass gem are installed:

```bash
$ gem install sass
```

Ensure Node, NPM and CoffeeScript are installed:

```bash
$ npm install coffee-script -g
```

Execute the following commands to begin watching the static files and
collect the files (using Django's collectstatic command):

```bash
$ make sass coffee watch collect
```

_Note, the `sass` and `coffee` targets are called first to ensure the compiled
files exist before attempting to collect them. Just running `watch` spawns
background processes and may result in a race condition with the `collect`
command._

Then either start the built-in Django server:

```bash
$ ./bin/manage.py runserver
```

or run a `uwsgi` process:

```bash
$ uwsgi --ini server/uwsgi/local.ini --protocol http --socket 127.0.0.1:8000 --check-static _site
```

## Features

- clean project structure
    - ``_site`` directory for web server document root
        - copied static files and user uploaded media files
        - works well with nginx's ``try_files`` directive
        - ``maintenance`` directory for toggling maintenance mode's
- server configurations for nginx, uWSGI, and Supervisor
    - note: the paths will need to be updated to match your environment
- tiered settings for easier cross-environment support
    - ``global_settings.py`` for environment-independent settings
    - ``local_settings.py`` for environment-specific settings (not versioned)
    - ``settings.py`` for bringing them together and post-setup
- ``local_settings.py.sample`` template
- a clean static directory for large Web app development
- wicked hot Makefile for watching static files pre-processors:
    - ``make watch``
    - CoffeeScript (requires Node and CoffeeScript)
    - SCSS (requires Ruby and Sass)
    - compiles scss => css
    - compiles coffee => javascript/src
- integration with [r.js](https://github.com/jrburke/r.js/)
    - ``make optimize``
    - includes ``app.build.js`` file for single-file JavaScript optimization
    - compiles javascript/src => javascript/min
- context processor for including more direct static urls
    - ``{{ CSS_URL }}``
    - ``{{ JAVASCRIPT_URL }}``
    - ``{{ IMAGES_URL }}``
- simple, but useful fabfile.py for common commands

## Dependencies

- Python 2.7 (because that's how I roll)
- Ruby
- Node
- Ruby Sass gem
- Node CoffeeScript module

## Makefile Commands

- ``build`` - builds and initializes all submodules, compiles SCSS and
    CoffeeScript and optimizes JavaScript
- ``watch`` - watches the CoffeeScript and SCSS files in the background
for changes and automatically recompiles the files
- ``unwatch`` - stops watching the CoffeeScript and SCSS files
- ``sass`` - one-time explicit recompilation of SCSS files
- ``coffee`` - one-time explicit recompilation of CoffeeScript files

## Fabfile Commands

- ``mm_on`` - turns on maintenance mode
- ``mm_off`` - turns off maintenance mode
- ``deploy`` - deploy a specific Git tag on the host


## Local Settings

``local_settings.py`` is intentionally not versioned (via .gitignore). It should
contain any environment-specific settings and/or sensitive settings such as
passwords, the ``SECRET_KEY`` and other information that should not be in version
control. Defining ``local_settings.py`` is not mandatory but will warn if it does
not exist.

## CoffeeScript/JavaScript Development

CoffeeScript is lovely. The flow is simple:

- write some CoffeeScript which automatically gets compiled in JavaScript
(assuming you did ``make watch``)
- when ready to test non-``DEBUG`` mode, run ``make optimize``

The ``app.build.js`` file will need to be updated to define which modules
should be compiled to single files. It is recommended to take a tiered
approach to reduce overall file size across pages and increase cache potential
for libraries that won't change for a while, for example jQuery.

## SCSS Development

[Sass](http://sass-lang.com/) is awesome. SCSS is a superset of CSS so you can
use as much or as little SCSS syntax as you want. It is recommended to write
all of your CSS rules as SCSS, since at the very least the Sass minifier can
be taken advantage of.
