import 'dart:core';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playbaloot/data/room.repo.dart';
import 'package:playbaloot/src/core/cubit/mr_states.dart';

class MrCubit extends Cubit<MrState> {
  MrCubit() : super(const MrState());

  // Generate 7-digit room code
  void generateRoomCode() {
    final random = Random();
    final newCode = (1000000 + random.nextInt(9000000)).toString();
    emit(state.copyWith(roomCode: newCode));
  }

  // Create a new room
  Future<bool> createRoom({
    required int target,
    required List<String> team1,
    required List<String> team2,
    required int timeMinutes,
  }) async {
    try {
      // Always generate a fresh room code for a new room creation to avoid
      // reusing an old roomCode in local state.
      generateRoomCode();
      final code = state.roomCode;

      // team player lists are stored by RoomRepo; no local map needed here.

      emit(state.copyWith(isCreatingRoom: true));

      final repo = RoomRepo();
      await repo.createRoom(
        code: code,
        target: target,
        t1: team1,
        t2: team2,
        timeMinutes: timeMinutes,
      );

      emit(
        state.copyWith(
          isAdmin: true,
          targetScore: target,
          team1Players: team1,
          team2Players: team2,
          isCreatingRoom: false,
          hasRoomBeenCreated: true,
          roomCode: code,
        ),
      );

      return true;
    } catch (e) {
      emit(state.copyWith(isCreatingRoom: false));
      return false;
    }
  }

  // Add round score
  Future<void> addRoundScoreRemote(int t1, int t2) async {
    if (state.roomCode.isEmpty) return;
    final ref = FirebaseDatabase.instance.ref('rooms/${state.roomCode}');
    await ref.update({
      'team1Score': ServerValue.increment(t1),
      'team2Score': ServerValue.increment(t2),
    });
    addRoundScore(t1, t2);
  }

  void addRoundScore(int a, int b) {
    emit(
      state.copyWith(
        team1Score: state.team1Score + a,
        team2Score: state.team2Score + b,
      ),
    );
    checkRoundEnded();
  }

  void checkRoundEnded() {
    final ended =
        state.team1Score >= state.targetScore ||
        state.team2Score >= state.targetScore;
    emit(state.copyWith(roundEnded: ended));
  }

  void setTargetScore(int v) => emit(state.copyWith(targetScore: v));

  void resetGame() => emit(
    state.copyWith(
      team1Score: 0,
      team2Score: 0,
      targetScore: 0,
      roundEnded: false,
    ),
  );

  // Finish current game (mark as finished in Firebase)
  Future<void> finishGame() async {
    if (!state.isAdmin || state.roomCode.isEmpty) return;

    try {
      await FirebaseDatabase.instance.ref('rooms/${state.roomCode}').update({
        'status': 'finished',
      });
    } catch (e) {
      print("Failed to mark room as finished: $e");
    } finally {
      // Reset local state but keep defaults; ensure roomCode cleared
      emit(MrState());
    }
  }

  // Start a new game with a fresh room code
  Future<void> finishGameWithNewCode() async {
    if (!state.isAdmin) return;

    try {
      // Mark old room as finished
      if (state.roomCode.isNotEmpty) {
        await FirebaseDatabase.instance.ref('rooms/${state.roomCode}').update({
          'status': 'finished',
        });
      }

      // Generate new room
      final newCode = (1000000 + Random().nextInt(9000000)).toString();

      // Create new room in Firebase
      await RoomRepo().createRoom(
        code: newCode,
        target: 152,
        t1: [],
        t2: [],
        timeMinutes: 30,
      );

      // Update local state
      emit(
        MrState().copyWith(
          roomCode: newCode,
          isAdmin: true,
          playerName: state.playerName,
          targetScore: 152,
        ),
      );
    } catch (e) {
      emit(MrState()); // Fallback
    }
  }

  // Timer control
  void startTimer() async {
    if (state.roomCode.isEmpty) return;
    await FirebaseDatabase.instance.ref('rooms/${state.roomCode}').update({
      'timerStarted': true,
      'timerStartTime': ServerValue.timestamp,
    });
    emit(state.copyWith(timerStarted: true));
  }

  void updateTimerFromServer(int remainingSeconds) {
    emit(state.copyWith(remainingSeconds: remainingSeconds));
  }

  // Join room logic
  void updateJoinRoomCode(String code) {
    emit(state.copyWith(joinRoomCode: code, canJoin: code.trim().isNotEmpty));
  }

  void resetJoinDialog() {
    emit(state.copyWith(joinRoomCode: "", canJoin: false));
  }

  // Join room logic with role differentiation
  Future<bool> joinRoom(
    String roomCode,
    String playerName, {
    String role = 'player',
  }) async {
    final ref = FirebaseDatabase.instance.ref('rooms/$roomCode');
    try {
      final snapshot = await ref.get();
      print(
        "🔍 joinRoom: Checking room '$roomCode', exists: ${snapshot.exists}",
      );

      if (!snapshot.exists) {
        print("❌ Room does not exist");
        return false;
      }

      final dynamic rawData = snapshot.value;

      if (rawData is! Map) {
        print(
          "🚨 Invalid room data type: ${rawData.runtimeType}. Expected Map, got List or null.",
        );
        return false;
      }

      final data = (rawData).cast<String, dynamic>();

      if (role == 'viewer') {
        // Add viewer to the viewers list
        final viewersRef = ref.child('viewers');
        await viewersRef.push().set(playerName);
        emit(
          state.copyWith(
            roomCode: roomCode,
            playerName: playerName,
            isAdmin: false,
          ),
        );
        print("👀 Viewer joined room: $roomCode");
        return true;
      }

      // Existing player join logic
      final team1Players = _parseTeamPlayers(data['team1Players']);
      final team2Players = _parseTeamPlayers(data['team2Players']);
      final targetScore = (data['targetScore'] as num?)?.toInt() ?? 0;
      final team1Score = (data['team1Score'] as num?)?.toInt() ?? 0;
      final team2Score = (data['team2Score'] as num?)?.toInt() ?? 0;

      emit(
        state.copyWith(
          roomCode: roomCode,
          playerName: playerName,
          isAdmin: false,
          team1Players: team1Players,
          team2Players: team2Players,
          targetScore: targetScore,
          team1Score: team1Score,
          team2Score: team2Score,
        ),
      );

      print("✅ Successfully joined room: $roomCode");
      return true;
    } catch (e, stack) {
      print("❌ joinRoom failed: $e");
      print(stack);
      return false;
    }
  }

  // Remove viewer from the room
  Future<void> removeViewer(String roomCode, String playerName) async {
    final ref = FirebaseDatabase.instance.ref('rooms/$roomCode/viewers');
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        final viewers = (snapshot.value as Map).cast<String, dynamic>();
        final viewerEntry = viewers.entries.firstWhere(
          (entry) => entry.value == playerName,
          orElse: () => const MapEntry('', ''),
        );

        if (viewerEntry.key.isNotEmpty) {
          await ref.child(viewerEntry.key).remove();
          print("👋 Viewer $playerName removed from room $roomCode");
        }
      }
    } catch (e) {
      print("❌ Failed to remove viewer: $e");
    }
  }

  List<String> _parseTeamPlayers(dynamic teamData) {
    if (teamData == null) return ['', ''];

    if (teamData is List) {
      return teamData
          .map((e) => (e ?? '').toString())
          .toList()
          .take(2)
          .toList();
    }

    if (teamData is Map) {
      final players = List<String>.filled(2, '');
      teamData.forEach((key, value) {
        final index = int.tryParse(key.toString()) ?? -1;
        if (index >= 0 && index < 2) {
          players[index] = (value ?? '').toString();
        }
      });
      return players;
    }

    return ['', ''];
  }

  // Assign player to team
  Future<String?> assignPlayerToTeam({
    required String name,
    required int team,
  }) async {
    if (state.roomCode.isEmpty) return 'No room';
    final code = state.roomCode;
    final teamKey = team == 1 ? 'team1Players' : 'team2Players';
    final ref = FirebaseDatabase.instance.ref('rooms/$code/$teamKey');

    try {
      final txResult = await ref.runTransaction((dynamic mutableData) {
        if (mutableData == null) return Transaction.abort();
        final md = mutableData;
        Map current = (md.value as Map?)?.cast<String, dynamic>() ?? {};

        // Find first free slot
        for (int i = 0; i < 2; i++) {
          final key = '$i';
          if (!current.containsKey(key) ||
              (current[key]?.toString().trim().isEmpty ?? true)) {
            current[key] = name;
            md.value = current;
            return Transaction.success(md);
          }
        }

        return Transaction.abort();
      });

      if (txResult.committed != true) return 'Team is full';

      // Refresh players from committed snapshot
      final snap = await ref.get();
      final players = <String>[];
      if (snap.value is Map) {
        final map = (snap.value as Map).cast<String, dynamic>();
        // ensure order 0,1
        for (int i = 0; i < 2; i++) {
          players.add((map['$i'] ?? '').toString());
        }
      }

      final t1 = List<String>.from(state.team1Players);
      final t2 = List<String>.from(state.team2Players);
      if (team == 1) {
        while (t1.length < players.length) {
          t1.add('');
        }
        for (int i = 0; i < players.length && i < t1.length; i++) {
          t1[i] = players[i];
        }
        emit(state.copyWith(team1Players: t1));
      } else {
        while (t2.length < players.length) {
          t2.add('');
        }
        for (int i = 0; i < players.length && i < t2.length; i++) {
          t2[i] = players[i];
        }
        emit(state.copyWith(team2Players: t2));
      }

      return null;
    } catch (e) {
      return 'Failed to join';
    }
  }

  // Join a room and assign the player to a team (atomic-ish flow)
  // Returns true on success, false otherwise.
  Future<bool> joinAndAssign({
    required String roomCode,
    required String playerName,
    required int team,
  }) async {
    print(
      '🚀 joinAndAssign started: room=$roomCode, player=$playerName, team=$team',
    );

    final ref = FirebaseDatabase.instance.ref('rooms/$roomCode');

    try {
      // First check if room exists
      final snap = await ref.get();
      if (!snap.exists) {
        print('❌ Room does not exist: $roomCode');
        return false;
      }

      final data = (snap.value as Map?)?.cast<String, dynamic>() ?? {};
      print('🏠 Room data exists, checking teams...');

      // Get current team players
      final teamKey = team == 1 ? 'team1Players' : 'team2Players';
      final teamData = data[teamKey];

      print('👥 Current team data for $teamKey: $teamData');

      // Parse current team players
      List<String> currentPlayers = [];
      if (teamData is Map) {
        // Handle Map format: {"0": "Ali", "1": "Sara"}
        final map = teamData.cast<String, dynamic>();
        for (int i = 0; i < 2; i++) {
          final player = (map['$i'] ?? '').toString().trim();
          currentPlayers.add(player);
        }
      } else if (teamData is List) {
        // Handle List format: ["Ali", "Sara"]
        for (int i = 0; i < teamData.length && i < 2; i++) {
          final player = (teamData[i] ?? '').toString().trim();
          currentPlayers.add(player);
        }
      }

      // Ensure we have exactly 2 slots
      while (currentPlayers.length < 2) {
        currentPlayers.add('');
      }

      print('🔍 Current players in team $team: $currentPlayers');

      // Find first empty slot
      int? freeSlot;
      for (int i = 0; i < 2; i++) {
        final player = currentPlayers[i];
        if (player.isEmpty ||
            player.startsWith('Player') ||
            player == 'Empty') {
          freeSlot = i;
          break;
        }
      }

      if (freeSlot == null) {
        print('❌ No free slots in team $team');
        return false;
      }

      print('✅ Found free slot $freeSlot, assigning player');

      // Assign player to the free slot
      await ref.child('$teamKey/$freeSlot').set(playerName);

      print('✅ Player assigned successfully, now joining room');

      // Update local state by joining the room
      final joined = await joinRoom(roomCode, playerName);
      print('🏠 Join room result: $joined');

      return joined;
    } catch (e, stackTrace) {
      print('💥 joinAndAssign failed with error: $e');
      print('📍 Stack trace: $stackTrace');
      return false;
    }
  }
}

// import 'dart:core';
// import 'dart:math';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playbaloot/data/room.repo.dart';
// import 'package:playbaloot/src/core/cubit/mr_states.dart';

// class MrCubit extends Cubit<MrState> {
//   //MrCubit({this.roomCode = "7654321"}) : super(0);
//   MrCubit() : super(const MrState());

//   //this function generates random code for room. and its being used in roomScreen
//   void generateRoomCode() {
//     {
//       final random = Random();
//       // generates a 7-digit random number (1000000–9999999)
//       final newCode = (1000000 + random.nextInt(9000000)).toString();
//       emit(
//         state.copyWith(roomCode: newCode),
//       ); //emit is responsible for displaying data in ui.
//     }
//   }

//   // Updated createRoom in MrCubit
//   Future<bool> createRoom({
//     required int target,
//     required List<String> team1,
//     required List<String> team2,
//     required int timeMinutes, // NEW: pass time here
//   }) async {
//     try {
//       if (state.roomCode.isEmpty) generateRoomCode();
//       final code = state.roomCode;

//       final team1Map = team1.asMap().map((i, name) => MapEntry('$i', name));
//       final team2Map = team2.asMap().map((i, name) => MapEntry('$i', name));

//       // Emit loading state
//       emit(state.copyWith(isCreatingRoom: true)); // ← Add this field to MrState

//       // Single atomic write — includes everything
//       await FirebaseDatabase.instance.ref('rooms/$code').set({
//         'targetScore': target,
//         'team1Score': 0,
//         'team2Score': 0,
//         'team1Players': team1Map,
//         'team2Players': team2Map,
//         'status': 'waiting',
//         'createdAt': ServerValue.timestamp,
//         'timerStarted': true,
//         'timerStartTime': ServerValue.timestamp,
//         'timeMinutes': timeMinutes, // included from the start
//       });

//       // Only update local state after Firebase success
//       emit(
//         state.copyWith(
//           isAdmin: true,
//           targetScore: target,
//           team1Players: team1,
//           team2Players: team2,
//           isCreatingRoom: false,
//           hasRoomBeenCreated: true,
//         ),
//       );

//       return true; // success
//     } catch (e) {
//       // Handle error and restore state
//       emit(state.copyWith(isCreatingRoom: false));
//       return false;
//     }
//   }
//   //add a function for addRound for scores
//   //this function takes data from users textfield
//   // and increments team1Score or team2Score. or adds on top of it
//   // and emits the change

//   Future<void> addRoundScoreRemote(int t1, int t2) async {
//     if (state.roomCode.isEmpty) return;
//     final ref = FirebaseDatabase.instance.ref('rooms/${state.roomCode}');
//     await ref.update({
//       'team1Score': ServerValue.increment(t1),
//       'team2Score': ServerValue.increment(t2),
//     });
//     // optional instant UI update:
//     addRoundScore(t1, t2);
//   }

//   void addRoundScore(int a, int b) {
//     emit(
//       state.copyWith(
//         team1Score: state.team1Score + a,
//         team2Score: state.team2Score + b,
//       ),
//     );
//     checkRoundEnded();
//   }

//   //to check if target score reached if yes end the round else no keep playing
//   void checkRoundEnded() {
//     final ended =
//         state.team1Score >= state.targetScore ||
//         state.team2Score >= state.targetScore;
//     emit(state.copyWith(roundEnded: ended));
//   }

//   void setTargetScore(int v) => emit(state.copyWith(targetScore: v));
//   void resetGame() => emit(
//     state.copyWith(
//       team1Score: 0,
//       team2Score: 0,
//       targetScore: 0,
//       roundEnded: false,
//       // Keep the room code!
//     ),
//   );

//   //this functino resets everything to intial state including generating fresh room code for next game.
//   //we use this in winScoreDialog so when user hits new game this function is called or used
//   /
//   Future<void> finishGame() async {
//     if (!state.isAdmin || state.roomCode.isEmpty) return;

//     try {
//       // ✅ Update Firebase status to "finished"
//       await FirebaseDatabase.instance.ref('rooms/${state.roomCode}').update({
//         'status': 'finished',
//       });

//       // ✅ Reset local state
//       emit(MrState());
//     } catch (e) {
//       // Handle error
//       print("Failed to finish game: $e");
//     }
//   }

//   // New function for admin to reset room with new code
//   Future<void> finishGameWithNewCode() async {
//     if (!state.isAdmin) return;

//     try {
//       // Generate new room code
//       final random = Random();
//       final newCode = (1000000 + random.nextInt(9000000)).toString();

//       // Reset Firebase room with new code and empty teams
//       final repo = RoomRepo();
//       await repo.createRoom(
//         code: newCode,
//         target: 152, // Default target
//         t1: [], // Empty teams
//         t2: [],
//       );

//       // Reset local state with new code and admin privileges
//       emit(
//         MrState().copyWith(
//           roomCode: newCode,
//           isAdmin: true,
//           playerName: state.playerName, // Keep admin name
//           targetScore: 152,
//         ),
//       );
//     } catch (e) {
//       // Fallback to local reset only
//       emit(MrState());
//     }
//   }

//   void numberOfPlayers() {
//     //here we will do the following:
//     // take cubit state.. and then say the number whcih user chooses in textfield
//     // becomes the state of cubit number. then we will go and display it in our roomScreen
//     // then the number of players displayed in UI be exactly the number of players inthe game
//   }

//   void startTimer() async {
//     if (state.roomCode.isEmpty) return;

//     await FirebaseDatabase.instance.ref('rooms/${state.roomCode}').update({
//       'timerStarted': true,
//       'timerStartTime': ServerValue.timestamp,
//     });

//     emit(state.copyWith(timerStarted: true));
//   }
//   //if room code is empty return nothing
//   //else update timerStamp in firebase database
//   //and update the timerStarted to true
//   //and emit the change

//   void updateTimerFromServer(int remainingSeconds) {
//     emit(state.copyWith(remainingSeconds: remainingSeconds));
//   }

//   // this function is used to update the timer from the server
//   // it takes the remaining seconds from the server
//   // and updates the state of the timer
//   // and emits the change

//   // Join dialog state management
//   void updateJoinRoomCode(String code) {
//     emit(state.copyWith(joinRoomCode: code, canJoin: code.trim().isNotEmpty));
//   }

//   void resetJoinDialog() {
//     emit(state.copyWith(joinRoomCode: "", canJoin: false));
//   }

//   // Join room function
//   Future<bool> joinRoom(String roomCode, String playerName) async {
//     try {
//       final snapshot =
//           await FirebaseDatabase.instance.ref('rooms/$roomCode').get();
//       if (!snapshot.exists) return false;

//       // Parse team data from Firebase
//       final data = (snapshot.value as Map?)?.cast<String, dynamic>() ?? {};

//       // Convert Firebase team data to List format
//       final team1Players = _parseTeamPlayers(data['team1Players']);
//       final team2Players = _parseTeamPlayers(data['team2Players']);
//       final targetScore = (data['targetScore'] as num?)?.toInt() ?? 0;
//       final team1Score = (data['team1Score'] as num?)?.toInt() ?? 0;
//       final team2Score = (data['team2Score'] as num?)?.toInt() ?? 0;

//       emit(
//         state.copyWith(
//           roomCode: roomCode,
//           playerName: playerName,
//           isAdmin: false, // viewers are not admin
//           team1Players: team1Players,
//           team2Players: team2Players,
//           targetScore: targetScore,
//           team1Score: team1Score,
//           team2Score: team2Score,
//         ),
//       );
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Helper function to parse team players
//   List<String> _parseTeamPlayers(dynamic teamData) {
//     if (teamData is List) {
//       return teamData.map((e) => (e ?? '').toString()).toList();
//     }
//     if (teamData is Map) {
//       final players = List<String>.filled(2, '');
//       teamData.forEach((key, value) {
//         final index = int.tryParse(key.toString()) ?? -1;
//         if (index >= 0 && index < 2) {
//           players[index] = (value ?? '').toString();
//         }
//       });
//       return players;
//     }
//     return ['', ''];
//   }

//   // NEW: add to MrCubit
//   Future<String?> assignPlayerToTeam({
//     required String name,
//     required int team, // 1 or 2
//   }) async {
//     if (state.roomCode.isEmpty) return 'No room';
//     final code = state.roomCode;
//     final teamKey = team == 1 ? 'team1Players' : 'team2Players';
//     final ref = FirebaseDatabase.instance.ref('rooms/$code/$teamKey');

//     final snap = await ref.get();
//     Map<String, dynamic> players = {};
//     if (snap.value is Map) {
//       players = (snap.value as Map).map(
//         (k, v) => MapEntry(k.toString(), (v ?? '').toString()),
//       );
//     }

//     if (players.length >= 2) return 'Team is full';

//     final slot =
//         !players.containsKey('0')
//             ? '0'
//             : (!players.containsKey('1') ? '1' : null);
//     if (slot == null) return 'Team is full';

//     await ref.update({slot: name});

//     // (Optional) immediate local fallback so UI updates even before RTDB stream ticks
//     final t1 = List<String>.from(state.team1Players);
//     final t2 = List<String>.from(state.team2Players);
//     if (team == 1) {
//       while (t1.length <= int.parse(slot)) t1.add('');
//       t1[int.parse(slot)] = name;
//       emit(state.copyWith(team1Players: t1));
//     } else {
//       while (t2.length <= int.parse(slot)) t2.add('');
//       t2[int.parse(slot)] = name;
//       emit(state.copyWith(team2Players: t2));
//     }

//     return null; // success
//   }
// }
