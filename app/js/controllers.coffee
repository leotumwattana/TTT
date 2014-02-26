TTT = angular.module 'TTT', ['ngRoute']

TTT.config ['$routeProvider',
  ($routeProvider) ->
    $routeProvider.when('/', {
        templateUrl: 'partials/splash.html',
        controller: 'BoardController'
      }).when('/start', {
        templateUrl: 'partials/game-board.html',
        controller: 'BoardController'
      }).otherwise({ redirectTo: '/' })
]

TTT.controller 'BoardController', ['$scope',
  ($scope) ->

    # Symbols for pieces
    O = 'o'
    X = 'x'
    $scope.O = O
    $scope.X = X

    $scope.board = []
    $scope.fade = []

    init = ->
      $scope.turn = O
      $scope.gameOver = false
      $scope.gameOverMessage = ""
    init()

    $scope.resetBoard = ->
      $scope.board = []
      $scope.fade = []
      $scope.gameOver = false

    $scope.getSplashBoard = ->
      $scope.board = [ O, O, X,
                       O, X, "",
                       X, "", O]

    $scope.placePiece = (pos) ->

      # check if position is taken
      if $scope.board[pos] == undefined
        
        # place piece on board
        $scope.board[pos] = $scope.turn

        if (isWon() || isBoardFull())
          if isWon()
            $scope.gameOverMessage = $scope.turn.toUpperCase() + " WON!"
          else
            $scope.gameOverMessage = "It's a tie!"
          $scope.gameOver = true
        else
          swapTurn()
      else
        console.log "Position taken!"

    swapTurn = ->
      $scope.turn = if $scope.turn == O then X else O

    isWon = ->
      checkSets = [[0,1,2],[3,4,5],[6,7,8],
                   [0,3,6],[1,4,7],[2,5,8],
                   [0,4,8],[2,4,6]]

      win = false
      for set in checkSets
        console.log set
        a = $scope.board[set[0]]
        b = $scope.board[set[1]]
        c = $scope.board[set[2]]

        if a != undefined && a == b && b == c
          win = true
      win

    isBoardFull = ->
      $scope.board.filter (value) ->
        value != undefined
      .length == 9
]