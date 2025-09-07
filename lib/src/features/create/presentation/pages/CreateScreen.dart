import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:playbaloot/src/core/cubit/mr_states.dart';
import 'package:playbaloot/src/features/create/presentation/widgets/FormFields.dart';
import 'package:playbaloot/src/features/intros/presentation/widgets/intro_icon_with_text.dart';
import 'package:playbaloot/src/features/room/presentation/pages/roomScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Createscreen extends StatefulWidget {
  const Createscreen({super.key});

  @override
  State<Createscreen> createState() => _CreatescreenState();
}

class _CreatescreenState extends State<Createscreen> {
  String _adminName = '';
  bool _canCreate = false;

  int _minutesFromLabel(String s) {
    if (s.contains('hour')) {
      final n = int.tryParse(s.split(' ').first) ?? 1;
      return n * 60;
    }
    return int.tryParse(s.split(' ').first) ?? 30;
  }

  String _selectedValue = '30 minutes';
  final List<String> _timeOptions = [
    '15 minutes',
    '30 minutes',
    '1 hour',
    '2 hours',
    '3 hours',
    '4 hours',
    '5 hours',
  ];

  void _showCupertinoPicker() {
    HapticFeedback.selectionClick();
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 240.h,
            color: Colors.white,
            child: CupertinoPicker(
              itemExtent: 38.h,
              scrollController: FixedExtentScrollController(
                initialItem: _timeOptions.indexOf(_selectedValue),
              ),
              onSelectedItemChanged: (index) {
                HapticFeedback.mediumImpact(); // haptic feedback on selection
                setState(() {
                  _selectedValue = _timeOptions[index];
                });
              },
              children:
                  _timeOptions
                      .map(
                        (e) => Center(
                          child: Text(e, style: TextStyle(fontSize: 18.sp)),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create Room',
                    style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
                SizedBox(height: 38.h),

                Column(
                  children: [
                    //*in future add number of players so people can add more than 4 players if they wish
                    // FormLabeledField(
                    //   label: "Number of players",
                    //   hintOrValue: "4",
                    //   isRequired: true,
                    // ),

                    //TODO Make the admin name be saved in the game as player team1 [0]
                    FormLabeledField(
                      label: "Admin Name",
                      hintOrValue: "Owner of the room",
                      isRequired: true,
                      onChanged: (v) => _adminName = v.trim(),
                    ),

                    SizedBox(height: 22.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Choose Time",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: _showCupertinoPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE5E5EA)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedValue,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 22.h),
                    FormLabeledField(
                      label: "Target Score",
                      isRequired: true,
                      hintOrValue: "100 points",
                      onChanged: (value) {
                        final score = int.tryParse(value.trim());
                        setState(() {
                          _canCreate =
                              score != null; // enable only when it's a number
                        });
                        if (score != null) {
                          context.read<MrCubit>().setTargetScore(score);
                        }
                        //Find my MrCubit in the widget tree, and tell it to update the target score with this new value.
                        // we added if else so if score is not empty then do updating else dont .
                      },
                    ),

                    SizedBox(height: 120.h),

                    BlocConsumer<MrCubit, MrState>(
                      //listens to for changes and go to roomscreen
                      listener: (context, state) {
                        if (state.hasRoomBeenCreated) {
                          // ✅ Successfully created → navigate
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Roomscreen(),
                            ),
                          );
                        }
                      },
                      //builder watches for changes and redraws the screen UI
                      builder: (context, state) {
                        return AppleStyleButton(
                          label:
                              state.isCreatingRoom
                                  ? "Creating Room..."
                                  : "Create a Room",
                          onPressed:
                              !_canCreate || state.isCreatingRoom
                                  ? null
                                  : () async {
                                    final cubit = context.read<MrCubit>();
                                    if (cubit.state.roomCode.isEmpty) {
                                      cubit.generateRoomCode();
                                    }

                                    // Use empty strings for empty slots so joins detect free slots correctly
                                    final team1 = [
                                      _adminName.isEmpty ? "Admin" : _adminName,
                                      "",
                                    ];
                                    final team2 = ["", ""]; // empty slots
                                    final minutes = _minutesFromLabel(
                                      _selectedValue,
                                    );

                                    final success = await cubit.createRoom(
                                      target: cubit.state.targetScore,
                                      team1: team1,
                                      team2: team2,
                                      timeMinutes: minutes,
                                    );

                                    if (!success) {
                                      // ✅ Show error if Firebase failed
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Failed to create room. Check connection.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
