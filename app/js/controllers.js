var TTT = angular.module('TTT', []);

TTT.controller('BoardController', ['$scope', function($scope) {
  $scope.board = [];;

  init = function() {
    $scope.turn = "o";
  }
  init();

  $scope.newBoard = function() {
    $scope.board = [];
  }

  $scope.getSplashBoard = function() {
    $scope.board = ["o", "o", "x",
                    "o", "x", " ",
                    "x", " ", "o"];
  }

  $scope.placePiece = function(position) {
    console.log("Placing piece on: " + position);
    $scope.board[position] = $scope.turn;
    swapTurn();
  }

  swapTurn = function() {
    if ($scope.turn == "o") {
      $scope.turn = "x";
    } else {
      $scope.turn = "o";
    }
  }

}]);