###*
Floating element directive displays template content on custom action
executed on the parent element.

@module shift.components.floating

@param {string} trigger The event trigger type click, hover or focus
@param {string} position The positioning of the element relative to its parent
@param {string} fixed if provided, the floating element will be fixed positioned
@param {string} template Template string for the content
@param {number} offset margin from the parent element
@param {DOM element} parent Parent object relative to

@example
```jade
shift-floating(
  trigger = "click|hover|focus"
  position = "top|bottom|left|right"
  parent = ""
  template = ""
  offset = "5"
  fixed
)
```
###

angular.module 'shift.components.floating', []
  .directive 'shiftFloating',
    (
      $compile
    ) ->
      restrict: 'E'
      transclude: 'true'

      scope:
        templateUrl: '@'
        position: '@'
        trigger: '@'
        offset: '@'
        parent: '='

      link: (scope, element, attrs, controllers, transclude) ->
        is_visible = false
        onDestroy = null
        offset = scope.offset or 0

        floating_container = angular.element document.createElement 'div'
        floating_container.addClass "floating-container floating-#{scope.position}"

        floating_container.append transclude()

        container = scope.parent or element[0].parentNode

        scope.show = (template) ->
          return if is_visible
          is_visible = true

          scope.$apply ->
            $(document.body).append(floating_container)
            $compile(floating_container) scope

          # no need for $timeout service, we are doing
          # straight CSS adjustment here
          setTimeout ->
            $(floating_container).offset( $(container).offset() )

            popover_height = $(floating_container[0]).outerHeight()
            popover_width = $(floating_container[0]).outerWidth()
            container_height = $(container).outerHeight()
            container_width = $(container).outerWidth()

            switch scope.position
              when 'top'
                floating_container.css
                  marginLeft: "#{container_width/2 - popover_width/2}px"
                  marginTop: "-#{popover_height + offset}px"
                  visibility: ''

              when 'bottom'
                floating_container.css
                  marginLeft: "#{container_width/2 - popover_width/2}px"
                  marginTop: "#{container_height + offset}px"
                  visibility: ''

              when 'right'
                floating_container.css
                  marginLeft: "#{container_width + offset}px"
                  marginTop: "#{container_height/2 - popover_height/2}px"
                  visibility: ''

              else # default left position
                floating_container.css
                  marginLeft: "-#{popover_width + offset}px"
                  marginTop: "#{container_height/2 - popover_height/2}px"
                  visibility: ''

        scope.hide = ->
          return unless is_visible

          floating_container.remove()
          floating_container.css(
            marginLeft: ''
            marginTop: ''
            visibility: 'hidden'
          )

          is_visible = false

        ###
        Event triggering a hide after the click event
        ###
        hideOnClickOut = (event) ->
          target = event.target

          while target
            if target in [floating_container[0], container]
              return
            target = target.parentNode

          scope.hide()

        hideOnEscape = (event) ->
          if event.which is 27 # ESC key
            scope.$apply scope.hide

        ###
        Triggers
        ###
        switch scope.trigger
          when 'hover'
            container.addEventListener 'mouseenter', scope.show
            container.addEventListener 'mouseout', scope.hide

            onDestroy = ->
              container.removeEventListener 'mouseenter', scope.show
              container.removeEventListener 'mouseout', scope.hide

          when 'focus'
            container.addEventListener 'focus', scope.show
            container.addEventListener 'blur', scope.hide

            onDestroy = ->
              container.removeEventListener 'focus', scope.show
              container.removeEventListener 'blur', scope.hide

          else # 'click' by default
            container.addEventListener 'click', scope.show
            document.addEventListener 'click', hideOnClickOut
            document.addEventListener 'keyup', hideOnEscape

            onDestroy = ->
              container.removeEventListener 'click', scope.show
              document.removeEventListener 'click', hideOnClickOut
              document.addEventListener 'keyup', hideOnEscape


        scope.$on '$destroy', onDestroy

