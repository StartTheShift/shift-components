angular.module('examples', ['shift.components'])
  .run ($templateCache) ->
    template_content = '''
      <form>
       <label> {{ foo.bar }} </label>
       <input
         type="text"
         ng-model = "foo.bar"
        placeholder = "Should display foo.bar value">
      </form>
    '''
    $templateCache.put('form_template.html', template_content);



  .controller 'PopoverCtrl', ($scope) ->
    $scope.foo =
      bar: "bar"
