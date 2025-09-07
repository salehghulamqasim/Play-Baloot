import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:playbaloot/src/features/create/presentation/pages/CreateScreen.dart';

import 'package:playbaloot/src/features/intros/presentation/widgets/intro_icon_with_text.dart';
import 'package:playbaloot/src/features/join/presentation/pages/JoinDialog.dart';

import 'package:vibration/vibration.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 📱 ScreenUtil import

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //to go back to previous page
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          // 📱 Handle overflow on small screens
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24.w,
                0,
                24.w,
                24.h,
              ), // 📱 Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Join Or Create Room',
                    style: TextStyle(
                      fontSize: 45.sp, // 📱 Responsive font size
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 38.h), // 📱 Responsive spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      //container -- 1
                      Container(
                        width: 140.w, // 📱 Responsive width
                        height: 220.h, // 📱 Responsive height
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2.w,
                          ), // 📱 Responsive border
                          borderRadius: BorderRadius.circular(
                            20.r,
                          ), // 📱 Responsive border radius
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // HapticFeedback.heavyImpact(); // or mediumImpact(), heavyImpact(), selectionClick()

                                if (await Vibration.hasVibrator()) {
                                  Vibration.vibrate(duration: 40);
                                }

                                //    Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const Joinscreen(),
                                //   ),
                                // );
                                joinDialog(context);
                              },
                              child: IntroIconWithText(
                                iconPath: 'assets/Icons/Qr-Code2.svg',
                                label: 'Join Room',
                                iconSize: 72,

                                textSize: 28,
                                iconColor: Color(0xFF0000FF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //container -- 2
                      SizedBox(
                        width: 20.w,
                      ), // 📱 Responsive spacing between containers
                      Container(
                        width: 140.w, // 📱 Responsive width
                        height: 220.h, // 📱 Responsive height
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2.w,
                          ), // 📱 Responsive border
                          borderRadius: BorderRadius.circular(
                            20.r,
                          ), // 📱 Responsive border radius
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (await Vibration.hasVibrator()) {
                                  Vibration.vibrate(duration: 40);
                                }

                                final c = context.read<MrCubit>();
                                if (c.state.roomCode ==
                                    "RoomCode Isn't Generated Yet") {
                                  c.generateRoomCode();
                                }

                                // await c
                                //     .createRoom(); // writes rooms/{code} to Realtime DB

                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Createscreen(),
                                  ),
                                );
                              },
                              child: const IntroIconWithText(
                                iconPath: 'assets/Icons/square-plus.svg',
                                label: 'Create Room',
                                iconSize: 72,
                                textSize: 28,
                                iconColor: Color(0xFF0000FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //if u wanna add something then add below this line
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
