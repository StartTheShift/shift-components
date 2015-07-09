angular.module('examples', ['shift.components'])
  .controller 'TimeCtrl', (
    $scope
  ) ->

    $scope.date = moment()
    min_date = moment().startOf('day').add(2, 'hour')
    max_date = moment().startOf('day').add(22, 'hour')

    # Regular Calendar example
    $scope.onDateChange = (date) ->
      console.log date

    $scope.setDateToNull = ->
      $scope.date = null

    $scope.setDateToNow = ->
      $scope.date = moment()

    $scope.dateValidator = (date) ->
      return true
      return date.isBetween min_date, max_date

