// RequireJS optimization configuration
// Full example: https://github.com/jrburke/r.js/blob/master/build/example.build.js

({
    // optiize relative to this url (i.e. the current directory)
    baseUrl: '.',
    
    // the source directory of the modules
    appDir: 'src',

    // the target directory of the optimized modules
    dir: 'min',

    optimize: 'uglify',

    optimizeCss: 'none',

    // a reference here for any scripts that need to include cilantro
    // modules
    paths: {
        'cilantro/main': 'empty:'
    },
    
    // if the project requires any custom javascript modules, they can be
    // listed here. below shows an example for a 'main' module. if this is
    // defined and depends on the 'cilantro/main' module, ensure this is
    // excluded during the optimization step.
    
    // modules: [{
    //     name: 'main',
    //     exclude: ['cilantro/main']
    // }]
})
