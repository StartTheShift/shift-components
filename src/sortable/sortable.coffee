###*
Sortable directive to allow drag n' drop sorting of an array.

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed
@param {string} shiftSortableHandle CSS selector to grab the element (optional)

@example
```jade
ul(
  shift-sortable = "list_of_object"
  shift-sortable-change = "onListOrderChange(list_of_object)"
  shift-sortable-handle = ".grab-icon"
)
  li(ng-repeat = "element in list_of_object") {{ element.name }}
```
###
angular.module 'shift.components.sortable', []
  .directive 'shiftSortable', ->
    restrict: 'A'
    scope:
      shiftSortable: '='
      shiftSortableChange: '&'
      shiftSortableHandle: '@'
    link: (scope, element, attrs) ->
      container = element[0]
      dragging = null
      start_position = null
      hovered_element = null
      last_element = {} # dummy object to detect if the element is last

      placeholder = document.createElement('div')
      placeholder.className = 'placeholder'

      getElementAt = (x, y) ->
        last = container.children[container.children.length - 1]

        for element, index in container.children
          coord = element.getBoundingClientRect()
          if isInside(x, y, coord)
            if isBefore(x, y, coord)
              return element
            else if element is last
              return last_element
            else
              return container.children[index + 1]

      # Return true if the point defined by x, y is above the diagonal formed by
      # the bottom left to the top right corner of the rectange object.
      isBefore = (x, y, rectange) ->
        # Adjust position if element is fixed on the screen
        y -= $(window).scrollTop()
        x -= $(window).scrollLeft()

        rel_x = x - rectange.left
        rel_y = rectange.top + rectange.height - y

        return rel_y > (rel_x / rectange.width) * rectange.height

      # Return true if the point defined by x, y is inside the rectangle
      isInside = (x, y, rectange) ->
        # Adjust position if element is fixed on the screen
        y -= $(window).scrollTop()
        x -= $(window).scrollLeft()

        return x > rectange.left and x < rectange.right and y > rectange.top and y < rectange.bottom

      grab = (event) ->
        event.preventDefault() # prevent text selection while dragging
        target = event.target

        if scope.shiftSortableHandle?
          return unless target.matches scope.shiftSortableHandle
          while target.parentElement isnt container
            target = target.parentElement

        if target in container.children
          dragging = target
          start_position = $(dragging).index()

          # getting size information with padding for the placholder
          placeholder.style.width = "#{dragging.clientWidth}px"
          placeholder.style.height = "#{dragging.clientHeight}px"

          # getting size information without padding for the flying element
          dragging.style.minWidth = "#{$(dragging).width()}px"
          dragging.style.minHeight = "#{$(dragging).height()}px"

          window.addEventListener 'mousemove', move
          window.addEventListener 'mouseup', release

          container.insertBefore placeholder, dragging
          document.body.appendChild dragging
          $(dragging).addClass('dragging')

          # grabing is also moving
          move event

        return false # prevent text selection while dragging

      move = (event) ->
        event.preventDefault() # prevent text selection while dragging

        dragging.style.left = "#{event.pageX - 10 }px"
        dragging.style.top = "#{event.pageY - 10 }px"

        return false unless isInside(event.pageX, event.pageY, container.getBoundingClientRect())

        elt = getElementAt(event.pageX, event.pageY)
        if elt?
          if elt is last_element
            container.appendChild placeholder
          else if elt isnt hovered_element
            hovered_element = elt
            container.insertBefore placeholder, elt

        return false # prevent text selection while dragging

      release = (event) ->
        end_position = $(placeholder).index()

        # DOM: replace placeholder by element and remove its styles
        $(dragging).removeClass 'dragging'
        container.insertBefore dragging, placeholder
        container.removeChild placeholder
        dragging.style.left = placeholder.style.width = dragging.style.minWidth = ''
        dragging.style.top = placeholder.style.height = dragging.style.minHeight = ''
        dragging = null

        window.removeEventListener 'mousemove', move
        window.removeEventListener 'mouseup', release

        # now that everything is back in place in the dom, trigger a digest
        if end_position isnt start_position
          # move the element in the provided list and trigger a digest cycle
          scope.$apply ->
            record = scope.shiftSortable.splice(start_position, 1)[0]
            scope.shiftSortable.splice(end_position, 0, record)
            scope.shiftSortableChange()

      container.addEventListener 'mousedown', grab
