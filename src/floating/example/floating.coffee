angular.module('examples', ['shift.components'])
  .controller 'FloatingCtrl', ($scope) ->
    $scope.foo =
      bar: 'custom value'
