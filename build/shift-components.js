
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

Note that moment(moment_object) is heavily used to clone a date instead of
just passing the reference (since date is a moment object). It allows simpler
date handeling without the the risk of impacting associated dates.

@module shift.components.calendar

@requires momentJS
@requires lodash

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
 */
angular.module('shift.components.calendar', []).directive('shiftCalendar', [
  function() {
    return {
      restrict: 'E',
      templateUrl: 'calendar/calendar.html',
      scope: {
        date: '=',
        dateChange: '&',
        dateValidator: '=',
        dateHightlight: '=',
        dateAllowNull: '='
      },
      link: function(scope) {
        var buildCalendarScope, isValidDate, updateDate;
        scope.goToNextMonth = function() {
          scope.showing_date.add(1, 'month');
          return buildCalendarScope();
        };
        scope.goToPreviousMonth = function() {
          scope.showing_date.subtract(1, 'month');
          return buildCalendarScope();
        };
        scope.goToSelectedDate = function() {
          scope.showing_date = moment(scope.date);
          return buildCalendarScope();
        };
        scope.selectDate = function($event) {
          return updateDate(moment($event.target.getAttribute('data-iso')));
        };
        scope.setNull = function() {
          if (!scope.dateAllowNull) {
            return;
          }
          scope.date = null;
          buildCalendarScope();
          return scope.dateChange();
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
            scope.showing_date = moment(date);
            buildCalendarScope();
            return scope.dateChange();
          }
        };
        scope.$watch('date', function(new_value, old_value) {
          if (new_value === old_value) {
            return;
          }
          return updateDate(new_value);
        });
        scope.getClass = function(date) {
          var ref;
          return {
            active: (ref = scope.date) != null ? ref.isSame(date, 'day') : void 0,
            off: !scope.showing_date.isSame(date, 'month'),
            available: isValidDate(date),
            invalid: !isValidDate(date),
            highlight: typeof scope.dateHightlight === "function" ? scope.dateHightlight(date) : void 0
          };
        };
        (buildCalendarScope = function() {
          var date, day_of_the_month, day_of_the_week, end_date, results, week;
          date = moment(scope.showing_date).startOf('month').startOf('week');
          end_date = moment(scope.showing_date).endOf('month').endOf('week');
          scope.weeks = [];
          results = [];
          while (true) {
            day_of_the_week = date.day();
            day_of_the_month = date.date();
            if (day_of_the_week === 0) {
              if (scope.weeks.length > 5) {
                break;
              }
              week = [];
              scope.weeks.push(week);
            }
            week.push({
              iso_8061: date.format(),
              day_of_the_month: day_of_the_month,
              date: moment(date)
            });
            results.push(date.add(1, 'day'));
          }
          return results;
        })();
        if (!scope.dateAllowNull && !moment.isMoment(scope.date)) {
          scope.date = moment();
        }
        if (moment.isMoment(scope.date)) {
          updateDate(scope.date);
          return scope.showing_date = moment(scope.date);
        } else {
          return scope.showing_date = moment().startOf('day');
        }
      }
    };
  }
]);

'use strict';

angular.module('shift.components.calendar').run(['$templateCache', function($templateCache) {

  $templateCache.put('calendar/calendar.html', '<div class="calendar"><table class="table-condensed"><thead><tr><th title="previous month" ng-click="goToPreviousMonth()"><i class="fa fa-chevron-left"></i></th><th><i ng-if="date" title="go to {{ date.format(\'MMMM Do, YYYY\') }}" ng-hide="showing_date.isSame(date, \'month\')" ng-click="goToSelectedDate()" class="fa fa-dot-circle-o"></i></th><th colspan="3" class="month">{{ showing_date.format(\'MMM YYYY\') }}</th><th><i title="Unset date" ng-click="setNull()" ng-if="date &amp;&amp; dateAllowNull" class="fa fa-times"></i></th><th title="next month" ng-click="goToNextMonth()"><i class="fa fa-chevron-right"></i></th></tr><tr><th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th></tr></thead><tbody ng-click="selectDate($event)"><tr ng-repeat="week in weeks track by $index"><td ng-repeat="day in week track by $index" ng-class="getClass(day.date)" data-iso="{{ day.iso_8061 }}">{{ day.day_of_the_month }}</td></tr></tbody></table></div>');

}]);

/**
Sortable directive to allow drag n' drop sorting of an array.

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed

@example
```jade
ul(
  shift-sortable = "list_of_object"
  shift-sortable-change = "onListOrderChange(list_of_object)"
)
  li(ng-repeat = "element in list_of_object") {{ element.name }}
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
      var container, dragging, getElementAt, grab, hovered_element, isBefore, isInside, last_element, move, placeholder, release, start_position;
      container = element[0];
      dragging = null;
      start_position = null;
      hovered_element = null;
      placeholder = document.createElement('div');
      placeholder.className = 'placeholder';
      last_element = {};
      getElementAt = function(x, y) {
        var coord, i, index, last, len, ref;
        last = container.children[container.children.length - 1];
        ref = container.children;
        for (index = i = 0, len = ref.length; i < len; index = ++i) {
          element = ref[index];
          coord = element.getBoundingClientRect();
          if (isInside(x, y, coord)) {
            if (isBefore(x, y, coord)) {
              return element;
            } else if (element === last) {
              return last_element;
            } else {
              return container.children[index + 1];
            }
          }
        }
      };
      isBefore = function(x, y, rectange) {
        var rel_x, rel_y;
        y -= $(window).scrollTop();
        x -= $(window).scrollLeft();
        rel_x = x - rectange.left;
        rel_y = rectange.top + rectange.height - y;
        return rel_y > (rel_x / rectange.width) * rectange.height;
      };
      isInside = function(x, y, rectange) {
        y -= $(window).scrollTop();
        x -= $(window).scrollLeft();
        return x > rectange.left && x < rectange.right && y > rectange.top && y < rectange.bottom;
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
        if (!isInside(event.pageX, event.pageY, container.getBoundingClientRect())) {
          return false;
        }
        elt = getElementAt(event.pageX, event.pageY);
        if (elt != null) {
          if (elt === last_element) {
            container.appendChild(placeholder);
          } else if (elt !== hovered_element) {
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
            return scope.shiftSortableChange();
          });
        }
      };
      return container.addEventListener('mousedown', grab);
    }
  };
});
