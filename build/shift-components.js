
/**
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable
@requires shift.components.calendar
@requires shift.components.select
@requires shift.components.typeahead

@module shift.components

@link sortable/
 */
angular.module('shift.components', ['shift.components.sortable', 'shift.components.calendar', 'shift.components.select', 'shift.components.typeahead']);


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
angular.module('shift.components.calendar', []).directive('shiftCalendar', function() {
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
});

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
 */
var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('shift.components.sortable', []).directive('shiftSortable', function() {
  return {
    restrict: 'A',
    scope: {
      shiftSortable: '=',
      shiftSortableChange: '&',
      shiftSortableHandle: '@'
    },
    link: function(scope, element, attrs) {
      var container, dragging, getElementAt, grab, hovered_element, isBefore, isInside, last_element, move, placeholder, release, start_position;
      container = element[0];
      dragging = null;
      start_position = null;
      hovered_element = null;
      last_element = {};
      placeholder = document.createElement('div');
      placeholder.className = 'placeholder';
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
        var target;
        event.preventDefault();
        target = event.target;
        if (scope.shiftSortableHandle != null) {
          if (!target.matches(scope.shiftSortableHandle)) {
            return;
          }
          while (target.parentElement !== container) {
            target = target.parentElement;
          }
        }
        if (indexOf.call(container.children, target) >= 0) {
          dragging = target;
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


/**
A directive that displays a list of option, navigation using arrow
keys + enter or mouse click.

The options are not displayed anymore if selected has a value or if
options is emtpy.

@module shift.components.select

@param {array} options Options to be displayed and to choose from
@param {object} selected Object selected from the options
@param {function} onSelect Callback triggered when an option has been selected

@example
```jade
  shift-select(
    options = "options"
    selected = "selected"
    on-select = "onSelect(selected)"
  )
    strong {{option.city}}
    span &nbsp; {{option.state}}
    div
      i pop. {{option.population}}
```
 */
angular.module('shift.components.select', []).directive('shiftSelect', function($compile) {
  var DOWN_KEY, ENTER_KEY, UP_KEY;
  UP_KEY = 38;
  DOWN_KEY = 40;
  ENTER_KEY = 13;
  return {
    restrict: 'E',
    transclude: true,
    scope: {
      options: '=',
      selected: '=',
      onSelect: '&'
    },
    link: function(scope, element, attrs, ctrl, transclude) {
      var autoScroll, onKeyDown, option, select_container, startListening, stopListening;
      select_container = angular.element(document.createElement('div'));
      select_container.addClass('select-container');
      select_container.attr({
        'ng-if': '!selected && options.length'
      });
      option = angular.element(document.createElement('div'));
      option.addClass('select-option');
      option.attr({
        'ng-repeat': 'option in options',
        'ng-class': 'getClass($index)',
        'ng-click': 'select($index)',
        'ng-mouseenter': 'setPosition($index)'
      });
      transclude(scope, function(clone, scope) {
        return option.append(clone);
      });
      select_container.append(option);
      element.append(select_container);
      $compile(select_container)(scope);
      $compile(option)(scope);
      scope.position = -1;
      onKeyDown = function(event) {
        var key_code, ref;
        if (!((ref = scope.options) != null ? ref.length : void 0)) {
          return;
        }
        key_code = event.which || event.keyCode;
        if (key_code !== UP_KEY && key_code !== DOWN_KEY && key_code !== ENTER_KEY) {
          return;
        }
        scope.$apply(function() {
          switch (key_code) {
            case UP_KEY:
              scope.position -= 1;
              break;
            case DOWN_KEY:
              scope.position += 1;
              break;
            default:
              if (scope.position > -1) {
                scope.select(scope.position);
              }
          }
          scope.position = Math.max(0, scope.position);
          scope.position = Math.min(scope.options.length - 1, scope.position);
          return autoScroll();
        });
        event.preventDefault();
        event.stopPropagation();
        return false;
      };
      autoScroll = function() {
        var container_elt, container_pos, option_elt, option_pos;
        container_elt = element[0].children[0];
        option_elt = container_elt.children[scope.position];
        option_pos = option_elt.getBoundingClientRect();
        container_pos = container_elt.getBoundingClientRect();
        if (option_pos.bottom > container_pos.bottom) {
          container_elt.scrollTop += option_pos.bottom - container_pos.bottom + 5;
        }
        if (option_pos.top < container_pos.top) {
          return container_elt.scrollTop += option_pos.top - container_pos.top - 5;
        }
      };
      scope.select = function(index) {
        scope.position = index;
        scope.selected = scope.options[scope.position];
        return scope.onSelect({
          selected: scope.selected
        });
      };
      scope.setPosition = function($index) {
        return scope.position = $index;
      };
      scope.getClass = function(index) {
        return {
          'selected': index === scope.position
        };
      };
      (startListening = function() {
        return document.addEventListener('keydown', onKeyDown);
      })();
      stopListening = function() {
        return document.removeEventListener('keydown', onKeyDown);
      };
      scope.$on('$destroy', stopListening);
      return void 0;
    }
  };
});


/**
Typeahead directive displaying a set of option to choose from as input changes.

The transcluded object attributes are prepend with `option.`. In the case of the
example, the sources are

```coffee
$scope.sources = [
  {state: 'ca', city: 'Los Angeles', population: 3884307}
  ...
]
```

in the transcluded template section, you would then access the population information
through `{{ option.population }}`

@module shift.components.typeahead

@requires shift.components.select

@param {array} sources Source of options to be filtered by the input
@param {string} filterAttribute Name of the attribute for the filter
@param {object} selected Object selected within the source

@example
```jade
shift-typeahead(
  sources = "list_of_object"
  filterAttribute = "city"
  selected = "selected_city"
)
  strong {{option.city}}
  span &nbsp; {{option.state}}
  div
    i pop. {{option.population}}
```
 */
angular.module('shift.components.typeahead', ['shift.components.select']).directive('shiftTypeahead', function($compile, $filter) {
  return {
    restrict: 'E',
    transclude: true,
    templateUrl: 'typeahead/typeahead.html',
    scope: {
      source: '=',
      filterAttribute: '@',
      selected: '='
    },
    link: function(scope, element, attrs, ctrl, transclude) {
      var filterOptions, mouse_down, shift_select, shift_select_scope;
      shift_select = angular.element(document.createElement('shift-select'));
      shift_select.attr({
        'ng-show': 'show_select_menu',
        'options': 'options',
        'selected': 'selected',
        'on-select': 'onSelect(selected)',
        'ng-mousedown': 'mouseDown(true)',
        'ng-mouseup': 'mouseDown(false)'
      });
      shift_select_scope = scope.$new();
      transclude(shift_select_scope, function(clone) {
        return shift_select.append(clone);
      });
      element.append(shift_select);
      $compile(shift_select)(shift_select_scope);
      filterOptions = function() {
        var filter;
        if (scope.query) {
          filter = {};
          filter[scope.filterAttribute] = scope.query;
          return scope.options = $filter('filter')(scope.source, filter).slice(0, 6);
        } else {
          return scope.options = [];
        }
      };
      mouse_down = false;
      scope.mouseDown = function(is_down) {
        return mouse_down = is_down;
      };
      scope.hide = function($event) {
        if (!mouse_down) {
          return scope.show_select_menu = false;
        }
      };
      scope.onSelect = function(selected) {
        scope.selected = selected;
        return scope.query = selected != null ? selected[scope.filterAttribute] : void 0;
      };
      return scope.$watch('query', function(new_value, old_value) {
        var ref;
        if (new_value === old_value) {
          return;
        }
        if (scope.query !== ((ref = scope.selected) != null ? ref[scope.filterAttribute] : void 0)) {
          scope.selected = null;
        }
        return filterOptions();
      });
    }
  };
});

'use strict';

angular.module('shift.components.typeahead').run(['$templateCache', function($templateCache) {

  $templateCache.put('typeahead/typeahead.html', '<input type="text" ng-blur="hide($event)" ng-focus="show_select_menu = true" ng-model="query">');

}]);