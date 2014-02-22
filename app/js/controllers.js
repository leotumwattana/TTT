var TTT = angular.module('TTT', []);

TTT.controller('BoardController', ['$scope', function($scope) {

  // Symbols for pieces
  var O = "o";
  var X = "x";

  $scope.board = [];

  var init = function() {
    $scope.turn = O;
    $scope.gameOver = false;
    $scope.gameOverMessage = "";
  }
  init();

  $scope.resetBoard = function() {
    $scope.board = [];
    $scope.gameOver = false;
  }

  $scope.getSplashBoard = function() {
    $scope.board = [O, O, X,
                    O, X, " ",
                    X, " ", O];
  }

  $scope.placePiece = function(position) {

    // check if position is take
    if ($scope.board[position] == null) {

      $scope.board[position] = $scope.turn;

      if (isWon() || isBoardFull()) {
        if (isWon()) {
          $scope.gameOverMessage = $scope.turn.toUpperCase() + " WON!";
        } else {
          $scope.gameOverMessage = "It's a tie!";
        }
        $scope.gameOver = true;
      } else {
        swapTurn();
      }

    } else {
      console.log("Position taken!");
    }
  }

  var swapTurn = function() {
    $scope.turn = ($scope.turn === O) ? X : O;
  }

  var isWon = function() {
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

  var isBoardFull = function() {
    return $scope.board.filter(function(value){
      return value !== undefined;
    }).length === 9;
  }
}]);

  