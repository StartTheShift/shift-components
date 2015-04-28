gulp = require 'gulp'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
del = require 'del'
coffee = require 'gulp-coffee'
runSequence = require 'run-sequence'
concat = require 'gulp-concat'
sourceMap = require 'gulp-sourcemaps'
jsdoc2md = require 'gulp-jsdoc-to-markdown'
connect = require 'gulp-connect'
jade = require 'gulp-jade'

BUILD_DEST = 'build'

# Create docs next to coffee files
gulp.task 'docs', ['coffee'], ->
	gulp.src 'src-js/**/*.js'
		.pipe jsdoc2md({'private': true})
		.on 'error', (err) ->
			console.log "jsdoc2md failed: #{err.message}"
		.pipe rename (path) ->
			path.basename = "readme"
			path.extname = '.md'
		.pipe gulp.dest('src')

# Generate single lib file, minified with sourcemap
gulp.task 'build', ['coffee'], ->
  gulp.src './src-js/**/*.js'
  	.pipe concat('shift-components.js')
  	.pipe gulp.dest(BUILD_DEST)
  	.pipe sourceMap.init()
  	.pipe uglify()
  	.pipe rename(extname: '.min.js')
  	.pipe sourceMap.write('./')
  	.pipe gulp.dest(BUILD_DEST)

# Translate Coffee into JS
gulp.task 'coffee', ->
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('src-js'));

gulp.task 'clean', (done) ->
  del ['src/**/*.md', 'src-js', 'examples'], done

# Monitor changes on coffee files, trigger default on
# change
gulp.task 'watch', ['coffee', 'docs', 'examples'], ->
	gulp.watch ['src/**/*.coffee'], ['coffee', 'docs']
	gulp.watch ['src/**/*.jade'], ['examples']

# Translate coffee file into JS and generate MarkDown doc
gulp.task 'default', (cb) ->
  runSequence 'clean', ['watch', 'connect'], cb

# Web serving of examples
gulp.task 'connect', ->
  connect.server {
    root: 'examples',
    livereload: true
  }

gulp.task 'examples', ['build'], ->
  gulp.src([
      'bower_components/skeletor/dist/skeletor.css'
      'bower_components/normalize.css/normalize.css'
    ])
    .pipe rename (path) ->
      path.dirname = '/'
    .pipe gulp.dest('examples/css')

  gulp.src([
      'build/shift-components.js'
      'node_modules/angular/angular.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/lodash/lodash.js'
    ])
    .pipe rename (path) ->
      path.dirname = '/'
    .pipe gulp.dest('examples/js')

  gulp.src('src/**/*.jade')
  	.pipe jade()
    .pipe rename (path) ->
      path.dirname = '/'
  	.pipe gulp.dest('examples')
    .pipe connect.reload()


