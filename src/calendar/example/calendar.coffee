angular.module('examples', ['shift.components'])
  .controller 'CalendarCtrl', ($scope) ->
    $scope.date = moment().startOf 'day'

    min_date = moment().startOf('year').subtract(1, 'day')
    max_date = moment().endOf('year').add(1, 'day')

    $scope.onDateChange = (date) ->
      console.log date

    $scope.dateValidator = (date) ->
      return date.isBetween min_date, max_date, 'day'

    $scope.beginingOfYear = ->
      $scope.date = moment().startOf('year')

    $scope.endOfYear = ->
      $scope.date = moment().endOf('year')
