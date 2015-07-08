###*
Popover directive displays transcluded content on custom action
executed on the parent element.

@module shift.components.popover

@param {moment} date A moment object, default to now
@param {function} dateChange Called when date is changed
@param {function} dateValidator Method returning a Boolean indicating if
the selected date is valid or not
@param {function} dateHightlight Method returning a Boolean to highlight
a days on the calendar.
@param {Boolean} dateAllowNull Indicate if the date can be set to null

@example
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
  date-validator = "isValidDate"
  date-highlight = "isSpecialDay"
  date-allow-null = "true"
)
```
###
angular.module 'shift.components.popover', []
  .service 'shiftPopoverService', ->
    popover_scope = null

    register: (scope) ->
      # Hide current popover if any and return
      # a de-registering method
      popover_scope.hide() if popover_scope?
      popover_scope = scope

      # deregistering method removes the popover
      # scope to prevent memory leakage
      return ->
        # make sure we only remove our directive scope
        if popover_scope is scope
          popover_scope = null

  .directive 'shiftPopover',
    (
      $timeout
      $window
      shiftPopoverService
    ) ->
      restrict: 'E'
      transclude: true
      templateUrl: 'popover/popover.html'
      scope:
        on: '@'
        off: '@'
        offDelay: '@'

      compile: (element, attrs, scope)->
        root_element = element[0].parentNode

        getStyle = (element, key, default_value='') ->
          return $window.getComputedStyle(element)[key] or default_value

        # find a parent a non static element
        while getStyle(root_element, 'position', 'static') is 'static'
          root_element = root_element.parentNode

        $(root_element).append(element)

      link: (scope, element, attrs, controllers, transclude) ->

        transclude scope, (copy) ->
          console.log copy

        parent = element[0].parentNode
        unregister = null

        show = (event) ->
          scope.$apply scope.show

        hide = (event) ->
          scope.$apply scope.hide

        scope.show = ->
          unregister = shiftPopoverService.register(scope)
          scope.visible = true
          window.addEventListener 'keyup', hideOnEscape
          document.body.addEventListener 'mousedown', hideOnClickOut

        scope.hide = ->
          scope.visible = false
          unregister()
          window.removeEventListener 'keyup', hideOnEscape
          document.body.removeEventListener 'mousedown', hideOnClickOut

        hideOnClickOut = (event) ->
          target = event.target
          while target
            return if target is parent
            target = target.parent

          scope.$apply scope.hide

        hideOnEscape = (event) ->
          if event.which is 27 # ESC key
            scope.$apply scope.hide

        if scope.off
          parent.addEventListener scope.off, ->
            $timeout scope.hide, scope.offDelay

        parent.addEventListener scope.on, show

        # unregister the popover on destroy
        scope.$on '$destroy', ->
          unregister()
          parent.removeEventListener scope.on, trigger
          window.removeEventListener 'keyup', hideOnEscape
          document.body.removeEventListener 'mousedown', hideOnClickOut
