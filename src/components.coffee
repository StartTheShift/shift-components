###*
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable
@requires shift.components.calendar

@module shift.components

@link sortable/
###

angular.module 'shift.components', [
  'shift.components.sortable'
  'shift.components.calendar'
]
