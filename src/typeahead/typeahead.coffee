###*
Typeahead directive displaying a set of option to choose from as input changes.

The transcluded object attributes are prepend with `option.`. In the case of the
example, the sources are

```coffee
$scope.sources = [
  {state: 'ca', city: 'Los Angeles', population: 3884307}
  ...
]
```

in the transcluded template section, you would then access the population information
through `{{ option.population }}`

@module shift.components.typeahead

@requires shift.components.selector

@param {array} sources Source of options to be filtered by the input
@param {string} filterAttribute Name of the attribute for the filter
@param {object} selected Object selected within the source
@param {function} onOptionSelect Invoked when a multiselect option is selected
@param {function} onOptionDeselect Invoked when a multiselect option is deselected
@param {string} placeholder Placeholder text for the input
@param {bool} show_options_on_focus Open the select menu on focus
@param {bool} show_selectmenu
@param {bool} close_menu_on_esc Enable closing the menu with the escape key
@param {string} multiselect An *attribute* to toggle shift-multiselect support

@example
```jade
shift-typeahead(
  sources = "list_of_object"
  filterAttribute = "city"
  selected = "selected_city"
)
  strong {{option.city}}
  span &nbsp; {{option.state}}
  div
    i pop. {{option.population}}

//- with multiselect enabled:
shift-typeahead(
  sources = "list_of_object"
  filterAttribute = "city"
  selected = "selected_cities"
  multiselect
)
  label(for="shift_multiselect_option_{{$index}}") {{option.city}}
```
###
angular.module 'shift.components.typeahead', [
  'shift.components.multiselect'
  'shift.components.selector'
]
  .directive 'shiftTypeahead',
    (
      $compile
      $filter
    ) ->
      restrict: 'E'
      transclude: true
      templateUrl: 'typeahead/typeahead.html'

      scope:
        source: '='
        filterAttribute: '@'
        selected: '='
        onOptionSelect: '&'
        onOptionDeselect: '&'
        placeholder: '@'
        show_options_on_focus: '=showOptionsOnFocus'
        show_select_menu: '=?showSelectMenu'
        close_menu_on_esc: '=closeMenuOnEsc'

      link: (scope, element, attrs, ctrl, transclude) ->
        scope.show_select_menu ?= false

        scope.onSelectMultiOption = (option) ->
          scope.onOptionSelect?({option})

        scope.onDeselectMultiOption = (option) ->
          scope.onOptionDeselect?({option})

        if attrs.multiselect?
          select_menu = angular.element document.createElement 'shift-multiselect'
          select_menu.attr
            'ng-show': 'show_select_menu'
            'options': 'options'
            'selected': 'selected'
            'on-select': "onSelectMultiOption(option)"
            'on-deselect': 'onDeselectMultiOption(option)'
            'ng-mousedown': 'mouseDown(true)'
            'ng-mouseup': 'mouseDown(false)'

        else
          select_menu = angular.element document.createElement 'shift-selector'
          select_menu.attr
            'ng-show': 'show_select_menu && !selected'
            'options': 'options'
            'selected': 'selected'
            'on-select': 'onSelect(selected)'
            'ng-mousedown': 'mouseDown(true)'
            'ng-mouseup': 'mouseDown(false)'

        # Create a new scope to transclude + compile the template with (we don't
        # want the child directives directly modifying the scope of shiftTypeahead)
        shift_select_scope = scope.$new()

        # Attach the transcluded template to shift-select
        transclude shift_select_scope, (clone) ->
          select_menu.append clone

        # Finally, add shift-select to the shiftTypeahead element
        element.append select_menu
        $compile(select_menu) shift_select_scope

        filterOptions = ->
          if scope.query
            filter = {}
            filter[scope.filterAttribute] = scope.query
            scope.options = $filter('filter')(scope.source, filter)[0..5]
            scope.show_select_menu = true

          # No option displayed if not query entered
          else
            scope.options = []

        mouse_down = false
        scope.mouseDown = (is_down) ->
          mouse_down = is_down

        scope.hide = ($event) ->
          if not mouse_down
            scope.show_select_menu = false

        scope.onFocus = ($event) ->
          scope.show_select_menu = true

          # List options when input has focused
          if scope.show_options_on_focus
            if scope.query
              filterOptions()
            else
              scope.options = scope.source

        scope.onSelect = (selected) ->
          scope.selected = selected
          scope.query = selected?[scope.filterAttribute]

        scope.$watch 'query', (new_value, old_value) ->
          return if new_value is old_value

          unless attrs.multiselect?
            scope.selected = null if scope.query isnt scope.selected?[scope.filterAttribute]

          filterOptions()

        onKeyUp = (event) ->
          key = event.which or event.keyCode

          return unless scope.close_menu_on_esc

          if key is 27 # ESC key
            scope.$apply ->
              scope.show_select_menu = false

        do startListening = ->
          document.addEventListener 'keyup', onKeyUp

        stopListening = ->
          document.removeEventListener 'keyup', onKeyUp

        scope.$on '$destroy', stopListening
