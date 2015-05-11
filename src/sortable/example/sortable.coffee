angular.module('examples', ['shift.components'])
  .controller 'SortableCtrl', ($scope) ->
    $scope.items = [
      'Tokyo'
      'Jakarta'
      'Seoul'
      'Delhi'
      'Shanghai'
      'Manila'
      'Karachi'
      'New York'
      'Sao Paulo'
      'Mexico City'
    ]

    $scope.items_visited = ['Paris', 'Los Angeles']
    $scope.items_to_visit = []

    $scope.onItemOrderChange = (elements) ->
      console.log 'change', elements
