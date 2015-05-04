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
ngtemplate = require 'gulp-ngtemplate'
htmlmin = require 'gulp-htmlmin'
protractor = require('gulp-protractor').protractor

BUILD_DEST = 'build'
EXAMPLES_DEST = 'examples'

COMPILED_SRC = '.src-js'
COMPILED_EXAMPLES = '.examples'


###
Jade, Coffee and Stylus compilers:

- compile_template: to compile jade into string and leverage Angular template cache
- compile_coffee: to compile all the components coffeeScript to JavaScript
- compile_example: to compile examples into executable demo web-pages
###

gulp.task 'compile_example', ['clean'], ->
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

gulp.task 'compile_template', ['compile_coffee', 'clean'], ->
  merge gulp.src('src/*/*.jade')
    .pipe jade()
    .pipe htmlmin({collapseWhitespace: true})
    .pipe ngtemplate(
      standalone: false
      module: (name) ->
        'shift.components.' + name.split('/')[0]
    )
    .pipe rename (path) ->
      path.basename += "_template"
    .pipe gulp.dest('.src-js')

gulp.task 'compile_coffee', ['clean'], ->
  gulp.src ['src/*/*.coffee', 'src/components.coffee']
    .pipe coffee({bare: true})
    .pipe gulp.dest('.src-js')


###
Markdown documentation generator converts docstring in the
code into a gitHub markdown file (readme.md) and stores it
in every component.
###
gulp.task 'markdown_docs', ['clean', 'compile_coffee'], ->
  gulp.src "#{COMPILED_SRC}/**/*.js"
    .pipe jsdoc2md({'private': true})
    .on 'error', (err) ->
      console.log "jsdoc2md failed: #{err.message}"
    .pipe rename (path) ->
      path.basename = "readme"
      path.extname = '.md'
    .pipe gulp.dest('src')


###
Combine all the component into one JavaScript file. Additionaly
this file gets uglified with a SourceMap
###
gulp.task 'combine_minifiy', ['compile_coffee', 'compile_template'], ->
  gulp.src "#{COMPILED_SRC}/**/*.js"
    .pipe concat('shift-components.js')
    .pipe gulp.dest(BUILD_DEST)
    .pipe sourceMap.init()
    .pipe uglify()
    .pipe rename(extname: '.min.js')
    .pipe sourceMap.write('./')
    .pipe gulp.dest(BUILD_DEST)

###
Delete all the compiled coffee and jade
###
gulp.task 'clean', (done) ->
  del ['src/**/*.md', COMPILED_SRC, BUILD_DEST, EXAMPLES_DEST, COMPILED_EXAMPLES], done

###
Monitor changes on coffee files, trigger default on change
###
gulp.task 'watch', ['combine_minifiy', 'markdown_docs', 'examples'], ->

  # Compile, generate docs and examples on coffee and jade changes to the library
  gulp.watch [
    'src/*/*.coffee'
    'src/components.coffee'
    './src/template.jade'
    './src/*/*.jade'
    'src/*/example/*.jade'
    'src/*/example/*.styl'
    'src/*/example/*.coffee'
  ], ['combine_minifiy', 'markdown_docs', 'examples']


###
Web service to browse and auto-reload of examples
Runs on http://127.0.0.1:8080
###
gulp.task 'connect', ->
  connect.server {
    root: EXAMPLES_DEST,
    livereload: true
  }

###
Run e2e tests
###
gulp.task 'test', ['combine_minifiy'], ->
  gulp.src 'src/*/test/*.spec.coffee'
  .pipe protractor
      configFile: 'protractor.conf.coffee',
      args: ['--baseUrl', 'http://127.0.0.1:8000']
  .on 'error', (err) ->
    console.log "protractor failed: #{err.message}"

###
Generates the examples HTML files located in the examples folder.
Also moves copy of third party dependancies like momentJS and lodash.
###
gulp.task 'examples', ['combine_minifiy', 'compile_example'], ->
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
      'bower_components/momentjs/moment.js'
      'bower_components/lodash/lodash.js'
      'bower_components/prism/prism.js'
      'bower_components/prism/components/prism-coffeescript.js'
      'bower_components/prism/components/prism-jade.js'
      'bower_components/prism/components/prism-stylus.js'
      'bower_components/prism/components/prism-javascript.js'
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

# Translate coffee file into JS and generate MarkDown doc
gulp.task 'default', (cb) ->
  runSequence 'clean', ['watch', 'connect'], cb
