###*
Time directive displays a text input guessing the time entered.

@module shift.components.time

@requires momentJS
@requires lodash

@param {moment} time A moment object, default to now
the selected date is valid or not

@example
```jade
input(
  ng-model = "date"
  type = "text"
  shift-time
)
```
###
angular.module 'shift.components.time', []
  .directive 'shiftTime',
    (
      $timeout
    ) ->
      require: 'ngModel'
      restrict: 'A'
      scope:
        time: '=ngModel'

      link: (scope, element, attr, ngModel) ->
        # Guess and return a time tuple from a string
        guessTime = (time_str) ->
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

        # format text going to user (model to view)
        ngModel.$formatters.push (value) ->
          if value
            return moment(value).format('h:mm a')
          return ''

        # format text from the user (view to model)
        ngModel.$parsers.push (value) ->
          if value
            [hour, minute] = guessTime(value)
            new_date = moment(scope.time).set('hour', hour).set('minute', minute)
            return new_date

          return scope.time

        element.on 'blur', (event) ->
          return unless scope.time and scope.time.isValid()

          # Update the time value to trigger the $formatter when leaving
          # the field
          if event.target.value not in moment(scope.time).format('h:mm a')
            $timeout ->
              scope.time = moment(scope.time)
