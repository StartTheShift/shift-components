angular.module('examples', ['shift.components'])

  .directive 'myTypeahead', [
    '$compile'
    (
      $compile
    ) ->
      restrict: 'E'
      transclude: true

      template: '''
        <input ng-model="query"
          ng-focus = "show_select_menu = true"
          ng-blur = "hide($event)"
          type="text"/>
      '''

      scope:
        options: '='
        filter: '='
        filter_attribute: '@filterAttribute'
        selected: '='

      link: (scope, element, attrs, ctrl, transclude) ->

        do attachSelectMenu = ->
          shift_select = angular.element document.createElement 'shift-select'
          shift_select.attr
            'ng-show': 'show_select_menu'
            'options': 'options'
            'filter': 'query'
            'selected': 'selected'
            'on-select': 'onSelect(selected)'
            'ng-mousedown': 'mouseDown(true)'
            'ng-mouseup': 'mouseDown(false)'

          # Create a new scope to transclude + compile the template with (we don't
          # want the child directives directly modifying the scope of myTypeahead)
          shift_select_scope = scope.$new()

          # Attach the transcluded template to shift-select
          transclude shift_select_scope, (clone) ->
            shift_select.append clone

          # Finally, add shift-select to the myTypeahead element
          element.append shift_select

          $compile(shift_select) shift_select_scope

        scope.show_select_menu = false
        mouse_down = false

        scope.mouseDown = (down) ->
          mouse_down = down

        scope.hide = ($event) ->
          unless mouse_down
            scope.show_select_menu = false

        scope.onSelect = (selected) ->
          scope.selected = selected
          scope.query = selected?[scope.filter_attribute]

        scope.$watch 'query', (new_value, old_value) ->
          return if new_value is old_value
          scope.selected = null if scope.query isnt scope.selected?[scope.filter_attribute]
      ]

  .controller 'ExampleCtrl',
    (
      $scope
    ) ->
      $scope.state = ''
      $scope.states = ['', 'ca', 'ny']

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
