# shift-components
UI components for SHIFT applications

## Gulp commands

### Development

```sh
gulp
```

Watch the coffee files in the `src` folder and compile them into
JavaScript files into the `src-js` folder.

Every jade file located in src folder are compiled into html and stored
into examples folder. The example folder is being served on
[http://localhost:8080](http://localhost:8080)


### Versioning

A new component should trigger a minor revision aka `B++` in `A.B.C`.

```sh
gulp bump
```

A bug fix should increase the patch aka `C++` in `A.B.C`

```sh
gulp patch
```

Calling `bump` and `patch` will also call a `build`. A call to `build`
combines all the sources in one JS. Templates are also included through
`$templateCache`.

:warning: Note that calling a build will likely generate merge issues if done
on a branch other than master. It's highly recommended to only trigger it on
the master branch post merge.

## Examples

JQuery, lodash, angular, skeletor.css and shift-components are loaded automagically for
every examples. Examples are served and auto-reloaded on code update when running the
dev server (simple `gulp` command).

Examples are served at [http://localhost:8080](http://localhost:8080).

An example should be composed of a stylus file, a jade file and a coffee file.

:warning: Not having those 3 file types in the folder makes the watcher crash. If
someone has time to address the bug in the gulpfile `examples` section, in the
gulp-inject task.

See [sortable](src/sortable/example/) for guidance.

## Fix

There is a potential bug in gulp-inject, removing line breaks from the gulp stream.
The result is very long one line examples on the example page.

An issue was created on gulp-inject repository:

https://github.com/klei/gulp-inject/issues/101

As a quick workaround to the bug, you can edit the file located at
`node_modules/gulp-inject/src/inject/index.js` and prepend the return value with
a straight string return:

```js
           .concat(files.reduce(function transformFile (lines, file, i) {
             var filepath = getFilepath(file, target, opt);
             var transformedContents = opt.transform(filepath, file, i, files.length, target);
             if (typeof transformedContents !== 'string') {
               return lines;
             }
             # Add the following line as a workaround to return the string directly
             return transformedContents;
             # return lines.concat(transformedContents.split(/\r?\n/g));
```
