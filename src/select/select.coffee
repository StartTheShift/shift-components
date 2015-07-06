###*
A directive to mimic HTML select but awesome.

@module shift.components.select

@param {array} options Options to be displayed and to choose from
@param {object} option Option selected
@param {function} onSelect Callback triggered when an option has been selected
@param {function} onDiscard Callback triggered when an option has been de-selected
@param {string} placeholder Text to display when no option are selected

@example
```jade
  shift-select(
    options = "options"
    option = "selected_option"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
    placeholder = "Click to make a selection..."
  )
    strong {{option.city}}, {{ option.state }}
    div
      i pop. {{option.population}}
```
###

angular.module 'shift.components.select', ['shift.components.selector']
  .directive 'shiftSelect',
    (
      $compile
    ) ->
      restrict: 'E'
      transclude: true
      templateUrl: 'select/select.html'

      scope:
        options: '='
        option: '='
        onSelect: '&'
        onDiscard: '&'
        placeholder: '@'

      link: (scope, element, attrs, ctrl, transclude) ->
        scope.show_select = false

        shift_selected = angular.element document.createElement 'div'
        shift_selected.attr
          'ng-show': 'option'
          'class': 'select-option'

        shift_selector = angular.element document.createElement 'shift-selector'
        shift_selector.attr
          'ng-show': 'show_select'
          'options': 'options'
          'on-select': '_onSelect(selected)'
          'on-discard': '_onDiscard(discarded)'

        # Create a new scope to transclude + compile the template with (we don't
        # want the child directives directly modifying the scope)
        shift_selector_scope = scope.$new()
        shift_selected_scope = scope.$new()

        # Attach the transcluded template to selector
        transclude shift_selector_scope, (clone) ->
          shift_selector.append clone

        # Attach the transcluded template to the selected option
        transclude shift_selected_scope, (clone) ->
          shift_selected.append clone

        # Finally, add shift-selector and the selected option
        # to the template.
        # Selected is added to the container
        element.children().append shift_selected
        element.append shift_selector

        # ... while the selector is appended to the element itself
        $compile(shift_selector) shift_selector_scope
        $compile(shift_selected) shift_selected_scope

        scope._onDiscard = (discarded) ->
          scope.show_select = false
          scope.option = null
          scope.onDiscard {discarded}

        scope._onSelect = (selected) ->
          scope.onSelect {selected}
          scope.option = selected
          scope.show_select = false

        scope.show = ->
          scope.show_select = true

        # Event: close selector on ESC press and click outside the element
        onKeyup = (event) ->
          if event.which is 27 # ESC key

            scope.$apply ->
              scope.show_select = false

        onDocumentClick = (event) ->
          target = event.target

          while target?.parentNode
            if target is element[0]
              return

            target = target.parentNode

          scope.$apply ->
            scope.show_select = false

        document.addEventListener 'click', onDocumentClick
        document.addEventListener 'keyup', onKeyup

        scope.$on '$destroy', ->
          document.removeEventListener 'click', onDocumentClick
          document.removeEventListener 'keyup', onKeyup
