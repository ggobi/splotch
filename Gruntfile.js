module.exports = function(grunt) {
    grunt.initConfig({
        bower: {
            rjsConfig: 'config/rjs.js'
        },
        requirejs: {
            compile: {
                options: {
                    mainConfigFile: 'config/rjs.js',
                    include: ['almond', 'cs!splotch'],
                    exclude: ['coffee-script'],
                    stubModules: ['cs'],
                    out: 'dist/splotch.js',
                    wrap: {
                        startFile: 'config/wrap.start',
                        endFile: 'config/wrap.end'
                    }
                }
            }
        }
    });

    // Load external tasks
    grunt.loadNpmTasks('grunt-bower-hooks');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    
    // Make task shortcuts
    grunt.registerTask('default', ['bower', 'requirejs']);
};
