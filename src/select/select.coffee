###*
A directive that displays a list of option, navigation using arrow keys + enter or mouse click.
###

angular.module 'shift.components.select', []
  .directive 'shiftSelect', [
    '$compile'
    '$filter'
    '$timeout'
    (
      $compile
      $filter
      $timeout
    ) ->
      restrict: 'E'
      templateUrl: 'select/select.html'

      scope:
        template: '@'
        options: '='
        filter: '='
        selected: '='
        onSelect: '&'

      link: (scope, element) ->
        UP_KEY = 38
        DOWN_KEY = 40
        ENTER_KEY = 13

        scope.position = -1

        scope.display = (option) ->
          return option.city #unless scope.template
          return $compile scope.template, option

        scope.$watch 'filter', (new_value, old_value) ->
          return if new_value is old_value

          scope.position = -1

          filterOptions()
        , true

        do filterOptions = ->
          scope.filtered_options = $filter('filter')(scope.options, scope.filter)

        onKeyDown = (event) ->
          return unless scope.filtered_options.length

          key_code = event.which or event.keyCode

          return unless key_code in [UP_KEY, DOWN_KEY, ENTER_KEY]

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

          scope.$apply()

          event.preventDefault()
          event.stopPropagation()
          return false

        scope.select = (index) ->
          scope.position = index
          scope.selected = scope.filtered_options[scope.position]

          for own key of scope.filter
            scope.filter[key] = scope.selected[key]

          scope.onSelect()

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
