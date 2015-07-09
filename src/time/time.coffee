###*
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
###
angular.module 'shift.components.time', []
  .directive 'shiftTime',
    ->
      restrict: 'E'
      templateUrl: 'time/time.html'
      scope:
        time: '='
        timeChange: '&'
        timeValidator: '='

      link: (scope) ->
        original_time_str = null

        isValidDate = (date) ->
          return false unless moment.isMoment(date) and date.isValid()

          if scope.timeValidator?
            return scope.timeValidator date
          return true

        updateDate = (date) ->
          if isValidDate(date)
            scope.time = date
            scope.timeChange()

          # if the date set is reset to null,
          # display an empty field
          if scope.time is null
            scope.time_str = ''
          else
            scope.time_str = scope.time.format('h:mm a')

          original_time_str = scope.time_str

        scope.$watch 'time', (new_time, old_time) ->
            return if new_time is old_time
            updateDate(new_time)

        scope.readTime = ->
          return if original_time_str is scope.time_str

          [hour, minute] = guessTime(scope.time_str)
          new_date = moment(scope.time).set('hour', hour).set('minute', minute)
          updateDate(new_date)

        guessTime = (time_str) ->
          # Guess and return a time tuple from a string
          time_re = /(1[0-2]|0?[1-9])[^ap\d]?([0-5][0-9]|[0-9])?\s?(am|pm|a|p)?/

          time_tuple = time_re.exec(time_str.toLowerCase())

          if time_tuple
            hour = time_tuple[1] and parseInt(time_tuple[1], 10) or 0
            minute = time_tuple[2] and parseInt(time_tuple[2], 10) or 0

            if time_tuple[3] in ['p', 'pm']
              if hour < 12
                hour += 12

            else
              if hour is 12
                hour = 0

            return [hour, minute]

          return [0,0]

        if moment.isMoment(scope.time)
          updateDate scope.time
