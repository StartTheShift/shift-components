###*
A directive that displays a list of option, navigation using arrow
keys + enter or mouse click.

The options are not displayed anymore if selected has a value or if
options is emtpy.

@module shift.components.selector

@param {array} options Options to be displayed and to choose from
@param {object} selected Object selected from the options
@param {function} onSelect Callback triggered when an option has been selected

@example
```jade
  shift-selector(
    options = "options"
    selected = "selected"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
    multiselect = "true"
  )
    strong {{option.city}}
    span &nbsp; {{option.state}}
    div
      i pop. {{option.population}}
```
###

angular.module 'shift.components.selector', []
  .directive 'shiftSelector',
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
        selected: '=?'
        onSelect: '&'
        onDiscard: '&'
        multiselect: '='

      link: (scope, element, attrs, ctrl, transclude) ->
        # Build the select container
        select_container = angular.element document.createElement 'div'
        select_container.addClass 'select-container'
        select_container.attr
          'ng-if': 'options.length'

        # Build the base option element
        option = angular.element document.createElement 'div'
        option.addClass 'select-option'
        option.attr
          'ng-repeat': 'option in options'
          'ng-class': 'getClass($index)'
          'ng-click': 'toggle($index, $event)'
          'ng-mouseenter': 'setPosition($index, $event)'

        # Transclude the template to the base option element
        transclude scope, (clone, scope) ->
          option.append clone

        select_container.append option
        element.append select_container

        $compile(select_container) scope
        $compile(option) scope

        scope.position = -1

        # default to an array as null value if selector allows multiselect
        if scope.multiselect
          scope.selected ?= []

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
                  scope.toggle scope.position, event

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
          option_style = getComputedStyle(option_elt)

          if option_pos.bottom > container_pos.bottom
            margin = parseInt option_style.marginBottom, 10
            container_elt.scrollTop += option_pos.bottom - container_pos.bottom + margin
          if option_pos.top < container_pos.top
            margin = parseInt option_style.marginTop, 10
            container_elt.scrollTop += option_pos.top - container_pos.top - margin

        isSelected = (option) ->
          if scope.multiselect
            return option in scope.selected

          return option is scope.selected

        scope.toggle = (index, event) ->
          event.stopPropagation()

          option = scope.options[index]

          if isSelected(option)
              scope.discard(index)
          else
            scope.select(index)

          return false

        scope.select = (index) ->
          scope.position = index
          selected = scope.options[scope.position]

          if scope.multiselect
            scope.selected.push selected
          else
            scope.selected = selected

          scope.onSelect {selected}

        scope.discard = (index) ->
          scope.position = index
          discarded = scope.options[scope.position]

          if scope.multiselect
            _.pull scope.selected, discarded
          else
            scope.selected = null

          scope.onDiscard {discarded}

        previous_client_y = 0
        scope.setPosition = ($index, event) ->
          # only set the position if the mouse actually
          # moved. Prevent mouse enter from being triggered
          # when the content is moving under the cursor.
          if event.clientY isnt previous_client_y
            previous_client_y = event.clientY
            scope.position = $index

        scope.getClass = (index) ->
          return {
            'selected': isSelected(scope.options[index])
            'active': index is scope.position
          }

        do startListening = ->
          document.addEventListener 'keydown', onKeyDown

        stopListening = ->
          document.removeEventListener 'keydown', onKeyDown

        scope.$on '$destroy', stopListening
