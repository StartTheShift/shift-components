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
      $timeout
      $window
      $http
      $compile
    ) ->
      restrict: 'E'
      transclude: true

      #templateUrl: 'popover/popover.html'
      scope:
        title: '@'
        text: '@'
        templateUrl: '@'
        position: '@'
        trigger: '@'

      link: (scope, element, attrs, controllers, transclude) ->
        is_visible = false
        renderPopover = null
        onDestroy = null
        is_compiled = false
        offset = 5

        default_template =
          '<div' +
          '  class = "popover-title"' +
          '  ng-if = "title ">{{title}}</div>' +
          '<p>{{ text }}</p>'

        popover = angular.element(
          "<div class=\"popover-container\ popover-#{scope.direction}\" />"
        )

        if 'fixed' of attrs
          $scope.fixed = true

        container = element[0].parentNode


        renderTemplate = (template) ->
          return if is_visible
          is_visible = true

          unless is_compiled
            popover.append $compile(template)(scope)
            is_compiled = true

          scope.$apply ->
            $(document.body).append(popover)

          $timeout ->
            $(popover).offset( $(container).offset() )

            popover_height = $(popover[0]).outerHeight()
            popover_width = $(popover[0]).outerWidth()
            container_height = $(container).outerHeight()
            container_width = $(container).outerWidth()

            switch scope.position
              when 'top'
                popover.css
                  marginLeft: "#{container_width/2 - popover_width/2}px"
                  marginTop: "-#{popover_height + offset}px"
                  visibility: ''

              when 'bottom'
                popover.css
                  marginLeft: "#{container_width/2 - popover_width/2}px"
                  marginTop: "#{container_height + offset}px"
                  visibility: ''

              when 'right'
                popover.css
                  marginLeft: "#{container_width + offset}px"
                  marginTop: "#{container_height/2 - popover_height/2}px"
                  visibility: ''

              else # default left position
                popover.css
                  marginLeft: "-#{popover_width + offset}px"
                  marginTop: "#{container_height/2 - popover_height/2}px"
                  visibility: ''

        scope.hide = ->
          console.log 'hide called', is_visible

          return unless is_visible
          is_visible = false

          popover.remove()
          popover.css(
            marginLeft: ''
            marginTop: ''
            visibility: 'hidden'
          )


        ###
        Event triggering a hide after the click event
        ###
        hideOnClickOut = (event) ->
          target = event.target

          while target
            if target in [popover[0], container]
              return
            target = target.parentNode

          scope.hide()

        hideOnEscape = (event) ->
          if event.which is 27 # ESC key
            scope.$apply scope.hide

        if scope.templateUrl
          $http.get scope.templateUrl
            .then (response) ->
              renderPopover = ->
                renderTemplate(response.data)
        else
          renderPopover = ->
            renderTemplate(default_template)

        ###
        Triggers
        ###
        switch scope.trigger
          when 'hover'
            container.addEventListener 'mouseenter', renderPopover
            container.addEventListener 'mouseout', scope.hide

            onDestroy = ->
              container.removeEventListener 'mouseenter', renderPopover
              container.removeEventListener 'mouseout', scope.hide

          when 'focus'
            container.addEventListener 'focus', renderPopover
            container.addEventListener 'blur', scope.hide

            onDestroy = ->
              container.removeEventListener 'focus', renderPopover
              container.removeEventListener 'blur', scope.hide

          else # 'click' by default
            container.addEventListener 'click', renderPopover
            document.addEventListener 'click', hideOnClickOut
            document.addEventListener 'keyup', hideOnEscape

            onDestroy = ->
              container.removeEventListener 'click', renderPopover
              document.removeEventListener 'click', hideOnClickOut
              document.addEventListener 'keyup', hideOnEscape


        scope.$on '$destroy', onDestroy

