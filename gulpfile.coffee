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
merge = require 'merge-stream'
stylus = require 'gulp-stylus'
fs = require 'fs'
path = require 'path'
inject = require 'gulp-inject'

BUILD_DEST = 'build'
EXAMPLES_DEST = 'examples'

COMPILED_SRC = '.src-js'
COMPILED_EXAMPLES = '.examples'

# Create docs next to coffee files
gulp.task 'docs', ['coffee'], ->
  gulp.src "#{COMPILED_SRC}/**/*.js"
    .pipe jsdoc2md({'private': true})
    .on 'error', (err) ->
      console.log "jsdoc2md failed: #{err.message}"
    .pipe rename (path) ->
      path.basename = "readme"
      path.extname = '.md'
    .pipe gulp.dest('src')

# Generate single lib file, minified with sourcemap
gulp.task 'build', ['coffee'], ->
  gulp.src "#{COMPILED_SRC}/**/*.js"
    .pipe concat('shift-components.js')
    .pipe gulp.dest(BUILD_DEST)
    .pipe sourceMap.init()
    .pipe uglify()
    .pipe rename(extname: '.min.js')
    .pipe sourceMap.write('./')
    .pipe gulp.dest(BUILD_DEST)

# Translate Coffee into JS
gulp.task 'coffee', ['clean'], ->
  gulp.src(['./src/*/*.coffee', './src/components.coffee'])
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('.src-js'));

gulp.task 'clean', (done) ->
  del ['src/**/*.md', COMPILED_SRC, BUILD_DEST], done

gulp.task 'cleanExamples', (done) ->
  del [EXAMPLES_DEST], done

# Monitor changes on coffee files, trigger default on
# change
gulp.task 'watch', ['build', 'docs', 'examples'], ->
  gulp.watch ['src/**/*.coffee'], ['coffee', 'docs', 'examples']
  gulp.watch [
    'src/*/example/*.jade'
    'src/*/example/*.styl'
    'src/*/example/*.coffee'
  ], ['examples']

# Translate coffee file into JS and generate MarkDown doc
gulp.task 'default', (cb) ->
  runSequence 'clean', ['watch', 'connect'], cb

# Web serving of examples
gulp.task 'connect', ->
  connect.server {
    root: EXAMPLES_DEST,
    livereload: true
  }

gulp.task 'examples', ['cleanExamples', 'build', 'compileExamples'], ->
  getFolders = (dir) ->
    fs.readdirSync(dir)
      .filter (file) ->
        fs.statSync(path.join(dir, file)).isDirectory()

  third_party_css = gulp.src([
      'bower_components/skeletor/dist/skeletor.css'
      'bower_components/normalize.css/normalize.css'
      'bower_components/prism/themes/prism.css'
    ])
    .pipe rename (path) ->
      path.dirname = '/'
    .pipe gulp.dest("#{EXAMPLES_DEST}/css")

  third_party_js = gulp.src([
      "#{BUILD_DEST}/shift-components.js"
      'bower_components/angular/angular.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/lodash/lodash.js'
      'bower_components/prism/prism.js'
      'bower_components/prism/components/prism-coffeescript.js'
      'bower_components/prism/components/prism-jade.js'
      'bower_components/prism/components/prism-stylus.js'
    ])
    .pipe rename (path) ->
      path.dirname = '/'
    .pipe gulp.dest("#{EXAMPLES_DEST}/js")

  tasks = getFolders(COMPILED_EXAMPLES).map (folder) ->
    example_folder = path.join COMPILED_EXAMPLES, folder

    return gulp.src "#{COMPILED_EXAMPLES}/template.html"
      # rename the output file to be "[feature].html"
      .pipe rename "#{folder}.html"

      # inject the CSS
      .pipe inject gulp.src("#{example_folder}/example/*.css"),
        starttag: '<!-- inject:css -->'
        transform: (filePath, file) ->
          content = file.contents.toString('utf8')
          return "<style>#{content}</style>"

      # inject the HTML
      .pipe inject gulp.src("#{example_folder}/example/*.html"),
        starttag: '<!-- inject:html -->'
        transform: (filePath, file) ->
          return file.contents.toString('utf8')

      # inject the CoffeeScript
      .pipe inject gulp.src("#{example_folder}/example/*.coffee"),
        starttag: '<!-- inject:coffee -->'
        transform: (filePath, file) ->
          return file.contents.toString('utf8')

      # inject the Jade
      .pipe inject gulp.src("#{example_folder}/example/*.jade"),
        starttag: '<!-- inject:jade -->'
        transform: (filePath, file) ->
          return file.contents.toString('utf8')

      # inject the Stylus
      .pipe inject gulp.src("#{example_folder}/example/*.styl"),
        starttag: '<!-- inject:stylus -->'
        transform: (filePath, file) ->
          return file.contents.toString('utf8')

      # inject the JavaScript
      .pipe inject gulp.src("#{example_folder}/example/*.js"),
        starttag: '<!-- inject:js -->'
        transform: (filePath, file) ->
          content = file.contents.toString('utf8')
          return "<script>#{content}</script>"

      .pipe gulp.dest EXAMPLES_DEST

  return merge tasks, third_party_js, third_party_css
    .pipe connect.reload()

# Compiles example files from pseudo code to web standart
gulp.task 'compileExamples', ->
  html_template = gulp.src('src/template.jade')
    .pipe jade()
    .pipe gulp.dest(COMPILED_EXAMPLES)

  html = gulp.src('src/*/example/*.jade')
    .pipe gulp.dest(COMPILED_EXAMPLES)
    .pipe jade()
    .pipe gulp.dest(COMPILED_EXAMPLES)

  js = gulp.src('src/*/example/*.coffee')
    .pipe gulp.dest(COMPILED_EXAMPLES)
    .pipe coffee()
    .pipe gulp.dest(COMPILED_EXAMPLES)

  css = gulp.src('src/*/example/*.styl')
    .pipe gulp.dest(COMPILED_EXAMPLES)
    .pipe stylus()
    .pipe gulp.dest(COMPILED_EXAMPLES)

  merge html, js, css, html_template
