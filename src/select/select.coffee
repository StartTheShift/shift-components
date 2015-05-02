###*
A directive that displays a list of option, navigation using arrow keys + enter or mouse click.
###

angular.module 'shift.components.select', []
  .directive 'shiftSelect', [
    '$compile'
    '$filter'
    (
      $compile
      $filter
    ) ->
      UP_KEY = 38
      DOWN_KEY = 40
      ENTER_KEY = 13

      restrict: 'E'
      transclude: true

      scope:
        options: '='
        filter: '='
        selected: '='
        onSelect: '&'

      link: (scope, element, attrs, ctrl, transclude) ->
        # Build the select container
        select_container = angular.element document.createElement 'div'
        select_container.addClass 'select-container'
        select_container.attr
          'ng-if': '!selected && filtered_options.length'

        # Build the base option element
        option = angular.element document.createElement 'div'
        option.addClass 'select-option'
        option.attr
          'ng-repeat': 'option in filtered_options'
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

        scope.$watch 'filter', (new_value, old_value) ->
          return if new_value is old_value

          scope.position = -1

          filterOptions()
        , true

        do filterOptions = ->
          scope.filtered_options = $filter('filter')(scope.options, scope.filter)

        onKeyDown = (event) ->
          return unless scope.filtered_options?.length

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
            scope.position = Math.min scope.filtered_options.length - 1, scope.position

          event.preventDefault()
          event.stopPropagation()

          return false

        scope.select = (index) ->
          scope.position = index
          scope.selected = scope.filtered_options[scope.position]

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
