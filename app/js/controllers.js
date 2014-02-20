function BoardController($scope) {

  $scope.board = [];

  function newBoard() {
    $scope.board = [];
  }

  function splashBoard() {
    $scope.board = ["o", "o", "x",
                    "o", "x", " ",
                    "x", " ", "o"];
  }
}