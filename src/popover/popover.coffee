###*
Popover directive displays transcluded content on custom action
executed on the parent element.

@module shift.components.popover

@param {} date A moment object, default to now
@param {function} dateChange Called when date is changed
@param {function} dateValidator Method returning a Boolean indicating if
the selected date is valid or not
@param {function} dateHightlight Method returning a Boolean to highlight
a days on the calendar.
@param {Boolean} dateAllowNull Indicate if the date can be set to null

@example
```jade
shift-popover(
  title = "date"
  text = "lorem ipsum"
  trigger = "click|hover|focus"
  position = "top|bottom|left|right"
  template-url = ""
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
            ng-show = "title"
            class = "popover-title"
          > {{ title }} </h3>
          <p>{{ text }}</p>
        </div>
      '''

      ###
      # Directive definition object
      ###

      restrict: 'E'
      scope: true

      link: (scope, element, attrs, controllers, transclude) ->
        scope.title = ''
        scope.text = ''
        scope.parent_node = element.parent()?[0]

        compile = (template) ->
          element.empty()

          shift_floating = angular.element '<shift-floating />'

          shift_floating.attr
            parent: 'parent_node'
            position: attrs.position or 'bottom'
            trigger: attrs.trigger or 'click'

          if attrs.fixed
            shift_floating.attr
              fixed: true

          shift_floating.append $compile(template)(scope)
          element.append $compile(shift_floating)(scope)

          undefined

        # Recompile popover on template change
        # attrs.$observe 'templateUrl', ->
        #   return unless attrs.templateUrl
        #   $http.get attrs.templateUrl, cache: $templateCache
        #     .success compile

        # Recompile popover on title/text change
        scope.$watch ->
          "#{attrs.title}, #{attrs.text}"
        , (new_value, old_value) ->
          return unless new_value
          return if new_value isnt old_value

          scope.title = attrs.title
          scope.text = attrs.text
          compile default_template

