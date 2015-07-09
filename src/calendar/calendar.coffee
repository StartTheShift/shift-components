###*
Calendar directive displays the date and changes it on click.

Note that moment(moment_object) is heavily used to clone a date instead of
just passing the reference (since date is a moment object). It allows simpler
date handeling without the the risk of impacting associated dates.

@module shift.components.calendar

@requires momentJS
@requires lodash

@param {moment} date A moment object, default to now
@param {function} change Called when date is changed
@param {function} validator Method returning a Boolean indicating if
the selected date is valid or not
@param {function} highlight Method returning a Boolean to highlight
a days on the calendar.
@param {Boolean} allowNull Indicate if the date can be set to null

@example
```jade
shift-calendar(
  ng-model = "date"
  change = "onDateChange(date)"
  validator = "isValidDate"
  highlight = "isSpecialDay"
  allow-null = "true"
)
```
###
angular.module 'shift.components.calendar', []
  .directive 'shiftCalendar',
    ->
      restrict: 'E'
      templateUrl: 'calendar/calendar.html'
      require: 'ngModel'
      scope:
        date: '=ngModel'
        change: '&'
        validator: '='
        highlight: '='
        allowNull: '='

      link: (scope) ->
        scope.goToNextMonth = ->
          scope.showing_date.add(1, 'month')
          buildCalendarScope()

        scope.goToPreviousMonth = ->
          scope.showing_date.subtract(1, 'month')
          buildCalendarScope()

        scope.goToSelectedDate = ->
          scope.showing_date = moment(scope.date)
          buildCalendarScope()

        scope.selectDate = ($event) ->
          updateDate moment $event.target.getAttribute('data-iso')

        scope.setNull = ->
          return unless scope.allowNull
          scope.date = null
          buildCalendarScope()
          scope.change()

        isValidDate = (date) ->
          return false unless moment.isMoment(date) and date.isValid()

          if scope.validator?
            return scope.validator date
          return true

        updateDate = (date) ->
          if isValidDate(date)
            scope.date = date
            scope.showing_date = moment(date)
            buildCalendarScope()
            scope.change()

        scope.$watch 'date', (new_value, old_value) ->
            return if new_value is old_value
            updateDate(new_value)

        scope.getClass = (date) ->
          return {
           active: scope.date?.isSame(date, 'day')
           off: not scope.showing_date.isSame(date, 'month')
           available: isValidDate(date)
           invalid: not isValidDate(date)
           highlight: scope.highlight?(date)
          }

        do buildCalendarScope = ->
          date = moment(scope.showing_date).startOf('month').startOf('week')
          end_date = moment(scope.showing_date).endOf('month').endOf('week')

          if scope.date?.isValid?()
            date.set('hour', scope.date.get('hour'))
            date.set('minute', scope.date.get('minute'))
            date.set('second', scope.date.get('second'))

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

        if not scope.allowNull and not moment.isMoment(scope.date)
          scope.date = moment()

        if moment.isMoment(scope.date)
          updateDate scope.date
          scope.showing_date = moment(scope.date)
        else
          scope.showing_date = moment().startOf('day')
