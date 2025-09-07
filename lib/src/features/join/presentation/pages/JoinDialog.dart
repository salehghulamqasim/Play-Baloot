import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:playbaloot/src/features/create/presentation/widgets/FormFields.dart';
import 'package:playbaloot/src/features/room/presentation/pages/roomScreen.dart';
import 'package:playbaloot/src/features/room/presentation/widgets/winScoreDialog.dart';

/// Flow (short & sweet):
/// 1) Show dialog with QR scanner + manual input + name/team fields
/// 2) User scans/types code, enters name, picks team
/// 3) Verify room exists and is active → join directly
Future<void> joinDialog(BuildContext context) async {
  context.read<MrCubit>().resetJoinDialog();

  String playerName = '';
  int selectedTeam = 0;
  String roomCode = '';

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final kb = MediaQuery.of(dialogCtx).viewInsets.bottom;
          final keyboardOpen = kb > 0;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: kb),
            child: Center(
              child: Material(
                color: const Color(0xFFF7F7F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 4,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // keep dialog from growing larger than the screen
                    maxHeight: MediaQuery.of(dialogCtx).size.height * 0.85,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: 360.w,
                      child: Padding(
                        padding: EdgeInsets.all(26.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // QR Scanner (collapses when typing)
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              crossFadeState:
                                  keyboardOpen
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                              firstChild: AspectRatio(
                                aspectRatio: 1.2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: MobileScanner(
                                    onDetect: (capture) async {
                                      for (final b in capture.barcodes) {
                                        final v = b.rawValue;
                                        if (v != null && v.isNotEmpty) {
                                          setState(() => roomCode = v);
                                          break;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),

                            SizedBox(height: 12.h),
                            Text(
                              'Scan QR or enter details below',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            // Room Code Input
                            FormLabeledField(
                              label: "Room Code",
                              isRequired: true,
                              hintOrValue:
                                  roomCode.isEmpty
                                      ? "Enter room code"
                                      : roomCode,
                              keyboardType: TextInputType.number,
                              onChanged:
                                  (value) => setState(() => roomCode = value),
                            ),

                            // Player Name Input
                            FormLabeledField(
                              label: "Your Name",
                              isRequired: true,
                              hintOrValue: "Enter your name",
                              onChanged:
                                  (value) => setState(() => playerName = value),
                            ),

                            SizedBox(height: 16.h),

                            // Team Selection
                            Text(
                              'Select Team',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(() => selectedTeam = 1),
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedTeam == 1
                                                ? Colors.blue
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Team 1',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              selectedTeam == 1
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(() => selectedTeam = 2),
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedTeam == 2
                                                ? Colors.blue
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Team 2',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              selectedTeam == 2
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Join Button
                            AppleStyleButton(
                              label: "Join Room",
                              onPressed:
                                  (roomCode.trim().isEmpty ||
                                          playerName.trim().isEmpty ||
                                          selectedTeam == 0)
                                      ? null
                                      : () async {
                                        print(
                                          'Joining room: $roomCode, player: $playerName, team: $selectedTeam',
                                        );
                                        final success = await context
                                            .read<MrCubit>()
                                            .joinAndAssign(
                                              roomCode: roomCode,
                                              playerName: playerName,
                                              team: selectedTeam,
                                            );

                                        if (!success) {
                                          print(
                                            'Join failed for room: $roomCode, player: $playerName, team: $selectedTeam',
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Team is full. Try the other team.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.of(dialogCtx).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const Roomscreen(),
                                          ),
                                        );
                                      },
                            ),

                            SizedBox(height: 16.h),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ), // Column
                      ), // Padding
                    ), // SizedBox
                  ), // SingleChildScrollView
                ), // ConstrainedBox
              ), // Material
            ), // Center
          );
        },
      );
    },
  );
}
