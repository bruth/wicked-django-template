module.exports = (grunt) ->

    require('time-grunt')(grunt)
    require('load-grunt-tasks')(grunt)

    shell = require('shelljs')

    run = (cmd) ->
        grunt.log.ok cmd
        shell.exec cmd

    grunt.initConfig
        static_path: '{{ project_name }}/static/'
        app: '{{ project_name }}'
        
        watch:
            coffee:
                files: ['<%= static_path %>/scripts/coffeescript/{,*/}*.coffee']
                tasks: ['coffee:dist']
            
            compass:
                files: ['<%= static_path %>/stylesheets/scss/{,*/}*.{scss,sass}']
                tasks: ['compass:dist']

        copy:
            localSettings:
                expand: true
                src: 'local_settings.py.sample'
                dest: '<%= app %>/conf'
                cwd: '<%= app %>/conf'
                ext: '.py'

        compass:
            dist:
                options:
                    sassDir: '<%= static_path %>/stylesheets/scss'
                    cssDir: '.tmp/stylesheets'
                    importPath: '<%= static_path %>/stylesheets'
                    relativeAssets: false

        cssmin:
            dist:
                files:
                    '<%= static_path %>/stylesheets/css/style.css':[
                        '.tmp/stylesheets/{,*/}*.css'
                    ]
        
        requirejs:
            dist:
                options:
                    baseUrl: './'
                    appDir: '<%= static_path %>/scripts/javascript/src'
                    dir: '<%= static_path %>/scripts/javascript/min'
                    optimize: 'uglify'
                    optimizeCss: 'none'
                    paths: {}
                    shim:
                        underscore:
                            exports: '_'
                        backbone: 
                            deps: ['underscore', 'jquery']
                            exports: 'Backbone'
                        bootstrap: ['jquery']
                    modules: [
                        name: 'main',
                        exclude: ['environ', 'jquery', 'underscore', 'backbone']
                    ,
                        name: 'environ',
                        include: ['jquery', 'underscore', 'backbone', 'core/mixins', 'bootstrap']
                    ]
        coffee:
            dist:
                options:
                    bare: true
                files: [
                    expand: true,
                    cwd: '<%= static_path %>/scripts/coffeescript'
                    src: '{,*/}*.coffee'
                    dest: '<%= static_path %>/scripts/javascript/src'
                    ext: '.js'
                ]
    
    grunt.registerTask 'setup', 'Copies the sample local_settings file into place',[
        'copy'
    ]

    grunt.registerTask 'collect-static', 'Symlink static files using Django utility', ->
        run "./bin/manage.py collectstatic --link --noinput > /dev/null"
    
    grunt.registerTask 'build', '', [
        'setup'
        'coffee'
        'compass'
        'cssmin'
        'requirejs'
        'copy'
    ]

    grunt.registerTask 'default', [
        'build'
        'collect-static'
    ]