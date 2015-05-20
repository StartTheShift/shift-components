angular.module('examples', ['shift.components'])

  .controller 'ExampleCtrl',
    (
      $scope
      $filter
    ) ->
      $scope.state = ''
      $scope.options = []

      $scope.states = [
        ['All states', '']
        ['California', 'ca']
        ['New York', 'ny']
      ]

      $scope.sources = [
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

      $scope.toggleSelect = (state) ->
        $scope.show_select = state

      $scope.toggleSelectMultiple = (state) ->
        $scope.show_select_multiple = state

      do filterOptions = ->
        if $scope.state
          $scope.options = $filter('filter')($scope.sources, {state: $scope.state})
        else
          $scope.options = $scope.sources

      $scope.$watch 'state', (new_value, old_value) ->
        return if new_value is old_value
        filterOptions()

      window.addEventListener 'mouseup', ->
        $scope.$apply ->
          $scope.show_select = false;
          $scope.show_select_multiple = false;

      window.addEventListener 'keyup', (event) ->
        if event.which is 27 # ESC key

          $scope.$apply ->
            $scope.show_select = false;
            $scope.show_select_multiple = false;
