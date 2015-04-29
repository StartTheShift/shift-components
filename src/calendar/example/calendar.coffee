angular.module('examples', ['shift.components'])
  .controller 'CalendarCtrl', ($scope) ->
    $scope.date = moment()
