angular.module('examples', ['shift.components'])
  .controller 'SortableCtrl', ($scope) ->
    $scope.items = [
      'item 1'
      'item 2'
      'item 3'
      'item 4'
      'item 5'
      'item 6'
      'item 7'
      'item 8'
    ]

    $scope.onItemOrderChange = (elements) ->
      console.log 'change', elements
