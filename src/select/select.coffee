###*
A directive that displays a list of option, navigation using arrow
keys + enter or mouse click.

The options are not displayed anymore if selected has a value or if
options is emtpy.

@module shift.components.select

@param {array} options Options to be displayed and to choose from
@param {object} selected Object selected from the options
@param {function} onSelect Callback triggered when an option has been selected

@example
```jade
  shift-select(
    options = "options"
    selected = "selected"
    on-select = "onSelect(selected)"
  )
    strong {{option.city}}
    span &nbsp; {{option.state}}
    div
      i pop. {{option.population}}
```
###

angular.module 'shift.components.select', []
  .directive 'shiftSelect', [
    '$compile'
    (
      $compile
    ) ->
      UP_KEY = 38
      DOWN_KEY = 40
      ENTER_KEY = 13

      restrict: 'E'
      transclude: true

      scope:
        options: '='
        selected: '='
        onSelect: '&'

      link: (scope, element, attrs, ctrl, transclude) ->
        # Build the select container
        select_container = angular.element document.createElement 'div'
        select_container.addClass 'select-container'
        select_container.attr
          'ng-if': '!selected && options.length'

        # Build the base option element
        option = angular.element document.createElement 'div'
        option.addClass 'select-option'
        option.attr
          'ng-repeat': 'option in options'
          'ng-class': 'getClass($index)'
          'ng-click': 'select($index)'
          'ng-mouseenter': 'setPosition($index)'

        # Transclude the template to the base option element
        transclude scope, (clone, scope) ->
          option.append clone

        select_container.append option
        element.append select_container

        $compile(select_container) scope
        $compile(option) scope

        scope.position = -1

        onKeyDown = (event) ->
          return unless scope.options?.length

          key_code = event.which or event.keyCode

          return unless key_code in [UP_KEY, DOWN_KEY, ENTER_KEY]

          scope.$apply ->
            switch key_code
              when UP_KEY
                scope.position -= 1
              when DOWN_KEY
                scope.position += 1
              else # ENTER KEY
                if scope.position > -1
                  scope.select scope.position

            # limit the movement to the possible range of the options
            scope.position = Math.max 0, scope.position
            scope.position = Math.min scope.options.length - 1, scope.position

            autoScroll()

          event.preventDefault()
          event.stopPropagation()

          return false

        autoScroll = ->
          container_elt = element[0].children[0]
          option_elt = container_elt.children[scope.position]
          option_pos = option_elt.getBoundingClientRect()
          container_pos = container_elt.getBoundingClientRect()

          # TODO: Find something less arbitrary than 5px margin
          if option_pos.bottom > container_pos.bottom
            container_elt.scrollTop += option_pos.bottom - container_pos.bottom + 5
          if option_pos.top < container_pos.top
            container_elt.scrollTop += option_pos.top - container_pos.top - 5

        scope.select = (index) ->
          scope.position = index
          scope.selected = scope.options[scope.position]

          scope.onSelect {selected: scope.selected}

        scope.setPosition = ($index) ->
          scope.position = $index

        scope.getClass = (index) ->
          return {
            'selected': index is scope.position
          }

        do startListening = ->
          document.addEventListener 'keydown', onKeyDown

        stopListening = ->
          document.removeEventListener 'keydown', onKeyDown

        scope.$on '$destroy', stopListening

        undefined
  ]
