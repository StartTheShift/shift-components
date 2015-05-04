# shift-components
UI components for SHIFT applications

## Gulp commands

### Development

Watch the coffee files in the `src` folder and compile them into
JavaScript files into the `src-js` folder. Those are then build
to a single JS file, a minified version and a sourceMap.

Every jade file located in src are compiled into html and stored
into examples folder. The example folder is being served on
http://localhost:8080

```sh
gulp
```

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
combined all the source files in one JS. Templates are also included through
`$templateCache`.

:warning: Note that calling a build will likely generate merge issues if done
on a branch other than master. It's highly recommended to only trigger it on
the master branch post merge.

### Examples

JQuery, lodash, angular, skeletor.css and shift-components are loaded automagically for
every examples.

An example should be composed of a stylus file, a jade file and a coffee file.

See [sortable](src/sortable/example/)

## Fix

There is a potential bug in gulp-inject, reming line feed from stream. The result
is very long examples in the example page. An issue was created on the repository:

https://github.com/klei/gulp-inject/issues/101

As a quick workaround the bug, you can edit the file located at
`node_modules/gulp-inject/src/inject/index.js` and prepend the return value with
a straight string return:

```js
           .concat(files.reduce(function transformFile (lines, file, i) {
             var filepath = getFilepath(file, target, opt);
             var transformedContents = opt.transform(filepath, file, i, files.length, target);
             if (typeof transformedContents !== 'string') {
               return lines;
             }
             # Return the string directly
             return transformedContents;
             # return lines.concat(transformedContents.split(/\r?\n/g));
```
