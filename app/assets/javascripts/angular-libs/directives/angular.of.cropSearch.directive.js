openFarmApp.directive('cropSearch', ['$http', 'cropService',
  function cropSearch($http, cropService) {
    return {
      restrict: 'A',
      scope: {
        cropSearchFunction: '=',
        cropOnSelect: '=',
        clearCropSelection: '=',
        focusOn: '=',
        loadingVariable: '=',
        loadingCropsText: '=',
        options: '=',
        allowNew: '=',
        query: '=',
        doesNotHaveButton: '=',
      },
      controller: ['$scope', '$element', '$attrs',
        function ($scope, $element, $attrs) {
          $scope.placeholder = $attrs.placeholder || 'Search crops';
          $scope.buttonValue = $attrs.buttonValue || 'Submit';
          $scope.cropQuery = undefined;

          $scope.firstCrop = undefined;
          //Typeahead search for crops
          $scope.getCrops = function (val) {
            // be nice and only hit the server if
            // length >= 3
            return $http.get('/api/v1/crops', {
              params: {
                filter: val
              }
            }).then(function(res) {
              console.log(res);
              var crops = [];
              crops = res.data.data;
              if (crops.length === 0 && $scope.allowNew) {
                crops.push({ attributes: {
                  name: val,
                  is_new: true
                } });
              }
              crops = crops.map(function(crop) {
                return cropService.utilities.buildCrop(crop, res.data.included);
              });
              $scope.firstCrop = crops[0];
              return crops;
            });
          };

          $scope.submitCrop = function() {
            if ($scope.firstCrop !== undefined) {
              $scope.cropOnSelect($scope.firstCrop);
            } else {
              $scope.cropOnSelect($scope.cropQuery);
            }
          };
        }
      ],
      templateUrl: '/assets/templates/_crop_search.html',
    };
}]);
