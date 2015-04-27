# shift-components
UI components for SHIFT applications

## Gulp commands

### Watch

Watch the coffee files in the `src` folder and compile them into
JavaScript files into the `src-js` folder

```sh
gulp watch
```

### Clean

Delete `src-js` and `build` folders

```sh
gulp clean
```

### Build

Create a concatenated version of the library into a js file,
uglifies it and generate a source map of the minified version.

```sh
gulp build
```
