var TTT = angular.module('TTT', []);

TTT.controller('BoardController', ['$scope', function($scope) {
  $scope.board = ["o", "o", "x",
                    "o", "x", " ",
                    "x", " ", "o"];;

  $scope.newBoard = function() {
    $scope.board = [];
    console.log("What?");
  }

  $scope.getSplashBoard = function() {
    $scope.board = ["o", "o", "x",
                    "o", "x", " ",
                    "x", " ", "o"];
  }

  $scope.wha = function() {
    console.log("Wha?")
  }
}]);