angular.module('examples', ['shift.components'])
  .run ($templateCache) ->
    template_content = '''
      <shift-calendar ng-model="foo.date" class="naked range-calendar" />
    '''
    $templateCache.put('calendar_template.html', template_content);

  .controller 'CalendarCtrl', ($scope) ->
    min_date = moment().startOf('year').subtract(1, 'day')
    max_date = moment().endOf('year').add(1, 'day')

    $scope.foo = {date: moment().add(4, 'day')}

    # Regular Calendar example
    $scope.onDateChange = (date) ->
      console.log date

    $scope.dateValidator = (date) ->
      return date.isBetween min_date, max_date, 'day'

    $scope.today = ->
      $scope.date = moment()

    $scope.nullDate = ->
      $scope.date = null

    $scope.beginingOfYear = ->
      $scope.date = moment().startOf('year')

    $scope.endOfQuarter = ->
      $scope.date = moment().endOf('quarter')

    # Calendar Range example
    $scope.start_date = moment().startOf 'week'
    $scope.stop_date = moment().endOf 'week'

    $scope.startDateChange = (date) ->
      if date.isAfter $scope.stop_date
        $scope.stop_date = moment(date)

    $scope.stopDateChange = (date) ->
      if date.isBefore $scope.start_date
        $scope.start_date = moment(date)

    $scope.isDateInRange = (date) ->
      return true if date.isSame $scope.start_date, 'day'
      return true if date.isSame $scope.stop_date, 'day'

      return date.isBetween $scope.start_date, $scope.stop_date, 'day'

    $scope.last90Days = ->
      $scope.stop_date = moment().startOf 'day'
      $scope.start_date = moment($scope.stop_date).subtract(90, 'day')

    $scope.lastWeek = ->
      $scope.stop_date = moment().startOf 'week'
      $scope.start_date = moment($scope.stop_date).subtract(1, 'week')

    $scope.outOfRangeDate = ->
      $scope.stop_date = moment(min_date).subtract(1, 'week')
      $scope.start_date = moment(min_date).subtract(3, 'week')

