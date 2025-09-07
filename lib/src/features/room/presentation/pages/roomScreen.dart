/*
  FLOW (what happens on this screen):
  1) We listen to Firebase RTDB at `rooms/{roomCode}` via StreamBuilder.
  2) On each update we parse:
     - Scores (team1Score, team2Score), targetScore
     - Timer (createdAt/startedAt + timeMinutes) => remaining time
     - Player names (team1Players, team2Players)  ✅ works with List OR Map {"0":"Ali","1":"Sara"}
     - Status ("finished") to propagate finish to all viewers
  3) If the game has ended remotely, we show the "Victory" bottom sheet once for viewers (_finishShown).
  4) The "End Round / Finish" button is only visible for admins (state.isAdmin).
     - Admin pressing "Finish" writes `status: finished` so all devices close properly.
  */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion/motion.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:confetti/confetti.dart';
import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:playbaloot/src/core/cubit/mr_states.dart';
import 'package:playbaloot/src/features/room/presentation/widgets/roundScoreDialog.dart';
import 'package:playbaloot/src/features/room/presentation/widgets/winScoreDialog.dart';

// ⬇️ Import with a prefix so we refer to the button explicitly.
import 'package:playbaloot/src/features/intros/presentation/widgets/intro_icon_with_text.dart'
    as intro;

class Roomscreen extends StatefulWidget {
  const Roomscreen({super.key});

  @override
  State<Roomscreen> createState() => _RoomscreenState();
}

class _RoomscreenState extends State<Roomscreen> {
  Timer? _tick;
  final DateTime _now = DateTime.now();

  bool _finishShown = false; // prevent re-showing finish sheet repeatedly
  bool _confettiShown = false;

  late ConfettiController _confettiController; // Add ConfettiController

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _mmss(int secs) {
    if (secs < 0) secs = 0;
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  List<String> _playersFromRtdb(dynamic v, List<String> fallback) {
    if (v is List) return v.map((e) => (e ?? '').toString()).toList();
    if (v is Map) {
      final m = v.map(
        (k, val) =>
            MapEntry(int.tryParse(k.toString()) ?? -1, (val ?? '').toString()),
      );
      final out = List<String>.filled(2, '');
      m.forEach((i, name) {
        if (i >= 0 && i < out.length) out[i] = name;
      });
      return out;
    }
    return fallback;
  }

  String _orPlaceholder(String name, String placeholder) =>
      name.trim().isEmpty ? placeholder : name;

  Future<bool> _confirmEnd(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('End Game?'),
            content: const Text(
              'Do you want to end the game and leave the room?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('End Game'),
              ),
            ],
          ),
    );

    if (result == true) {
      final code = context.read<MrCubit>().state.roomCode;
      if (code.isNotEmpty) {
        try {
          await FirebaseDatabase.instance.ref('rooms/$code').update({
            'status': 'finished',
          });
        } catch (_) {}
      }
      // Reset local Cubit state so UI that listens to hasRoomBeenCreated
      // doesn't immediately navigate back into the old room.
      try {
        await context.read<MrCubit>().finishGame();
      } catch (_) {
        // ignore
      }
      return true;
    }
    return false;
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text(
              'Do you want to exit the game and leave the room?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Exit Game'),
              ),
            ],
          ),
    );

    if (result == true) {
      final code = context.read<MrCubit>().state.roomCode;
      final playerName = context.read<MrCubit>().state.playerName;
      if (code.isNotEmpty && playerName.isNotEmpty) {
        try {
          await context.read<MrCubit>().removeViewer(code, playerName);
        } catch (_) {}
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MrCubit, MrState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop:
              () =>
                  state.isAdmin ? _confirmEnd(context) : _confirmExit(context),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () async {
                  final confirmed =
                      state.isAdmin
                          ? await _confirmEnd(context)
                          : await _confirmExit(context);
                  if (confirmed) Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            backgroundColor: const Color(0xFFF7F7F7),
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: true,
                    emissionFrequency: 0.03,
                    numberOfParticles: 10,
                    gravity: 0.06,
                    minBlastForce: 3,
                    maxBlastForce: 7,
                    colors: [
                      Colors.orange,
                      Colors.redAccent,
                      const Color.fromARGB(255, 42, 19, 218),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(0.w),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'The Game Room',
                                style: TextStyle(
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // QR container
                            Container(
                              padding: EdgeInsets.all(4.w),
                              width: 210.w,
                              height: 248.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 2.w,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Column(
                                children: [
                                  Motion.elevated(
                                    elevation: 16,
                                    glare: false,
                                    shadow: false,
                                    filterQuality: FilterQuality.medium,
                                    child: QrImageView(
                                      data: state.roomCode,
                                      version: QrVersions.auto,
                                      size: 180.w,
                                      gapless: true,
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    state.roomCode,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Monospace",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // LIVE: timer + scores + target + names + finish status from Realtime DB
                            StreamBuilder<DatabaseEvent>(
                              key: ValueKey(state.roomCode),
                              stream:
                                  state.roomCode.isEmpty
                                      ? null
                                      : FirebaseDatabase.instance
                                          .ref('rooms/${state.roomCode}')
                                          .onValue,
                              builder: (context, snap) {
                                final data =
                                    (snap.data?.snapshot.value as Map?)
                                        ?.cast<String, dynamic>() ??
                                    {};

                                final t1 = _asInt(
                                  data['team1Score'],
                                  fallback: state.team1Score,
                                );
                                final t2 = _asInt(
                                  data['team2Score'],
                                  fallback: state.team2Score,
                                );
                                final target = _asInt(
                                  data['targetScore'],
                                  fallback: state.targetScore,
                                );
                                if ((t1 >= target || t2 >= target) &&
                                    !_confettiShown &&
                                    mounted) {
                                  _confettiShown = true;
                                  _confettiController.play();
                                }

                                final status =
                                    (data['status'] ?? '').toString();
                                final remoteEnded = status == 'finished';

                                int minutes = _asInt(
                                  data['timeMinutes'],
                                  fallback: 30,
                                );

                                int? createdAtMs;
                                final ca =
                                    data['timerStartTime'] ??
                                    data['startedAt'] ??
                                    data['createdAt'];
                                if (ca is int) {
                                  createdAtMs = ca;
                                } else if (ca is num)
                                  createdAtMs = ca.toInt();

                                int remaining;
                                if (createdAtMs != null) {
                                  final started =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        createdAtMs,
                                      );
                                  final elapsed =
                                      _now.difference(started).inSeconds;
                                  remaining = (minutes * 60) - elapsed;
                                } else {
                                  remaining = minutes * 60;
                                }

                                final team1Players = _playersFromRtdb(
                                  data['team1Players'],
                                  state.team1Players,
                                );
                                final team2Players = _playersFromRtdb(
                                  data['team2Players'],
                                  state.team2Players,
                                );

                                if (remoteEnded &&
                                    !_finishShown &&
                                    mounted &&
                                    !state.isAdmin) {
                                  _finishShown = true;
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!mounted) return;
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (context) => Stack(
                                            alignment: Alignment.topCenter,
                                            children: [
                                              WinningBottomSheet(
                                                winnerLabel:
                                                    (t1 >= target && t1 != t2)
                                                        ? "Team 1 wins"
                                                        : (t2 >= target &&
                                                            t1 != t2)
                                                        ? "Team 2 wins"
                                                        : "Game Finished",
                                                title: "Victory",
                                                message:
                                                    "Great match! The game has ended.",
                                                finishButtonText:
                                                    "Back to Menu",
                                                onFinish: () {
                                                  context
                                                      .read<MrCubit>()
                                                      .finishGame();
                                                  Navigator.of(
                                                    context,
                                                  ).popUntil(
                                                    (route) => route.isFirst,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  });
                                }

                                return Column(
                                  children: [
                                    Text(
                                      _mmss(remaining),
                                      style: TextStyle(
                                        fontSize: 38.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 18.h),
                                    Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Team 1",
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                ),
                                              ),
                                              Text(
                                                '$t1',
                                                style: TextStyle(
                                                  fontSize: 44.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 24.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F7F7),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Target",
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              const Text(
                                                "",
                                                style: TextStyle(fontSize: 0),
                                              ),
                                              Text(
                                                '$target',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF007AFF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Team 2",
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                ),
                                              ),
                                              Text(
                                                '$t2',
                                                style: TextStyle(
                                                  fontSize: 44.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _orPlaceholder(
                                                  team1Players.isNotEmpty
                                                      ? team1Players[0]
                                                      : '',
                                                  "Player 1",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              const Divider(),
                                              SizedBox(height: 16.h),
                                              Text(
                                                _orPlaceholder(
                                                  team1Players.length > 1
                                                      ? team1Players[1]
                                                      : '',
                                                  "Player 2",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _orPlaceholder(
                                                  team2Players.isNotEmpty
                                                      ? team2Players[0]
                                                      : '',
                                                  "Player 1",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              const Divider(),
                                              SizedBox(height: 16.h),
                                              Text(
                                                _orPlaceholder(
                                                  team2Players.length > 1
                                                      ? team2Players[1]
                                                      : '',
                                                  "Player 2",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 40.h),
                                    if (state.isAdmin)
                                      intro.AppleStyleButton(
                                        label:
                                            (t1 >= target || t2 >= target)
                                                ? "Finish the Game"
                                                : "End Round",
                                        onPressed: () async {
                                          if (!(t1 >= target || t2 >= target)) {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              enableDrag: true,
                                              useSafeArea: true,
                                              builder:
                                                  (context) =>
                                                      const RoundScoreBottomSheet(
                                                        title:
                                                            "Round completed",
                                                        teamALabel: 'Team 1',
                                                        teamBLabel: "Team 2",
                                                        submitButtonText:
                                                            'Continue',
                                                      ),
                                            );
                                          } else {
                                            final code =
                                                context
                                                    .read<MrCubit>()
                                                    .state
                                                    .roomCode;
                                            if (code.isNotEmpty) {
                                              await FirebaseDatabase.instance
                                                  .ref('rooms/$code')
                                                  .update({
                                                    'status': 'finished',
                                                  });
                                            }
                                            if (!mounted) return;

                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder:
                                                  (context) => Stack(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    children: [
                                                      WinningBottomSheet(
                                                        winnerLabel:
                                                            (t1 >= target &&
                                                                    t1 != t2)
                                                                ? "Team 1 wins"
                                                                : (t2 >=
                                                                        target &&
                                                                    t1 != t2)
                                                                ? "Team 2 wins"
                                                                : "Game Finished",
                                                        title: "Victory",
                                                        message:
                                                            "Amazing performance! Well played",
                                                        finishButtonText:
                                                            state.isAdmin
                                                                ? "New Game?"
                                                                : "Leave Room",
                                                        onFinish: () {
                                                          if (state.isAdmin) {
                                                            context
                                                                .read<MrCubit>()
                                                                .finishGameWithNewCode();
                                                          }
                                                          Navigator.of(
                                                            context,
                                                          ).popUntil(
                                                            (route) =>
                                                                route.isFirst,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                      )
                                    else
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.h),
                                        child: Text(
                                          "Waiting for admin…",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    if (!state.isAdmin)
                                      intro.AppleStyleButton(
                                        label: "Exit Game",
                                        onPressed: () async {
                                          final confirmed = await _confirmExit(
                                            context,
                                          );
                                          if (confirmed) Navigator.pop(context);
                                        },
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
