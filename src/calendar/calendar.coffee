###*
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
###
angular.module 'shift.components.calendar', []
  .directive 'shiftCalendar', [
    ->
      restrict: 'E'
      templateUrl: 'calendar/calendar.html'
      scope:
        date: '='
        dateChange: '&'
        dateValidator: '='

      link: (scope) ->
        if not moment.isMoment(scope.date)
          updateDate moment().startOf('day')

        scope.goToNextMonth = ->
          next_month = moment(scope.date).add(1, 'month')
          updateDate next_month

        scope.goToPreviousMonth = ->
          previous_month = moment(scope.date).subtract(1, 'month')
          updateDate previous_month

        scope.selectDate = ($event) ->
          updateDate moment event.target.getAttribute('data-iso')

        isValidDate = (date) ->
          return false unless moment.isMoment(date) and date.isValid()

          if scope.dateValidator?
            return scope.dateValidator date
          return true

        updateDate = (date) ->
          if isValidDate(date)
            scope.date = date
            buildCalendarScope()
            scope.dateChange()

        scope.$watch 'date', (new_value, old_value) ->
          return if new_value is old_value
          buildCalendarScope()

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
              is_valid: isValidDate(date)
            }

            date.add(1, 'day')

          undefined
  ]
