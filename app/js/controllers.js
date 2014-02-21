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
    $scope.board[position] = $scope.turn;
    swapTurn();
    console.log("win? " + checkWin());
  }

  swapTurn = function() {
    if ($scope.turn === "o") {
      $scope.turn = "x";
    } else {
      $scope.turn = "o";
    }
  }

  checkWin = function() {
    checkSets = [[0,1,2],[3,4,5],[6,7,8],
                 [0,3,6],[1,4,7],[2,5,8],
                 [0,4,8],[2,4,6]];

    win = false;
    checkSets.forEach(function(positions) {
      a = $scope.board[positions[0]];
      b = $scope.board[positions[1]];
      c = $scope.board[positions[2]];

      if (a === b && b === c && a != null) {
        win = true;
      }
    });
    return win;
  }

}]);