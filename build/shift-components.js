
/**
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable

@module shift.components

@link sortable/
 */
angular.module('shift.components', ['shift.components.sortable']);


/**
Sortable directive to allow drag n' drop sorting of an array of object

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed

@example
```jade
ul
  li(
    ng-repeat = "element in list"
    shift-sortable = "list"
    shift-sortable-change = "onListOrderChange"
  ) {{ element.name }}
```
 */
var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('shift.components.sortable', []).directive('shiftSortable', function() {
  return {
    restrict: 'A',
    scope: {
      shiftSortable: '=',
      shiftSortableChange: '&'
    },
    link: function(scope, element, attrs) {
      var container, dragging, getElementAt, grab, hovered_element, isAfterLastElement, isInsideContainer, move, placeholder, release, start_position;
      container = element[0];
      dragging = null;
      start_position = null;
      hovered_element = null;
      placeholder = document.createElement('div');
      placeholder.className = 'placeholder';
      getElementAt = function(x, y) {
        var coord, i, len, ref;
        y -= $(window).scrollTop();
        x -= $(window).scrollLeft();
        ref = container.children;
        for (i = 0, len = ref.length; i < len; i++) {
          element = ref[i];
          coord = element.getBoundingClientRect();
          if (x > coord.left && x < coord.right && y > coord.top && y < coord.bottom) {
            if (!element.getAttribute('shift-sortable-still')) {
              return element;
            }
          }
        }
      };
      isInsideContainer = function(x, y) {
        var coord;
        y -= $(window).scrollTop();
        x -= $(window).scrollLeft();
        coord = container.getBoundingClientRect();
        return x > coord.left && x < coord.right && y > coord.top && y < coord.bottom;
      };
      isAfterLastElement = function(x, y) {
        var coord, x_offset, y_offset;
        y -= $(window).scrollTop();
        x -= $(window).scrollLeft();
        coord = container.children[container.children.length - 1].getBoundingClientRect();
        x_offset = (coord.right - coord.left) * .50;
        y_offset = (coord.bottom - coord.top) * .50;
        return (x > coord.right - x_offset && y > coord.top) || (x > coord.left && y > coord.bottom - y_offset);
      };
      grab = function(event) {
        var ref;
        event.preventDefault();
        if ((ref = event.target, indexOf.call(container.children, ref) >= 0) && !event.target.getAttribute('shift-sortable-still')) {
          dragging = event.target;
          start_position = $(dragging).index();
          placeholder.style.width = dragging.clientWidth + "px";
          placeholder.style.height = dragging.clientHeight + "px";
          dragging.style.minWidth = ($(dragging).width()) + "px";
          dragging.style.minHeight = ($(dragging).height()) + "px";
          window.addEventListener('mousemove', move);
          window.addEventListener('mouseup', release);
          container.insertBefore(placeholder, dragging);
          document.body.appendChild(dragging);
          $(dragging).addClass('dragging');
          move(event);
        }
        return false;
      };
      move = function(event) {
        var elt;
        event.preventDefault();
        dragging.style.left = (event.pageX - 10) + "px";
        dragging.style.top = (event.pageY - 10) + "px";
        if (!isInsideContainer(event.pageX, event.pageY)) {
          return false;
        }
        if (isAfterLastElement(event.pageX, event.pageY)) {
          container.appendChild(placeholder);
        } else {
          elt = getElementAt(event.pageX, event.pageY);
          if ((elt != null) && elt !== hovered_element) {
            hovered_element = elt;
            container.insertBefore(placeholder, elt);
          }
        }
        return false;
      };
      release = function(event) {
        var end_position;
        end_position = $(placeholder).index();
        $(dragging).removeClass('dragging');
        container.insertBefore(dragging, placeholder);
        container.removeChild(placeholder);
        dragging.style.left = placeholder.style.width = dragging.style.minWidth = '';
        dragging.style.top = placeholder.style.height = dragging.style.minHeight = '';
        dragging = null;
        window.removeEventListener('mousemove', move);
        window.removeEventListener('mouseup', release);
        if (end_position !== start_position) {
          return scope.$apply(function() {
            var record;
            record = scope.shiftSortable.splice(start_position, 1)[0];
            scope.shiftSortable.splice(end_position, 0, record);
            return typeof scope.shiftSortableChange === "function" ? scope.shiftSortableChange() : void 0;
          });
        }
      };
      return container.addEventListener('mousedown', grab);
    }
  };
});
