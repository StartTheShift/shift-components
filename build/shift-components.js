
/**
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable
@requires shift.components.calendar

@module shift.components

@link sortable/
 */
angular.module('shift.components', ['shift.components.sortable', 'shift.components.calendar']);


/**
Calendar directive displays the date and changes it on click.

@module shift.components.calendar

@requires momentJS
@requires lodash

@param {moment} date A moment object, default to now
@param {function} dateChange Called when date is changed
@param {function} dateValidator A method returning a Boolean indicating if
the selected date is valid or not

@example
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
  date-validator = "isValidDate"
)
```
 */
angular.module('shift.components.calendar', []).directive('shiftCalendar', [
  function() {
    return {
      restrict: 'E',
      templateUrl: 'calendar/calendar.html',
      scope: {
        date: '=',
        dateChange: '&',
        dateValidator: '='
      },
      link: function(scope) {
        var buildCalendarScope, isValidDate, updateDate;
        if (!moment.isMoment(scope.date)) {
          updateDate(moment().startOf('day'));
        }
        scope.goToNextMonth = function() {
          var next_month;
          next_month = moment(scope.date).add(1, 'month');
          return updateDate(next_month);
        };
        scope.goToPreviousMonth = function() {
          var previous_month;
          previous_month = moment(scope.date).subtract(1, 'month');
          return updateDate(previous_month);
        };
        scope.selectDate = function($event) {
          return updateDate(moment(event.target.getAttribute('data-iso')));
        };
        isValidDate = function(date) {
          if (!(moment.isMoment(date) && date.isValid())) {
            return false;
          }
          if (scope.dateValidator != null) {
            return scope.dateValidator(date);
          }
          return true;
        };
        updateDate = function(date) {
          if (isValidDate(date)) {
            scope.date = date;
            buildCalendarScope();
            return scope.dateChange();
          }
        };
        scope.$watch('date', function(new_value, old_value) {
          if (new_value === old_value) {
            return;
          }
          return buildCalendarScope();
        });
        return (buildCalendarScope = function() {
          var date, day_of_the_month, day_of_the_week, end_date, week;
          scope.weeks = [];
          date = moment(scope.date).startOf('month').startOf('week');
          end_date = moment(scope.date).endOf('month').endOf('week');
          scope.weeks = [];
          while (date < end_date) {
            day_of_the_week = date.day();
            day_of_the_month = date.date();
            if (day_of_the_week === 0) {
              week = [];
              scope.weeks.push(week);
            }
            week.push({
              iso_8061: date.format(),
              day_of_the_month: day_of_the_month,
              is_off: scope.date.month() !== date.month(),
              is_active: date.format('YYYY-MM-DD') === scope.date.format('YYYY-MM-DD'),
              is_valid: isValidDate(date)
            });
            date.add(1, 'day');
          }
          return void 0;
        })();
      }
    };
  }
]);

'use strict';

angular.module('shift.components.calendar').run(['$templateCache', function($templateCache) {

  $templateCache.put('calendar/calendar.html', '<div class="calendar"><table class="table-condensed"><thead><tr><th ng-click="goToPreviousMonth()"><i class="fa fa-arrow-left"></i></th><th colspan="5" class="month">{{ date.format(\'MMM Do, YY\') }}</th><th ng-click="goToNextMonth()"><i class="fa fa-arrow-right"></i></th></tr><tr><th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th></tr></thead><tbody ng-click="selectDate($event)"><tr ng-repeat="week in weeks track by $index"><td ng-repeat="day in week track by $index" ng-class="{active: day.is_active, off: day.is_off, available: day.is_valid, invalid: !day.is_valid}" data-iso="{{ day.iso_8061 }}">{{ day.day_of_the_month }}</td></tr></tbody></table></div>');

}]);

/**
Sortable directive to allow drag n' drop sorting of an array of object

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed

@example
```jade
ul(
  shift-sortable = "list"
  shift-sortable-change = "onListOrderChange(list)"
)
  li(ng-repeat = "element in list") {{ element.name }}
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
