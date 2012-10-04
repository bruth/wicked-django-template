// RequireJS optimization configuration
// Full example: https://github.com/jrburke/r.js/blob/master/build/example.build.js

({
    // Optimize relative to this url (i.e. the current directory)
    baseUrl: '.',
    
    // The source directory of the modules
    appDir: 'src',

    // The target directory of the optimized modules
    dir: 'min',

    optimize: 'uglify',

    optimizeCss: 'none',

    paths: {},

    shim: {
        underscore: {
            exports: '_'
        },
        backbone: {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        bootstrap: ['jquery']
    },
    
    modules: [{
        name: 'main',
        exclude: ['environ', 'jquery', 'underscore', 'backbone']
    }, {
        name: 'environ',
        include: ['jquery', 'underscore', 'backbone', 'core/mixins', 'bootstrap'] 
    }]
})
