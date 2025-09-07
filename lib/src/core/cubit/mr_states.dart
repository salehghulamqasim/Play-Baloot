/*
! has data structure (what information your app holds)
  define current snapshot of your app
  example player name, score , room code

*/

class MrState {
  final String roomCode;
  final String playerName;
  final int team1Score;
  final int team2Score;
  final List<String> team1Players;
  final List<String> team2Players;
  final bool isGameStarted;
  final int secondsElapsed;
  final int targetScore;
  final bool roundEnded;
  final bool isConnected; //  field for connection status
  final String gameId; // field for Firebase document ID
  final int timeMinutes; // Total time in minutes
  final int remainingSeconds; // Remaining time in seconds
  final bool timerStarted; // Whether timer has started
  // Join dialog state
  final String joinRoomCode; // Room code being entered
  final bool canJoin; // Whether join button should be enabled
  final bool isAdmin;
  final bool isCreatingRoom;
  final bool hasRoomBeenCreated;

  //Constrcutor -sets default values
  const MrState({
    this.roomCode = "",
    this.playerName = "",
    this.team1Score = 0,
    this.team2Score = 0,
    this.team1Players = const ["", ""],
    this.team2Players = const ["", ""],
    this.isGameStarted = false,
    this.secondsElapsed = 0,
    this.targetScore = 0,
    this.roundEnded = false, //by default false
    this.isConnected = false, //This tells you if you're connected to Firebase
    this.gameId =
        "", //this stores the firbase documetnation id for our game room
    this.timeMinutes = 30,
    this.remainingSeconds = 1800,
    this.timerStarted = false,
    this.joinRoomCode = "",
    this.canJoin = false,
    this.isAdmin = false,
    this.isCreatingRoom = false,
    this.hasRoomBeenCreated = false,
  });

  //2. Copywith -creates new state with some values changed. lets u only change what u need
  MrState copyWith({
    // the sign "?" means the value can be null. its null safety
    String? roomCode,
    String? playerName,
    int? team1Score,
    int? team2Score,
    List<String>? team1Players,
    List<String>? team2Players,
    bool? isGameStarted,
    int? secondsElapsed,
    int? targetScore,
    bool? roundEnded,
    bool? isConnected,
    String? gameId,
    int? timeMinutes,
    int? remainingSeconds,
    bool? timerStarted,
    String? joinRoomCode,
    bool? canJoin,
    bool? isAdmin,
    bool? isCreatingRoom,
    bool? hasRoomBeenCreated,
  }) {
    //return these data. for room if
    return MrState(
      // * The ?? operator means "if null, then use this instead
      roomCode: roomCode ?? this.roomCode,
      //If roomCode parameter is NOT null → use the new roomCode
      //If roomCode parameter IS null → use the current this.roomCode
      playerName: playerName ?? this.playerName, //newValue ?? oldValue
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      team1Players: team1Players ?? this.team1Players,
      team2Players: team2Players ?? this.team2Players,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      targetScore: targetScore ?? this.targetScore,
      roundEnded: roundEnded ?? this.roundEnded,
      isConnected: isConnected ?? this.isConnected,
      gameId: gameId ?? this.gameId,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timerStarted: timerStarted ?? this.timerStarted,
      joinRoomCode: joinRoomCode ?? this.joinRoomCode,
      canJoin: canJoin ?? this.canJoin,
      isAdmin: isAdmin ?? this.isAdmin,
      isCreatingRoom: isCreatingRoom ?? this.isCreatingRoom,
      hasRoomBeenCreated: hasRoomBeenCreated ?? this.hasRoomBeenCreated,
    );
  }
}
