import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:playbaloot/src/features/intros/presentation/pages/IntroScreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "splash screen",
      home: AnimatedSplashScreen(
        splash: Lottie.asset("assets/animations/Card Game.json"),
        splashIconSize: 350,

        nextScreen: Introscreen(),
        splashTransition: SplashTransition.fadeTransition,
        //pageTransitionType: pageTransitionType.scale,
        backgroundColor: Color(0xFFF7F7F7),
        duration: 2500, //5 seconds
      ),
    );
  }
}
