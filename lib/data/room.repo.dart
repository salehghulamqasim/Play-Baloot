import 'package:firebase_database/firebase_database.dart';

class RoomRepo {
  RoomRepo({FirebaseDatabase? db}) : _db = db ?? FirebaseDatabase.instance;
  final FirebaseDatabase _db;

  DatabaseReference _room(String code) => _db.ref('rooms/$code');
  Future<void> createRoom({
    required String code,
    required int target,
    required List<String> t1,
    required List<String> t2,
    required int timeMinutes,
  }) async {
    await _room(code).set({
      'targetScore': target,
      'team1Score': 0,
      'team2Score': 0,
      'team1Players': t1.asMap().map((i, name) => MapEntry('$i', name)),
      'team2Players': t2.asMap().map((i, name) => MapEntry('$i', name)),
      'status': 'waiting',
      'createdAt': ServerValue.timestamp,
      'timeMinutes': timeMinutes,
      'timerStarted': false,
    });
  }
  //above are the starting values of each variable. such as scores, name and target etc.

  //watch room
  Stream<Map<String, dynamic>?> watchRoom(String code) => _room(
    code,
  ).onValue.map((e) => (e.snapshot.value as Map?)?.cast<String, dynamic>());

  //add round score
  Future<void> addRoundScore(String code, int t1, int t2) =>
      _room(code).update({
        'team1Score': ServerValue.increment(t1),
        'team2Score': ServerValue.increment(t2),
      });
}
