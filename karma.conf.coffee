module.exports = (config) ->
  config.set
    autoWatchBatchDelay: 1000
    basePath: ''

    browsers: ['PhantomJS']

    frameworks: ['mocha', 'chai', 'sinon']

    # gulp-karma ignores this files list since we provide file paths to gulp.src
    # files: []

    reporters: ['mocha']

    preprocessors:
      'src/**/*.{mock,spec}.coffee': ['coffee']

    singleRun: true
