gulp = require 'gulp'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
del = require 'del'
coffee = require 'gulp-coffee'
runSequence = require 'run-sequence'
concat = require 'gulp-concat'
sourceMap = require 'gulp-sourcemaps'
jsdoc2md = require 'gulp-jsdoc-to-markdown'

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
  del ['./build', 'src/**/*.md', './src-js'], done

# Monitor changes on coffee files, trigger default on
# change
gulp.task 'watch', ['default'], ->
	gulp.watch ['src/**/*.coffee'], ['default']

# Translate coffee file into JS and generate MarkDown doc
gulp.task 'default', (cb) ->
  runSequence 'clean', ['coffee', 'docs'], cb