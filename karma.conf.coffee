module.exports = (config) ->
  config.set
    browsers: ['PhantomJS']
    frameworks: ['mocha', 'chai', 'sinon']
    reporters: ['mocha']

    # gulp-karma ignores this files list since we provide file paths to gulp.src
    # files: []

    preprocessors:
      'src/**/*.{mock,spec}.coffee': ['coffee']
