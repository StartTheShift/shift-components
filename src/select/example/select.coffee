angular.module('examples', ['shift.components'])
  .directive 'myTypeahead', ->
    restrict: 'E'

    template: '''
      <input ng-model="query" type="text"/>
      <shift-select
        ng-show = "show_select_menu"
        options = "options"
        filter = "query"
        selected = "selected"
        on-select = "onSelect(selected)"
        template = "{{template}}"
       />
    '''

    scope:
      options: '='
      filter: '='
      filter_attribute: '@filterAttribute'
      option_template: '@optionTemplate'

    link: (scope, element, attrs) ->
      scope.show_select_menu = false

      do listen = ->
        input = angular.element element.find 'input'
        input.bind 'focus', ->
          scope.show_select_menu = true
          scope.$digest()

        input.bind 'blur', ->
          scope.show_select_menu = false
          scope.$digest()

        input.bind 'keyup', (event) ->
          char = String.fromCharCode event.which or event.keyCode

          return unless /[a-zA-Z0-9-_ ]/.test char

          scope.show_select_menu = true
          scope.$digest()

      query_object = {}
      query_string = ''
      Object.defineProperty scope, 'query',
        get: ->
          return query_object[scope.filter_attribute] if scope.filter_attribute?
          return query_string

        set: (value) ->
          if scope.filter_attribute?
            query_object[scope.filter_attribute] = value[scope.filter_attribute] or value

          else query_string = value

      scope.onSelect = (value) ->
        scope.query = value
        scope.show_select_menu = false
        scope.$digest()

      scope.$on '$destroy', -> input.off()

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
