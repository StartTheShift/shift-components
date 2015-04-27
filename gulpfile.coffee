gulp = require 'gulp'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
del = require 'del'
coffee = require 'gulp-coffee'
runSequence = require 'run-sequence'
concat = require 'gulp-concat'
sourceMap = require 'gulp-sourcemaps'

BUILD_DEST = './build/'

gulp.task 'build', ['coffee'], ->
  gulp.src('./src-js/**/*.js')
  	.pipe concat('shift-components.js')
  	.pipe gulp.dest(BUILD_DEST)
  	.pipe sourceMap.init()
  	.pipe uglify()
  	.pipe rename(extname: '.min.js')
  	.pipe sourceMap.write('./')
  	.pipe gulp.dest(BUILD_DEST)

gulp.task 'coffee', ['clean'], ->
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('./src-js/'));

gulp.task 'clean', (done) ->
  del ['./build', './src-js'], done

gulp.task 'watch', ['default'], ->
	gulp.watch ['src/**/*.coffee'], ['default']


gulp.task 'default', (cb) ->
  runSequence 'clean', ['coffee', 'watch'], cb