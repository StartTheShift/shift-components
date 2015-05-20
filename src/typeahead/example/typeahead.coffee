angular.module('examples', ['shift.components'])

  .controller 'ExampleCtrl',
    (
      $scope
    ) ->
      $scope.state = ''
      $scope.states = ['', 'ca', 'ny']

      $scope.selected_state = null
      $scope.selected_states = []

      $scope.sources = [
        {state: 'ca', city: 'Los Angeles', population: 3884307, value: 'los_angeles'}
        {state: 'ca', city: 'San Diego', population: 1355896, value: 'san_diego'}
        {state: 'ca', city: 'San Jose', population: 998537, value: 'san_jose'}
        {state: 'ca', city: 'San Francisco', population: 837442, value: 'san_francisco'}
        {state: 'ca', city: 'Fresno', population: 509924, value: 'fresno'}
        {state: 'ca', city: 'Sacramento', population: 479686, value: 'sacramento'}
        {state: 'ny', city: 'New York', population: 8244910, value: 'new_york'}
        {state: 'ny', city: 'Buffalo', population: 261025, value: 'buffalo'}
        {state: 'ny', city: 'Rochester', population: 210855, value: 'rochester'}
        {state: 'ny', city: 'Yonkers', population: 197399, value: 'yonkers'}
        {state: 'ny', city: 'Syracuse', population: 145151, value: 'syracuse'}
        {state: 'ny', city: 'Albany', population: 97660, value: 'albany'}
      ]

      $scope.getClass = (option) ->
        return {
          checked: option in $scope.selected_states
        }
