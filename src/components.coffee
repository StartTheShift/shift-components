###*
UI components for SHIFT applications

@requires momentJS
@requires lodash
@requires jQuery
@requires shift.components.sortable
@requires shift.components.calendar
@requires shift.components.select
@requires shift.components.typeahead
@requires shift.components.popover
@requires shift.components.select
@requires shift.components.time
@requires shift.components.floating
@requires shift.components.tooltip

@module shift.components

@link sortable/
###

angular.module 'shift.components', [
  'shift.components.sortable'
  'shift.components.calendar'
  'shift.components.selector'
  'shift.components.typeahead'
  'shift.components.popover'
  'shift.components.select'
  'shift.components.time'
  'shift.components.floating'
  'shift.components.tooltip'
]
