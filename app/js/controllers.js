var TTT = angular.module('TTT', []);

TTT.controller('BoardController', ['$scope', function($scope) {
  $scope.board = [];;

  $scope.newBoard = function() {
    $scope.board = [];
  }

  $scope.getSplashBoard = function() {
    $scope.board = ["o", "o", "x",
                    "o", "x", " ",
                    "x", " ", "o"];
  }

  $scope.placePiece = function(position) {
    console.log("Placing piece on: " + position)
    $scope.board[position] = "x"
  }
}]);