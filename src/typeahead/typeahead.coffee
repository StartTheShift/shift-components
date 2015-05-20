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

@requires shift.components.select

@param {array} sources Source of options to be filtered by the input
@param {string} filterAttribute Name of the attribute for the filter
@param {object} selected Object selected within the source

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
```
###
angular.module 'shift.components.typeahead', [
  'shift.components.multiselect'
  'shift.components.select'
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

      link: (scope, element, attrs, ctrl, transclude) ->
        shift_select = angular.element document.createElement 'shift-select'
        shift_select.attr
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
          shift_select.append clone

        # Finally, add shift-select to the shiftTypeahead element
        element.append shift_select

        $compile(shift_select) shift_select_scope

        filterOptions = ->
          if scope.query
            filter = {}
            filter[scope.filterAttribute] = scope.query
            scope.options = $filter('filter')(scope.source, filter)[0..5]

          # No option displayed if not query entered
          else
            scope.options = []

        mouse_down = false
        scope.mouseDown = (is_down) ->
          mouse_down = is_down

        scope.hide = ($event) ->
          if not mouse_down
            scope.show_select_menu = false

        scope.onSelect = (selected) ->
          scope.selected = selected
          scope.query = selected?[scope.filterAttribute]

        scope.$watch 'query', (new_value, old_value) ->
          return if new_value is old_value
          scope.selected = null if scope.query isnt scope.selected?[scope.filterAttribute]
          filterOptions()
