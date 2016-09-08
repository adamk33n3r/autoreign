---
---

angular.module 'AutoReignApp'
.directive 'unitInput', () ->
  restrict: 'E'
  scope:
    ngModelText: '@ngModel'
    ngModel: '='
  replace: true
  template: '<div class="form-group">
               <label for="<% name %>"><% name | capitalize %></label>
               <input
                 class="form-control"
                 type="number"
                 min="0"
                 name="<% name %>"
                 ng-model="ngModel"
               />
             </div>
'
  link: ($scope) ->
    $scope.name = $scope.ngModelText.split('.').slice(-1)[0]
