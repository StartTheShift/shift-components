###*
Tooltip directive displays help text on custom action
executed on the element it is attached to.

@module shift.components.tooltip

@param {string} shiftTooltip the text of the tooltip
@param {string} shiftTooltipTrigger What triggers the tooltip ? click, hover
or focus. Default to hover.
@param {string} shiftTooltipPosition Default to 'top', can also be set to
left, right and top.
@param {attribute} fixed Use fixed positioning for the the tooltip. To be set
when the trigger object is also fixed positioned.
@param {string} shiftTooltipAttachTo a CSS selector where to put the tooltip
element. Useful when the tooltip is appearing in a scrollable area.

@example
```jade
span(
  shift-tooltip = "lorem ipsum"
  shift-tooltip-trigger = "click|hover|focus"
  shift-tooltip-position = "top|bottom|left|right"
  shift-tooltip-attach-to = ".scrollable.classname"
  fixed
) blah blah blah...
```
###
angular.module 'shift.components.tooltip', []
  .directive 'shiftTooltip',
    (
      $http
      $compile
      $templateCache
    ) ->

      template = '<div class="tooltip-container">{{ text }}</div>'

      ###
      # Directive definition object
      ###

      restrict: 'A'
      scope:
        text: '@shiftTooltip'
        position: '@shiftTooltipPosition'
        trigger: '@shiftTooltipTrigger'
        attachTo: '@shiftTooltipattachTo'

      link: (scope, element, attrs, controllers, transclude) ->
        scope.parent_node = element[0]

        do compile = ->
          shift_floating = angular.element '<shift-floating />'

          shift_floating.attr
            parent: 'parent_node'
            attachTo: scope.attachTo
            position: scope.position or 'top'
            trigger: scope.trigger or 'hover'
            offset: "2"

          if attrs.fixed
            shift_floating.attr {fixed: true}

          shift_floating.append $compile(template)(scope)
          $('body').append $compile(shift_floating)(scope)

          undefined

        scope.$watch attrs.title, (new_value, old_value) ->
          return if new_value is old_value
          compile()

