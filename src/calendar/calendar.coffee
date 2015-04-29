###*
Calendar directive displays the date and changes it on click.

@module shift.components.calendar

@requires momentJS
@requires lodash

@param {moment} date A moment object, default to now
@param {function} dateChange Called when date is changed

@example
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
)
```
###
angular.module 'shift.components.calendar', []
  .directive 'shiftCalendar', [
    ->
      restrict: 'E'
      templateUrl: 'calendar/calendar.html'
      scope:
        date: '='
        dateChange: '&'

      link: (scope) ->
        if not moment.isMoment(scope.date)
          scope.date = moment()

        scope.goToNextMonth = ->
          scope.date.add(1, 'month')
          buildCalendarScope()

        scope.goToPreviousMonth = ->
          scope.date.subtract(1, 'month')
          buildCalendarScope()

        scope.selectDate = ($event) ->
          $event.preventDefault()

          date_iso_8061 = event.target.getAttribute('data-iso')

          if date_iso_8061?
            scope.date = moment(date_iso_8061)
            buildCalendarScope()
            dateChange?()

        do buildCalendarScope = ->
          scope.weeks = []

          date = moment(scope.date).startOf('month').startOf('week')
          end_date = moment(scope.date).endOf('month').endOf('week')

          scope.weeks = []
          while date < end_date
            day_of_the_week = date.day() # from 0 to 6, 0 being sunday
            day_of_the_month = date.date() # from 1 and up to 31

            if day_of_the_week is 0
              week = []
              scope.weeks.push week

            week.push {
              iso_8061: date.format()
              day_of_the_month: day_of_the_month
              # is the month for this date off the selected date's month?
              is_off: scope.date.month() isnt date.month()
              # we want to compare the day and ignore the time
              is_active: date.format('YYYY-MM-DD') is scope.date.format('YYYY-MM-DD')
            }

            date.add(1, 'day')

          undefined
  ]
