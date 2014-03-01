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
    gameId = ''
    gameRef = ''

    # creates new game in firebase and returns game id
    createGame = ->

      gameId = 'game' + generateName()
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
      $scope.game.gameOverMessage = ""

      # Bind game object to Firebase
      $firebase(gameRef).$bind($scope, 'game').then (unbind) ->
        $scope.unbind = unbind

      gameId

    # lists a game as available in firebase
    listAsOpenGame = (gameId) ->
      $firebase(openGamesRef).$add(gameId).then (ref) ->
        $scope.openGameId = ref.name()

    # creates and list game as open
    $scope.createAndListGame = ->
      gameId = createGame()
      listAsOpenGame gameId

    unlistOpenGame = (openGameId) ->
      $firebase(openGamesRef).$remove(openGameId)

    # read in list of open game ids
    getOpenGames = (onComplete) ->
      openGamesRef.once 'value', (snapshot) ->
        openGameIds = []
        for key, gameId of snapshot.val()
          openGameIds.push [key, gameId]
        onComplete(openGameIds)

    # binds game object with firebase
    bindGame = (gid) ->

      # unbind the game object if it was already bound
      $scope.unbind() if $scope.unbind
      gameId = gid
      gameRef = gamesRef.child gid
      $firebase(gameRef).$bind($scope, 'game').then (unbind) ->
        $scope.unbind = unbind
      gid

    @joinGame = (gameId, options) ->
      options ||= {}

      url = "https://ttt-leo-tumwattana.firebaseIO.com/games/#{gameId}/player2"
      player2Ref = new Firebase url
      
      player2Ref.transaction (player2) ->
        if !player2
          player2 = playerId
        else
          return
      , (error, committed, snapshot) ->
        if committed && !error
          # bind game object
          options.onSuccess() if options.onSuccess
        else
          if error
            options.onError() if options.onError
          if !committed
            options.onGameFull() if options.onGameFull

    joinOrCreateOpenGame = =>
      getOpenGames (openGameIds) =>

        tryToJoinOpenGame = =>
          pair = openGameIds.shift()
          if pair
            openGameKey = pair[0]
            gameId = pair[1]
            console.log "Trying to join game: #{gameId}"
            @joinGame gameId,
              onGameFull: ->
                console.log "Game is full: #{gameId}"
                tryToJoinOpenGame()
              onSuccess: ->
                console.log "Joined game: #{gameId}"
                bindGame gameId
                console.log "Unlisting game: #{gameId}"
                unlistOpenGame openGameKey
          else
            console.log "No more open games to join..."
            console.log "Creating a game..."
            $scope.createAndListGame()
        tryToJoinOpenGame()

    joinOrCreateOpenGame()

    # ------------------------

    resetGame = ->
      $scope.game.board = {0:'',1:'',2:'',3:'',4:'',5:'',6:'',7:'',8:''}
      $scope.game.counter = 0
      $scope.game.gameOver = false
      $scope.game.gameOverMessage = ""

    $scope.placePiece = (pos) ->
      # if playerId == getTurnId()
        # check if position is taken
        if $scope.game.board[pos] == ''
          # place piece on board
          $scope.game.board[pos] = getMark()
          $scope.game.counter += 1
          if (isWon() || isBoardFull())
            if isWon()
              $scope.game.counter -= 1
              message = if getTurnId() == playerId then "You WON!" else "You Lost."
              $scope.game.gameOverMessage = message
            else
              $scope.game.gameOverMessage = "It's a tie!"
            $scope.game.gameOver = true
        else
          console.log "Position taken!"

    getMark = (offset) ->
      offset ||= 0
      if (($scope.game.counter + offset) % 2 == 0) then O else X

    getTurnId = (offset) ->
      if getMark(offset) == O then $scope.game.player1 else $scope.game.player2

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
]
