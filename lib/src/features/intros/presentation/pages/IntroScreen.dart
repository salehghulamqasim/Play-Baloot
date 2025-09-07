// ignore: file_names

import 'package:flutter/material.dart';
import 'package:playbaloot/src/features/home/presentation/pages/HomeScreen.dart';
import 'package:playbaloot/src/features/intros/presentation/widgets/intro_icon_with_text.dart';

import 'package:vibration/vibration.dart';
// import 'path_to_your/apple_style_button.dart'; // if AppleStyleButton is in another file
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Introscreen extends StatelessWidget {
  const Introscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 24.h),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Play Baloot',
                  style: TextStyle(
                    fontSize: 45.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                SizedBox(height: 44.h),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IntroIconWithText(
                        iconPath: 'assets/Icons/qrcode-freepik.svg',
                        label: 'Scan a QR code to join a room',
                      ),
                    ),
                    Expanded(
                      child: IntroIconWithText(
                        iconPath: 'assets/Icons/cards-freepik.svg',
                        label: 'Play against other players',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 34.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 24.h),

                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 3.w),
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    child: Text(
                      'Score\npoints\nand win',
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
                SizedBox(height: 80.h),

                Center(
                  child: AppleStyleButton(
                    label: "Get Started",
                    onPressed: () async {
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate(duration: 50);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Homescreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ignore: file_names

// // import 'path_to_your/apple_style_button.dart'; // if AppleStyleButton is in another file

// class Introscreen extends StatelessWidget {
//   const Introscreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Play Baloot',
//                 style: TextStyle(
//                   fontSize: 45,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'SF Pro Display',
//                 ),
//               ),
//               const SizedBox(height: 54),
//               const Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: IntroIconWithText(
//                       iconPath: 'assets/Icons/qrcode-freepik.svg',
//                       label: 'Scan a QR code to join a room',
//                     ),
//                   ),
//                   Expanded(
//                     child: IntroIconWithText(
//                       iconPath: 'assets/Icons/cards-freepik.svg',
//                       label: 'Play against other players',
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 44),
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black, width: 3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Score\npoints\nand win',
//                     style: TextStyle(fontSize: 26),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 140),

//               Center(
//                 child: AppleStyleButton(
//                   label: "Get Started",
//                   onPressed: () async {
//                     if (await Vibration.hasVibrator()) {
//                       Vibration.vibrate(duration: 50);
//                     }

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const Homescreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     debugPrint('Pressed!');

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const Homescreen()),
//                     );
//                   },
//                   child: const Text('Get Started'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
