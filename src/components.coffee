###*
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
###

angular.module 'shift.components', [
  'shift.components.sortable'
  'shift.components.calendar'
  'shift.components.selector'
  'shift.components.typeahead'
]
