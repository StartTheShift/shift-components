angular.module('examples', ['shift.components'])
  .controller 'TimeCtrl', (
    $scope
  ) ->
    $scope.date = moment()

    # Regular Calendar example
    $scope.onDateChange = (date) ->
      console.log date

    $scope.setDateToNull = ->
      $scope.date = null

    $scope.setDateToNow = ->
      $scope.date = moment()

