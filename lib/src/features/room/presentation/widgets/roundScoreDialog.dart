import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:vibration/vibration.dart';
import '../../../intros/presentation/widgets/intro_icon_with_text.dart';

class RoundScoreBottomSheet extends StatefulWidget {
  final String title;
  final String teamALabel;
  final String teamBLabel;
  final void Function(int teamAScore, int teamBScore)? onSubmit;
  final VoidCallback? onCancel;
  final String submitButtonText;
  final String cancelButtonText;

  const RoundScoreBottomSheet({
    super.key,
    this.title = 'Round Over',
    this.teamALabel = 'Team 1',
    this.teamBLabel = 'Team 2',
    this.onSubmit,
    this.onCancel,
    this.submitButtonText = 'Next Round',
    this.cancelButtonText = 'Cancel',
  });

  @override
  State<RoundScoreBottomSheet> createState() => _RoundScoreBottomSheetState();
}

class _RoundScoreBottomSheetState extends State<RoundScoreBottomSheet> {
  late final TextEditingController teamAController;
  late final TextEditingController teamBController;

  @override
  void initState() {
    super.initState();
    teamAController = TextEditingController();
    teamBController = TextEditingController();
  }

  @override
  void dispose() {
    teamAController.dispose();
    teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDEE3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                'Enter the scores for this round',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0x991D1D1F),
                ),
              ),
              SizedBox(height: 24.h),

              _buildScoreInput(
                label: widget.teamALabel,
                controller: teamAController,
              ),
              SizedBox(height: 16.h),

              _buildScoreInput(
                label: widget.teamBLabel,
                controller: teamBController,
              ),
              SizedBox(height: 32.h),

              AppleStyleButton(
                label: widget.submitButtonText,
                onPressed: () async {
                  if (await Vibration.hasVibrator()) {
                    Vibration.vibrate(duration: 40);
                  }
                  final a = int.tryParse(teamAController.text.trim()) ?? 0;
                  final b = int.tryParse(teamBController.text.trim()) ?? 0;

                  if (widget.onSubmit != null) {
                    widget.onSubmit!(a, b);
                  } else {
                    final code = context.read<MrCubit>().state.roomCode;
                    if (code.isNotEmpty) {
                      await FirebaseDatabase.instance
                          .ref('rooms/$code')
                          .update({
                            'team1Score': ServerValue.increment(a),
                            'team2Score': ServerValue.increment(b),
                          });
                    }
                    context.read<MrCubit>().addRoundScore(a, b);

                    //if user types score for round and hits continue. then close the dialog
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
              SizedBox(height: 12.h),

              Center(
                child: TextButton(
                  onPressed:
                      widget.onCancel ??
                      () async {
                        if (await Vibration.hasVibrator()) {
                          Vibration.vibrate(duration: 40);
                        }
                        Navigator.of(context).pop();
                      },
                  child: Text(
                    widget.cancelButtonText,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreInput({
    required String label,
    required TextEditingController controller,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: const Color(0xFFE5E5EA), width: 1.w),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: const Color(0x991D1D1F),
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: const Color(0xFF007AFF),
                width: 2.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showRoundScoreBottomSheet({
  required BuildContext context,
  String title = 'Round Over',
  String teamALabel = 'Team A',
  String teamBLabel = 'Team B',
  void Function(int teamAScore, int teamBScore)? onSubmit,
  VoidCallback? onCancel,
  String submitButtonText = 'Next Round',
  String cancelButtonText = 'Cancel',
}) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => RoundScoreBottomSheet(
          title: title,
          teamALabel: teamALabel,
          teamBLabel: teamBLabel,
          onSubmit: onSubmit,
          onCancel: onCancel,
          submitButtonText: submitButtonText,
          cancelButtonText: cancelButtonText,
        ),
  );
}
