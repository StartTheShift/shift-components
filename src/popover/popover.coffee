###*
Popover directive displays transcluded content on custom action
executed on the parent element.

@module shift.components.popover

@param {string} shiftPopover the text of the popover
@param {string} shiftPopoverTitle (optional) The title of the popover
@param {string} shiftPopoverTrigger What triggers the popover ? click, hover
or focus.
@param {string} shiftPopoverPosition Default to 'bottom', can also be set to
left, right and top.
@param {string} shiftPopoverTemplateUrl the template URL for rendering. When
provided, the text and title attribute are ignored.
@param {attribute} fixed Use fixed positioning for the the tooltip. To be set
when the trigger object is also fixed positioned.
@param {string} shiftPopoverAttachTo a CSS selector where to put the popover
element. Useful when the popover is appearing in a scrollable area.

@example
```jade
input(
  type = "text"
  ng-model = "foo"
  shift-popover = "lorem ipsum"
  shift-popover-title = "date"
  shift-popover-trigger = "click|hover|focus"
  shift-popover-position = "top|bottom|left|right"
  shift-popover-template-url = "xyz.html"
  shift-popover-attach-to = ".scrollable.classname"
  fixed
)
```
###

angular.module 'shift.components.popover', []
  .directive 'shiftPopover',
    (
      $http
      $compile
      $templateCache
    ) ->
      default_template = '''
        <div class="popover-container">
          <h3
            ng-if = "title"
            class = "popover-title">{{ title }}</h3>
          <p>{{ text }}</p>
        </div>
      '''

      ###
      # Directive definition object
      ###
      restrict: 'A'
      scope: true

      link: (scope, element, attrs, controllers, transclude) ->
        scope.parent_node = element[0]

        do compile = (template=default_template) ->
          shift_floating = angular.element '<shift-floating />'

          scope.title = attrs.shiftPopoverTitle
          scope.text = attrs.shiftPopover

          shift_floating.attr
            parent: 'parent_node'
            attachTo: attrs.shiftPopoverattachTo
            position: attrs.shiftPopoverPosition or 'bottom'
            trigger: attrs.shiftPopoverTrigger or 'click'
            offset: "5"

          if attrs.fixed
            shift_floating.attr {fixed: true}

          shift_floating.html(template)

          $('body').append $compile(shift_floating)(scope)

          undefined

        # Recompile popover on template change
        # attrs.$observe 'templateUrl', ->
        #   return unless attrs.templateUrl
        #   $http.get attrs.templateUrl, cache: $templateCache
        #     .success compile

        scope.$watch attrs.title, (new_value, old_value) ->
          return if new_value is old_value
          compile()

        scope.$watch attrs.text, (new_value, old_value) ->
          return if new_value is old_value
          compile()

