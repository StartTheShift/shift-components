###*
Calendar directive displays the date and changes it on click.

@module shift.components.calendar

@requires momentJS
@requires lodash

@param {moment} date A moment object, default to now
@param {function} dateChange Called when date is changed
@param {function} dateValidator Method returning a Boolean indicating if
the selected date is valid or not
@param {function} dateHightlight Method returning a Boolean to highlight
a days on the calendar.

@example
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
  date-validator = "isValidDate"
  date-highlight = "isSpecialDay"
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
        dateHightlight: '='

      link: (scope) ->
        if not moment.isMoment(scope.date)
          updateDate moment().startOf('day')

        scope.showing_date = moment(scope.date)

        scope.goToNextMonth = ->
          scope.showing_date.add(1, 'month')
          buildCalendarScope()

        scope.goToPreviousMonth = ->
          scope.showing_date.subtract(1, 'month')
          buildCalendarScope()

        scope.goToDate = ->
          scope.showing_date = moment(scope.date)
          buildCalendarScope()

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
            scope.showing_date = moment(date)
            buildCalendarScope()
            scope.dateChange()

        scope.$watch 'date', (new_value, old_value) ->
          return if new_value is old_value
          updateDate(new_value)

        scope.getClass = (date) ->
          return {
           active: scope.date.isSame(date, 'day')
           off: not scope.showing_date.isSame(date, 'month')
           available: isValidDate(date)
           invalid: not isValidDate(date)
           highlight: scope.dateHightlight?(date)
          }

        do buildCalendarScope = ->
          date = moment(scope.showing_date).startOf('month').startOf('week')
          end_date = moment(scope.showing_date).endOf('month').endOf('week')

          scope.weeks = []
          while true
            day_of_the_week = date.day() # from 0 to 6, 0 being sunday
            day_of_the_month = date.date() # from 1 and up to 31


            if day_of_the_week is 0
              break if scope.weeks.length > 5
              week = []
              scope.weeks.push week

            week.push {
              iso_8061: date.format()
              day_of_the_month: day_of_the_month
              date: moment(date)
            }

            date.add(1, 'day')


          undefined
  ]
