###*
Sortable directive to allow drag n' drop sorting of an array of object

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed
@param {Boolean} shiftSortableFixed Set to true if the container is CSS
position fixed.

@example
```jade
ul
  li(
    ng-repeat = "element in list"
    shiftSortable = "list"
  )	{{ element.name }}
```
###
angular.module 'shift.components.sortable', []
	.directive 'shiftSortable', ->
	  restrict: 'A'
	  scope:
	    shiftSortable: '='
	    shiftSortableChange: '&'
	    # if the sortable element container is in a fixed element like a modal
	    # (aka. scrolling doesn't move it) set shift-sortable-fixed to true
	    shiftSortableFixed: '='
	  link: (scope, element, attrs) ->
	    container = element[0]
	    dragging = null
	    start_position = null
	    hovered_element = null

	    placeholder = document.createElement('div')
	    placeholder.className = 'placeholder'

	    getElementAt = (x, y) ->
	      # Adjust position if element is fixed on the screen
	      if scope.shiftSortableFixed
	        y -= $(window).scrollTop()
	        x -= $(window).scrollLeft()

	      for element in container.children
	        coord = element.getBoundingClientRect()
	        if x > coord.left and x < coord.right and y > coord.top and y < coord.bottom
	          return element unless element.getAttribute('shift-sortable-still')

	    isInsideContainer = (x, y) ->
	      # Adjust position if element is fixed on the screen
	      if scope.shiftSortableFixed
	        y -= $(window).scrollTop()
	        x -= $(window).scrollLeft()

	      coord = container.getBoundingClientRect()
	      return x > coord.left and x < coord.right and y > coord.top and y < coord.bottom

	    isAfterLastElement = (x, y) ->
	      # Adjust position if element is fixed on the screen
	      if scope.shiftSortableFixed
	        y -= $(window).scrollTop()
	        x -= $(window).scrollLeft()

	      coord = container.children[container.children.length - 1].getBoundingClientRect()
	      # check if pointer in a 25% bottom and right zone of the object
	      x_offset = (coord.right - coord.left) * .50
	      y_offset = (coord.bottom - coord.top) * .50

	      return (x > coord.right - x_offset and y > coord.top) or (x > coord.left and y > coord.bottom - y_offset)

	    grab = (event) ->
	      event.preventDefault() # prevent text selection while dragging

	      if event.target in container.children and not event.target.getAttribute('shift-sortable-still')
	        dragging = event.target
	        start_position = $(dragging).index()

	        window.addEventListener 'mousemove', move
	        window.addEventListener 'mouseup', release

	        container.insertBefore placeholder, dragging
	        document.body.appendChild dragging
	        $(dragging).addClass('dragging')

	      return false # prevent text selection while dragging

	    move = (event) ->
	      event.preventDefault() # prevent text selection while dragging

	      dragging.style.left = "#{event.pageX}px"
	      dragging.style.top = "#{event.pageY}px"

	      return false unless isInsideContainer(event.pageX, event.pageY)

	      if isAfterLastElement(event.pageX, event.pageY)
	        container.appendChild placeholder
	      else
	        elt = getElementAt(event.pageX, event.pageY)
	        if elt? and elt isnt hovered_element
	          hovered_element = elt
	          container.insertBefore placeholder, elt

	      return false # prevent text selection while dragging

	    release = (event) ->
	      end_position = $(placeholder).index()

	      # DOM: replace placeholder by element and remove its styles
	      $(dragging).removeClass 'dragging'
	      container.insertBefore dragging, placeholder
	      container.removeChild placeholder
	      dragging.style.left = ''
	      dragging.style.top = ''
	      dragging = null

	      window.removeEventListener 'mousemove', move
	      window.removeEventListener 'mouseup', release

	      # now that everything is back in place in the dom, trigger a digest
	      if end_position isnt start_position
	        # move the element in the provided list and trigger a digest cycle
	        scope.$apply ->
	          record = scope.shiftSortable.splice(start_position, 1)[0]
	          scope.shiftSortable.splice(end_position, 0, record)
	          scope.shiftSortableChange?()

	    container.addEventListener 'mousedown', grab