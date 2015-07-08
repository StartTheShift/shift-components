
/**
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable
@requires shift.components.calendar
@requires shift.components.select
@requires shift.components.typeahead
@requires shift.components.select
@requires shift.components.time

@module shift.components

@link sortable/
 */
angular.module('shift.components', ['shift.components.sortable', 'shift.components.calendar', 'shift.components.selector', 'shift.components.typeahead', 'shift.components.select', 'shift.components.time']);


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
A directive to mimic HTML select but awesome.

@module shift.components.select

@param {array} options Options to be displayed and to choose from
@param {object} option Option selected
@param {function} onSelect Callback triggered when an option has been selected
@param {function} onDiscard Callback triggered when an option has been de-selected
@param {string} placeholder Text to display when no option are selected

@example
```jade
  shift-select(
    options = "options"
    option = "selected_option"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
    placeholder = "Click to make a selection..."
  )
    strong {{option.city}}, {{ option.state }}
    div
      i pop. {{option.population}}
```
 */
angular.module('shift.components.select', ['shift.components.selector']).directive('shiftSelect', ['$compile', function($compile) {
  return {
    restrict: 'E',
    transclude: true,
    templateUrl: 'select/select.html',
    scope: {
      options: '=',
      option: '=',
      onSelect: '&',
      onDiscard: '&',
      placeholder: '@'
    },
    link: function(scope, element, attrs, ctrl, transclude) {
      var onDocumentClick, onKeyup, shift_selected, shift_selected_scope, shift_selector, shift_selector_scope;
      scope.show_select = false;
      shift_selected = angular.element(document.createElement('div'));
      shift_selected.attr({
        'ng-show': 'option',
        'class': 'select-option'
      });
      shift_selector = angular.element(document.createElement('shift-selector'));
      shift_selector.attr({
        'ng-show': 'show_select',
        'options': 'options',
        'on-select': '_onSelect(selected)',
        'on-discard': '_onDiscard(discarded)'
      });
      shift_selector_scope = scope.$new();
      shift_selected_scope = scope.$new();
      transclude(shift_selector_scope, function(clone) {
        return shift_selector.append(clone);
      });
      transclude(shift_selected_scope, function(clone) {
        return shift_selected.append(clone);
      });
      element.children().append(shift_selected);
      element.append(shift_selector);
      $compile(shift_selector)(shift_selector_scope);
      $compile(shift_selected)(shift_selected_scope);
      scope._onDiscard = function(discarded) {
        scope.show_select = false;
        scope.option = null;
        return scope.onDiscard({
          discarded: discarded
        });
      };
      scope._onSelect = function(selected) {
        scope.onSelect({
          selected: selected
        });
        scope.option = selected;
        return scope.show_select = false;
      };
      scope.show = function() {
        return scope.show_select = true;
      };
      onKeyup = function(event) {
        if (event.which === 27) {
          return scope.$apply(function() {
            return scope.show_select = false;
          });
        }
      };
      onDocumentClick = function(event) {
        var target;
        target = event.target;
        while (target != null ? target.parentNode : void 0) {
          if (target === element[0]) {
            return;
          }
          target = target.parentNode;
        }
        return scope.$apply(function() {
          return scope.show_select = false;
        });
      };
      document.addEventListener('click', onDocumentClick);
      document.addEventListener('keyup', onKeyup);
      return scope.$on('$destroy', function() {
        document.removeEventListener('click', onDocumentClick);
        return document.removeEventListener('keyup', onKeyup);
      });
    }
  };
}]);

'use strict';

angular.module('shift.components.select').run(['$templateCache', function($templateCache) {

  $templateCache.put('select/select.html', '<div ng-click="show()" class="select-container"><div ng-if="!option" class="select-option">{{ placeholder }}</div></div>');

}]);

/**
A directive that displays a list of option, navigation using arrow
keys + enter or mouse click.

The options are not displayed anymore if selected has a value or if
options is emtpy.

@module shift.components.selector

@param {array} options Options to be displayed and to choose from
@param {object} selected Object selected from the options
@param {function} onSelect Callback triggered when an option has been selected
@param {function} onDiscard Callback triggered when an option has de-selected
@param {boolean} multiple Indicates if the selection allows selection of more
than one option

@example
```jade
  shift-selector(
    options = "options"
    selected = "selected"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
    multiple
  )
    strong {{option.city}}
    span &nbsp; {{option.state}}
    div
      i pop. {{option.population}}
```
 */
var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('shift.components.selector', []).directive('shiftSelector', ['$compile', function($compile) {
  var DOWN_KEY, ENTER_KEY, UP_KEY;
  UP_KEY = 38;
  DOWN_KEY = 40;
  ENTER_KEY = 13;
  return {
    restrict: 'E',
    transclude: true,
    scope: {
      options: '=',
      selected: '=?',
      onSelect: '&',
      onDiscard: '&'
    },
    link: function(scope, element, attrs, ctrl, transclude) {
      var autoScroll, isSelected, onKeyDown, option, previous_client_y, select_container, startListening, stopListening;
      select_container = angular.element(document.createElement('div'));
      select_container.addClass('select-container');
      select_container.attr({
        'ng-if': 'options.length'
      });
      option = angular.element(document.createElement('div'));
      option.addClass('select-option');
      option.attr({
        'ng-repeat': 'option in options',
        'ng-class': 'getClass($index)',
        'ng-click': 'toggle($index, $event)',
        'ng-mouseenter': 'setPosition($index, $event)'
      });
      transclude(scope, function(clone, scope) {
        return option.append(clone);
      });
      select_container.append(option);
      element.append(select_container);
      $compile(select_container)(scope);
      $compile(option)(scope);
      scope.position = -1;
      if (attrs.multiple != null) {
        if (scope.selected == null) {
          scope.selected = [];
        }
      }
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
                scope.toggle(scope.position, event);
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
        var container_elt, container_pos, margin, option_elt, option_pos, option_style;
        container_elt = element[0].children[0];
        option_elt = container_elt.children[scope.position];
        option_pos = option_elt.getBoundingClientRect();
        container_pos = container_elt.getBoundingClientRect();
        option_style = getComputedStyle(option_elt);
        if (option_pos.bottom > container_pos.bottom) {
          margin = parseInt(option_style.marginBottom, 10);
          container_elt.scrollTop += option_pos.bottom - container_pos.bottom + margin;
        }
        if (option_pos.top < container_pos.top) {
          margin = parseInt(option_style.marginTop, 10);
          return container_elt.scrollTop += option_pos.top - container_pos.top - margin;
        }
      };
      isSelected = function(option) {
        if (attrs.multiple != null) {
          return indexOf.call(scope.selected, option) >= 0;
        }
        return option === scope.selected;
      };
      scope.toggle = function(index, event) {
        event.stopPropagation();
        option = scope.options[index];
        if (isSelected(option)) {
          scope.discard(index);
        } else {
          scope.select(index);
        }
        return false;
      };
      scope.select = function(index) {
        var selected;
        scope.position = index;
        selected = scope.options[scope.position];
        if (attrs.multiple != null) {
          scope.selected.push(selected);
        } else {
          scope.selected = selected;
        }
        return scope.onSelect({
          selected: selected
        });
      };
      scope.discard = function(index) {
        var discarded;
        scope.position = index;
        discarded = scope.options[scope.position];
        if (attrs.multiple != null) {
          _.pull(scope.selected, discarded);
        } else {
          scope.selected = null;
        }
        return scope.onDiscard({
          discarded: discarded
        });
      };
      previous_client_y = 0;
      scope.setPosition = function($index, event) {
        if (event.clientY !== previous_client_y) {
          previous_client_y = event.clientY;
          return scope.position = $index;
        }
      };
      scope.getClass = function(index) {
        var ref;
        return {
          'selected': isSelected((ref = scope.options) != null ? ref[index] : void 0),
          'active': index === scope.position
        };
      };
      (startListening = function() {
        return document.addEventListener('keydown', onKeyDown);
      })();
      stopListening = function() {
        return document.removeEventListener('keydown', onKeyDown);
      };
      return scope.$on('$destroy', stopListening);
    }
  };
}]);


/**
Sortable directive to allow drag n' drop sorting of an array.

@module shift.components.sortable

@requires momentJS
@requires lodash

@param {array} shiftSortable Array of sortable object
@param {function} shiftSortableChange Called when order is changed
@param {function} shiftSortableAdd Called when an item gets added with
the added item as argument (`item` keyword is mandatory)
@param {function} shiftSortableRemove Called when an item gets removed with
the removed item as argument (`item` keyword is mandatory)
@param {string} shiftSortableHandle CSS selector to grab the element (optional)
@param {string} shiftSortableNamespace Namespace for to define multiple possible
source and destinations.

@example
```jade
ul(
  shift-sortable = "list_of_object"
  shift-sortable-change = "onListOrderChange(list_of_object)"
  shift-sortable-handle = ".grab-icon"
  shift-sortable-namespace = "bucket_list"
)
  li(ng-repeat = "element in list_of_object") {{ element.name }}

ul(
  shift-sortable = "list_of_object_excluded"
  shift-sortable-add = "onListAdd(item)"
  shift-sortable-remove = "onListRemove(item)"
  shift-sortable-handle = ".grab-icon"
  shift-sortable-namespace = "bucket_list"
)
  li(ng-repeat = "element in list_of_object_excluded") {{ element.name }}
```
 */
var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('shift.components.sortable', []).service('shiftSortableService', function() {
  var namespaces;
  namespaces = {};
  return {
    register: function(namespace, container, scope) {
      if (namespaces[namespace] == null) {
        namespaces[namespace] = [];
      }
      namespaces[namespace].push({
        container: container,
        scope: scope
      });
      return namespaces[namespace];
    }
  };
}).directive('shiftSortable', ['shiftSortableService', function(shiftSortableService) {
  return {
    restrict: 'A',
    scope: {
      shiftSortable: '=',
      shiftSortableChange: '&',
      shiftSortableAdd: '&',
      shiftSortableRemove: '&',
      shiftSortableHandle: '@',
      shiftSortableNamespace: '@'
    },
    link: function(scope, element, attrs) {
      var container, dragging, getElementAt, grab, hovered_element, isBefore, isInside, last_element, move, movePlaceholder, placeholder, release, sortables, start_position;
      container = element[0];
      dragging = null;
      start_position = null;
      hovered_element = null;
      last_element = {};
      placeholder = document.createElement('div');
      placeholder.className = 'placeholder';
      if (scope.shiftSortableNamespace) {
        sortables = shiftSortableService.register(scope.shiftSortableNamespace, container, scope);
      }
      getElementAt = function(container, x, y) {
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
        target = event.target;
        if (scope.shiftSortableHandle != null) {
          if (!target.matches(scope.shiftSortableHandle)) {
            return;
          }
          while (target.parentNode !== container) {
            target = target.parentNode;
          }
        }
        event.preventDefault();
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
        var i, len, results, sortable;
        event.preventDefault();
        dragging.style.left = (event.pageX - 10) + "px";
        dragging.style.top = (event.pageY - 10) + "px";
        if (scope.shiftSortableNamespace) {
          results = [];
          for (i = 0, len = sortables.length; i < len; i++) {
            sortable = sortables[i];
            results.push(movePlaceholder(sortable.container, event));
          }
          return results;
        } else {
          return movePlaceholder(container, event);
        }
      };
      movePlaceholder = function(container, event) {
        var elt;
        if (!isInside(event.pageX, event.pageY, container.getBoundingClientRect())) {
          return false;
        }
        if (container.children.length === 0) {
          container.appendChild(placeholder);
        } else {
          elt = getElementAt(container, event.pageX, event.pageY);
          if (elt != null) {
            if (elt === last_element) {
              container.appendChild(placeholder);
            } else if (elt !== hovered_element) {
              hovered_element = elt;
              container.insertBefore(placeholder, elt);
            }
          }
        }
        return false;
      };
      release = function(event) {
        var container_changed, drop_container, end_position, i, len, position_changed, record, results, sortable;
        end_position = $(placeholder).index();
        drop_container = placeholder.parentNode;
        container_changed = drop_container !== container;
        position_changed = end_position !== start_position;
        $(dragging).removeClass('dragging');
        if (!(container_changed || position_changed)) {
          drop_container.insertBefore(dragging, placeholder);
        }
        drop_container.removeChild(placeholder);
        dragging.style.left = placeholder.style.width = dragging.style.minWidth = '';
        dragging.style.top = placeholder.style.height = dragging.style.minHeight = '';
        dragging = null;
        window.removeEventListener('mousemove', move);
        window.removeEventListener('mouseup', release);
        if (container_changed) {
          record = null;
          scope.$apply(function() {
            record = scope.shiftSortable.splice(start_position, 1)[0];
            scope.shiftSortableChange();
            return scope.shiftSortableRemove({
              item: record
            });
          });
          results = [];
          for (i = 0, len = sortables.length; i < len; i++) {
            sortable = sortables[i];
            if (sortable.container === drop_container) {
              results.push(sortable.scope.$apply(function() {
                sortable.scope.shiftSortable.splice(end_position, 0, record);
                sortable.scope.shiftSortableChange();
                return sortable.scope.shiftSortableAdd({
                  item: record
                });
              }));
            } else {
              results.push(void 0);
            }
          }
          return results;
        } else if (position_changed) {
          return scope.$apply(function() {
            record = scope.shiftSortable.splice(start_position, 1)[0];
            scope.shiftSortable.splice(end_position, 0, record);
            return scope.shiftSortableChange();
          });
        }
      };
      container.addEventListener('mousedown', grab);
      return scope.$on('$destroy', function() {
        container.removeEventListener('mousedown', grab);
        if (sortables) {
          return _.remove(sortables, function(sortable) {
            return sortable.scope === scope;
          });
        }
      });
    }
  };
}]);


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

@requires shift.components.selector

@param {array} sources Source of options to be filtered by the input
@param {string} filterAttribute Name of the attribute for the filter
@param {object} selected Object selected within the source
@param {function} onOptionSelect Invoked when a multiselect option is selected
@param {function} onOptionDeselect Invoked when a multiselect option is deselected
@param {string} placeholder Placeholder text for the input
@param {bool} show_options_on_focus Open the select menu on focus
@param {bool} show_selectmenu
@param {bool} close_menu_on_esc Enable closing the menu with the escape key
@param {string} multiselect An *attribute* to toggle shift-multiselect support

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

//- with multiselect enabled:
shift-typeahead(
  sources = "list_of_object"
  filterAttribute = "city"
  selected = "selected_cities"
  multiselect
)
  label(for="shift_multiselect_option_{{$index}}") {{option.city}}
```
 */
angular.module('shift.components.typeahead', ['shift.components.selector']).directive('shiftTypeahead', ['$compile', '$filter', function($compile, $filter) {
  return {
    restrict: 'E',
    transclude: true,
    templateUrl: 'typeahead/typeahead.html',
    scope: {
      source: '=',
      filterAttribute: '@',
      selected: '=',
      onOptionSelect: '&',
      onOptionDeselect: '&',
      placeholder: '@',
      show_options_on_focus: '=showOptionsOnFocus',
      show_select_menu: '=?showSelectMenu',
      close_menu_on_esc: '=closeMenuOnEsc'
    },
    link: function(scope, element, attrs, ctrl, transclude) {
      var filterOptions, mouse_down, onKeyUp, onMouseDown, select_menu, shift_select_scope, startListening, stopListening;
      scope.options = [];
      if (scope.show_select_menu == null) {
        scope.show_select_menu = false;
      }
      scope.onSelectMultiOption = function(option) {
        return scope.onOptionSelect({
          option: option
        });
      };
      scope.onDeselectMultiOption = function(option) {
        return scope.onOptionDeselect({
          option: option
        });
      };
      select_menu = angular.element(document.createElement('shift-selector'));
      select_menu.attr({
        'ng-show': 'show_select_menu && !selected',
        'options': 'options',
        'selected': 'selected',
        'on-select': 'onSelect(selected)',
        'ng-mousedown': 'mouseDown(true)',
        'ng-mouseup': 'mouseDown(false)'
      });
      if (attrs.multiselect != null) {
        select_menu.attr({
          'multiple': 'true',
          'on-select': 'onSelectMultiOption(selected)',
          'on-discard': 'onDeselectMultiOption(discarded)',
          'ng-show': 'show_select_menu'
        });
      }
      shift_select_scope = scope.$new();
      transclude(shift_select_scope, function(clone) {
        return select_menu.append(clone);
      });
      element.append(select_menu);
      $compile(select_menu)(shift_select_scope);
      filterOptions = function() {
        var filter;
        if (scope.query) {
          filter = {};
          filter[scope.filterAttribute] = scope.query;
          scope.options = $filter('filter')(scope.source, filter).slice(0, 6);
          return scope.show_select_menu = true;
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
      scope.onFocus = function($event) {
        scope.show_select_menu = true;
        if (scope.show_options_on_focus) {
          if (scope.query) {
            return filterOptions();
          } else {
            return scope.options = scope.source;
          }
        }
      };
      scope.onSelect = function(selected) {
        scope.selected = selected;
        return scope.query = selected != null ? selected[scope.filterAttribute] : void 0;
      };
      scope.$watch('query', function(new_value, old_value) {
        var ref;
        if (new_value === old_value) {
          return;
        }
        if (attrs.multiselect == null) {
          if (scope.query !== ((ref = scope.selected) != null ? ref[scope.filterAttribute] : void 0)) {
            scope.selected = null;
          }
        }
        return filterOptions();
      });
      onKeyUp = function(event) {
        var key;
        key = event.which || event.keyCode;
        if (!scope.close_menu_on_esc) {
          return;
        }
        if (key === 27 && scope.show_select_menu) {
          event.stopPropagation();
          return scope.$apply(function() {
            return scope.show_select_menu = false;
          });
        }
      };
      onMouseDown = function(event) {
        if (!scope.show_select_menu) {
          return;
        }
        if (element.has(event.target).length) {
          return;
        }
        scope.$apply(function() {
          return scope.show_select_menu = false;
        });
      };
      (startListening = function() {
        document.addEventListener('keyup', onKeyUp);
        if (attrs.multiselect != null) {
          return document.addEventListener('mousedown', onMouseDown);
        }
      })();
      stopListening = function() {
        document.removeEventListener('keyup', onKeyUp);
        return document.removeEventListener('mousedown', onMouseDown);
      };
      return scope.$on('$destroy', stopListening);
    }
  };
}]);

'use strict';

angular.module('shift.components.typeahead').run(['$templateCache', function($templateCache) {

  $templateCache.put('typeahead/typeahead.html', '<input type="text" ng-blur="hide($event)" ng-class="{\'select-menu-visible\': show_select_menu &amp;&amp; options.length}" ng-focus="onFocus($event)" ng-model="query" placeholder="{{placeholder}}">');

}]);

/**
Time directive displays a text input guessing the time entered. Accepts
a moment_object object as model and only inpacts its time.

@module shift.components.time

@requires momentJS
@requires lodash

@param {moment} time A moment object, default to now
@param {function} timeChange Called when date is changed
@param {function} timeValidator Method returning a Boolean indicating if
the selected date is valid or not
@param {Boolean} timeAllowNull Indicate if the date can be set to null

@example
```jade
shift-time(
  time = "date"
  time-change = "onDateChange(date)"
  time-validator = "isValidDate"
)
```
 */
angular.module('shift.components.time', []).directive('shiftTime', function() {
  return {
    restrict: 'E',
    templateUrl: 'time/time.html',
    scope: {
      time: '=',
      timeChange: '&',
      timeValidator: '='
    },
    link: function(scope) {
      var guessTime, isValidDate, original_time_str, updateDate;
      original_time_str = null;
      isValidDate = function(date) {
        if (!(moment.isMoment(date) && date.isValid())) {
          return false;
        }
        if (scope.timeValidator != null) {
          return scope.timeValidator(date);
        }
        return true;
      };
      updateDate = function(date) {
        if (isValidDate(date)) {
          scope.time = date;
          scope.timeChange();
        }
        if (scope.time === null) {
          scope.time_str = '';
        } else {
          scope.time_str = scope.time.format('h:mm a');
        }
        return original_time_str = scope.time_str;
      };
      scope.$watch('time', function(new_time, old_time) {
        if (new_time === old_time) {
          return;
        }
        return updateDate(new_time);
      });
      scope.readTime = function() {
        var hour, minute, new_date, ref;
        if (original_time_str === scope.time_str) {
          return;
        }
        ref = guessTime(scope.time_str), hour = ref[0], minute = ref[1];
        new_date = moment(scope.time).set('hour', hour).set('minute', minute);
        return updateDate(new_date);
      };
      guessTime = function(time_str) {
        var hour, minute, ref, time_re, time_tuple;
        time_re = /(1[0-2]|0?[1-9])[^\d]?([0-5][0-9]|[0-9])?\s?(am|pm|a|p)?/;
        time_tuple = time_re.exec(time_str.toLowerCase());
        if (time_tuple) {
          hour = time_tuple[1] && parseInt(time_tuple[1], 10) || 0;
          minute = time_tuple[2] && parseInt(time_tuple[2], 10) || 0;
          if ((ref = time_tuple[3]) === 'p' || ref === 'pm') {
            hour += 12;
          }
          return [hour, minute];
        }
        return [0, 0];
      };
      if (moment.isMoment(scope.time)) {
        return updateDate(scope.time);
      }
    }
  };
});

'use strict';

angular.module('shift.components.time').run(['$templateCache', function($templateCache) {

  $templateCache.put('time/time.html', '<input type="text" ng-model="time_str" placeholder="--:-- pm" ng-blur="readTime()" ng-disabled="!(time &amp;&amp; time.isValid())">');

}]);