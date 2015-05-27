angular.module('examples', ['shift.components'])
  .directive 'testTransclude', ->
    restrict: 'E'
    template: '<div>blah <div> <ng-transclude></ng-transclude/><hr></div><ng-transclude></ng-transclude></div>'
    transclude: true

  .controller 'ExampleCtrl',
    (
      $scope
      $filter
    ) ->
      $scope.state = ''

      $scope.options = [
        {state: 'ca', city: 'Los Angeles', population: 3884307}
        {state: 'ca', city: 'San Diego', population: 1355896}
        {state: 'ca', city: 'San Jose', population: 998537}
        {state: 'ca', city: 'San Francisco', population: 837442}
        {state: 'ca', city: 'Fresno', population: 509924}
        {state: 'ca', city: 'Sacramento', population: 479686}
        {state: 'ny', city: 'New York', population: 8244910}
        {state: 'ny', city: 'Buffalo', population: 261025}
        {state: 'ny', city: 'Rochester', population: 210855}
        {state: 'ny', city: 'Yonkers', population: 197399}
        {state: 'ny', city: 'Syracuse', population: 145151}
        {state: 'ny', city: 'Albany', population: 97660}
      ]

      $scope.onSelect = (selected) ->
        console.debug 'Selected', selected

      $scope.onDiscard = (discarded) ->
        console.debug 'Discarded', discarded
