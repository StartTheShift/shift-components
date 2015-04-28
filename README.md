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

JQuery, lodash, angular, skeletor.css and shift-components are available in the
example folder:

```jade
doctype
html.no-js
  head
    title Shift Sortable Demo

    meta(charset='utf-8')
    meta(http-equiv='X-UA-Compatible', content='IE=edge')
    meta(name='description', content='')
    meta(name='viewport', content='width=device-width, initial-scale=1')

    link(rel='stylesheet', href='css/normalize.css')
    link(rel='stylesheet', href='css/skeletor.css')

    script(src='js/angular.js')
    script(src='js/jquery.js')
    script(src='js/shift-components.js')

```

### Clean

Delete `src-js` and `build` folders

```sh
gulp clean
```

