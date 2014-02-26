TTT = angular.module 'TTT', ['ngRoute', 'firebase']

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

TTT.controller 'BoardController', ['$scope', '$firebase',
  ($scope, $firebase) ->

    # Symbols for pieces
    O = 'o'
    X = 'x'
    $scope.O = O
    $scope.X = X

    # Firebase
    gameRef = new Firebase "https://ttt-leo-tumwattana.firebaseIO.com/game"

    $scope.setupGame = ->
      $scope.game = {}
      $scope.game.board = {0:'',1:'',2:'',3:'',4:'',5:'',6:'',7:'',8:''}
      $scope.game.counter = 0
      $scope.game.gameOver = false
      $scope.game.gameOverMessage = ""
    $scope.setupGame()
    $firebase(gameRef).$bind($scope, 'game')

    $scope.resetBoard = ->
      $scope.setupGame()

    $scope.getSplashBoard = ->
      $scope.game.board = [ O, O, X,
                            O, X, "",
                            X, "", O ]

    $scope.placePiece = (pos) ->
      # check if position is taken
      if $scope.game.board[pos] == ''
        # place piece on board
        $scope.game.board[pos] = getMark()
        $scope.game.counter += 1
        if (isWon() || isBoardFull())
          if isWon()
            $scope.game.counter -= 1
            $scope.game.gameOverMessage = getMark().toUpperCase() + " WON!"
          else
            $scope.game.gameOverMessage = "It's a tie!"
          $scope.game.gameOver = true
      else
        console.log "Position taken!"

    getMark = (offset) ->
      offset ||= 0
      if (($scope.game.counter + offset) % 2 == 0) then O else X

    $scope.getMark = getMark

    isWon = ->
      checkSets = [[0,1,2],[3,4,5],[6,7,8],
                   [0,3,6],[1,4,7],[2,5,8],
                   [0,4,8],[2,4,6]]

      win = false
      for set in checkSets
        a = $scope.game.board[set[0]]
        b = $scope.game.board[set[1]]
        c = $scope.game.board[set[2]]

        if a != '' && a == b && b == c
          win = true
      win

    isBoardFull = ->
      $scope.game.counter == 9
]
