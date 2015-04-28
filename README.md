# shift-components
UI components for SHIFT applications

## Gulp commands

### default

Watch the coffee files in the `src` folder and compile them into
JavaScript files into the `src-js` folder. Those are then build
to a single JS file, a minified version and a sourceMap.

Every jade file located in src are compiled into html and stored
into examples folder. The example folder is being served on
http://localhost:8080

```sh
gulp
```

### Examples

JQuery, lodash, angular, skeletor.css and shift-components are loaded automagically for
every examples.

An example should be composed of a stylus file, a jade file and a coffee file.

See [sortable](src/sortable/example/)

### Clean

Delete `src-js` and `build` folders

```sh
gulp clean
```
