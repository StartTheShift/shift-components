angular.module 'shift.components.multiselect', []
  .directive 'shiftMultiselect',
    (
      $compile
    ) ->
      restrict: 'E'
      transclude: true

      scope:
        options: '='
        selected: '=?selected'
        onSelect: '&'
        onDeselect: '&'

      link: (scope, element, attrs, ctrl, transclude) ->
        scope.selected ?= []

        scope.selection_state_hash = {}

        shift_multiselect_initiated_change = null
        scope.onSelectionStateChange = (option, selected) ->
          shift_multiselect_initiated_change = true

          # Add to list of selected options when true
          if selected is true
            scope.selected.push option
            scope.onSelect?({option})

          # Remove from list of selected options when false
          else if selected is false
            index = scope.selected.indexOf option
            scope.selected.splice index, 1
            scope.onDeselect?({option})


          return

        do buildMultiselectElement = ->
          shift_select = angular.element document.createElement 'shift-select'
          shift_select.attr
            'options': 'options'

          # This is the multiselect template. Just a checkbox. You'll see a big
          # no-no below, that is, the deep reach back up the parent scopes.
          # ng-repeat, shift-select, shift-multiselect..
          shift_select.append '''
            <div class="checkbox-option" ng-init="shift_ms_scope = $parent.$parent.$parent">
              <input
                id="shift_multiselect_option_{{$index}}"
                ng-model="shift_ms_scope.selection_state_hash[option.value]"
                ng-change="shift_ms_scope.onSelectionStateChange(option, shift_ms_scope.selection_state_hash[option.value])"
                type="checkbox"
              />
            </div>
          '''

          # Inject transcluded elements into shift-select
          transclude scope, (copy) ->
            option_container = shift_select.find 'div'
            option_container.append copy

          # Compile and append to shift-multiselect element
          element.append $compile(shift_select)(scope.$new())

        # Set selection state
        scope.$watch ->
          return scope.selected.length
        , (new_value, old_value) ->
          return if not new_value? or new_value is old_value

          # Don't proceed if the change was made from this directive
          if shift_multiselect_initiated_change is true
            shift_multiselect_initiated_change = false
            return

          # Rebuild the selection state on progrommatic changes to scope.selected
          scope.selection_state_hash = {}
          _.each scope.selected, (selected_option, index) ->
            option = _.find scope.options, {value: selected_option.value}
            scope.selection_state_hash[selected_option.value] = true

        , true

        return