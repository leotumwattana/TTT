O = 'o'
X = 'x'

@ttt = angular.module 'TTT', ['ngRoute', 'firebase']

ttt.config ['$routeProvider',
  ($routeProvider) ->
    $routeProvider.when('/', {
        templateUrl: 'partials/splash.html',
        controller: 'SplashController'
      }).when('/start', {
        templateUrl: 'partials/game-board.html',
        controller: 'BoardController'
      }).otherwise({ redirectTo: '/' })
]

ttt.controller 'SplashController', ['$scope', ($scope) ->
  $scope.O = O
  $scope.X = X
]

ttt.controller 'BoardController', ['$scope', '$firebase',
  ($scope, $firebase) ->

    appRef = new Firebase "https://ttt-leo-tumwattana.firebaseIO.com"
    gamesRef = appRef.child "games"
    openGamesRef = appRef.child "openGames"

    # Helper to generate random name
    generateName = ->
      gamesRef.push().name()

    playerId = generateName()

    # creates new game in firebase and returns game id
    createGame = (gameId) ->

      gameRef = gamesRef.child gameId

      # If game is already bound then unbind it
      $scope.unbind() if $scope.unbind

      # Create game object
      $scope.game = {}
      $scope.game.board = {0:'',1:'',2:'',3:'',4:'',5:'',6:'',7:'',8:''}
      $scope.game.player1 = playerId
      $scope.game.player2 = null
      $scope.game.counter = 0
      $scope.game.gameOver = false
      $scope.game.won = false
      $scope.game.tie = false

      # if player disconnects
      player1Ref = gameRef.child "player1"
      player1Ref.onDisconnect().set 'disconnected'

      # Bind game object to Firebase
      $firebase(gameRef).$bind($scope, 'game').then (unbind) ->
        $scope.unbind = unbind

    # binds game object with firebase
    bindGame = (gameId) ->
      $scope.unbind() if $scope.unbind
      gameRef = gamesRef.child gameId
      $firebase(gameRef)
      .$bind($scope, 'game').then (unbind) ->
        $scope.unbind = unbind
      gameId

    joinGame = (gameId) ->
      player2Ref = gamesRef.child "#{gameId}/player2"
      player2Ref.set playerId
      player2Ref.onDisconnect().set 'disconnected'
      bindGame gameId

    $scope.opponentDisconnected = ->
      game = $scope.game || {}
      game.player1 == 'disconnected' || game.player2 == 'disconnected'

    $scope.leaveGame = ->
      location.href = "/"

    startGame = ->
      openGamesRef.transaction (gameId) ->
        if gameId
          $scope.gameId = gameId
          null
        else
          'game' + generateName()
      , (error, committed, snapshot) ->
        if committed && !error
          gameId = snapshot.val()
          if gameId
            # create game
            createGame gameId
          else
            # joining game
            joinGame $scope.gameId
        else
          console.log "There was an error starting game: #{error}"
    startGame()

    cleanOldGames = ->
      gamesRef.once 'value', (games) ->
        games.forEach (game) ->
          gameVal = game.val()
          if gameVal.player1 == "disconnected" && gameVal.player2 == "disconnected"
            gameRef = game.ref()
            gameRef.remove()
    cleanOldGames()

    isGameOn = ->
      if $scope.game
        $scope.game.player2? && !$scope.game.gameOver && $scope.unbind
      else
        false

    $scope.isFindingOpponent = ->
      if $scope.game then !$scope.game.player2? else true

    resetGame = ->
      $scope.game.board = {0:'',1:'',2:'',3:'',4:'',5:'',6:'',7:'',8:''}
      $scope.game.counter = 0
      $scope.game.gameOver = false
      $scope.game.won = false
      $scope.game.tie = false

    getTurnId = (offset) ->
      game = $scope.game || {}
      if getMark(offset) == O then game.player1 else game.player2

    $scope.placePiece = (pos) ->
      if playerId == getTurnId() && isGameOn()
        # check if position is taken
        if $scope.game.board[pos] == ''
          # place piece on board
          $scope.game.board[pos] = getMark()
          $scope.game.counter += 1
          if (isWon() || isBoardFull())
            if isWon()
              $scope.game.counter -= 1
              $scope.game.won = true
            else
              $scope.game.tie = true
            $scope.game.gameOver = true
        else
          console.log "Position taken!"

    $scope.getGameOverMessage = ->
      if getTurnId() == playerId then "You WON!" else "You Lost."

    getMark = (offset) ->
      offset ||= 0
      game = $scope.game || {}
      counter = game.counter || 0
      if (counter + offset) % 2 == 0 then O else X

    getTurnMessage = ->
      if playerId == getTurnId() then "Your turn!" else "Opponent's turn"

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

    $scope.O = O
    $scope.X = X
    $scope.getMark = getMark
    $scope.resetGame = resetGame
    $scope.getTurnMessage = getTurnMessage
    $scope.isGameOn = isGameOn
]