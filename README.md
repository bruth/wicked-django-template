Bada$$ Django Template
======================

- clean project structure
    - separate ``src`` directory for Django code
    - ``_site`` directory for web server document root
        - copied static files and user uploaded media files
        - works well with nginx's ``try_files`` directive
        - ``maintenance`` directory for toggling maintenance mode's
- tested server configurations for nginx, uWSGI, and Supervisor
- tiered settings for easier cross-environment support
    - ``global_settings.py`` for environment-independent settings
    - ``local_settings.py`` for environment-specific settings (not versioned)
    - ``settings.py`` for bringing them together and post-setup
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
- context processor for including JavaScript and CSS static urls
    - ``{{ CSS_URL }}``
    - ``{{ JAVASCRIPT_URL }}``
- ...HTML5 boilerplate hotness

Dependencies
------------
- Python 2.7 (because that's how we roll)

Fabfile Commands
----------------
``mm_on`` - turns on maintenance mode
``mm_off`` - turns off maintenance mode

