import 'package:firebase_database/firebase_database.dart';
// firebase_messaging removed - notifications handled externally or via OneSignal
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:motion/motion.dart';
import 'package:playbaloot/src/core/cubit/mr_cubit.dart';
import 'package:playbaloot/src/features/intros/presentation/pages/IntroScreen.dart';
//import 'package:playbaloot/src/features/intros/presentation/pages/IntroScreen.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 📱 ScreenUtil import
import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  // Ensure bindings, but don't block UI on service init
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before using messaging or RTDB.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // 🔔 Initialize OneSignal BEFORE runApp()
  print('🔔 Initializing OneSignal...');

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // Initialize with your OneSignal App ID
  OneSignal.initialize("1537486e-3e01-48ce-ada0-38e871495f92");
  print('🔔 OneSignal initialized with App ID');

  // Request notification permission
  OneSignal.Notifications.requestPermission(true);
  print('🔔 Notification permission requested');

  // 🔔 Handle notification taps
  OneSignal.Notifications.addClickListener((event) {
    print('🔔 NOTIFICATION CLICKED: ${event.notification.body}');
  });

  // 🔔 Get Player ID for testing (temporary - remove in production)
  OneSignal.User.addObserver((state) {
    print('🔔 ONESIGNAL PLAYER ID: ${state.current.onesignalId}');
    print('🔔 EXTERNAL ID: ${state.current.externalId}');
  });

  print('🔔 OneSignal setup complete!');
  // Initialize non-critical services and perform cleanup in background
  Future(() async {
    try {
      await Motion.instance.initialize();
      Motion.instance.setUpdateInterval(60.fps);
    } catch (e) {
      debugPrint('Motion init error: $e');
    }

    // Init & quick ping (testing) with timeouts so it never hangs startup
    try {
      final db = FirebaseDatabase.instance;
      await db
          .ref('debug/ping')
          .set({'ts': DateTime.now().toIso8601String()})
          .timeout(const Duration(seconds: 2));
      await db.ref('debug/ping').get().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Ping skipped: $e');
    }

    // 🔧 Run cleanup: Fix any rooms saved as List instead of Map
    try {
      final ref = FirebaseDatabase.instance.ref('rooms');
      final snapshot = await ref.get();
      if (snapshot.value is Map) {
        (snapshot.value as Map).forEach((key, dynamic value) {
          if (value is List) {
            debugPrint("🔧 Fixing invalid room (was List): $key");
            ref.child(key).remove(); // Delete corrupted room
          }
        });
      }
    } catch (e) {
      debugPrint("⚠️ Cleanup failed: $e");
    }
  });

  // Firebase Cloud Messaging removed from app code. Notification handling moved to backend or external service.
  runApp(
    DevicePreview(
      enabled: false, // Enable Device Preview in debug only
      builder:
          (context) => ScreenUtilInit(
            // 📱 Initialize ScreenUtil for responsive design
            designSize: const Size(375, 812), // 📱 iPhone X design size
            minTextAdapt: true, // 📱 Adapt text to screen size
            splitScreenMode: true, // 📱 Support split screen
            builder: (context, child) => MyApp(child: child),
          ),
    ),
    //const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final Widget? child;
  const MyApp({super.key, this.child});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // getting countercubit from main.dart BlocProvider
    return BlocProvider(
      create: (_) => MrCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        locale: DevicePreview.locale(context),
        // 📱 COMBINED RESPONSIVE BUILDER - DevicePreview + ScreenUtil!
        builder: (context, child) {
          final devicePreviewChild = DevicePreview.appBuilder(context, child);

          return MediaQuery(
            data: MediaQuery.of(context),
            child: devicePreviewChild,
          );
        },

        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.black, // Icon color in AppBar
            ),
          ),
        ),
        home: const Introscreen(),
      ),
    );
  }
}

// _firebaseMessagingBackgroundHandler removed along with firebase_messaging dependency

//TODO
//  SO i need to build the ui of join and create
//  then add in join page the qr scanner qrimageview
// also make sure to use same textfield of create in join
// and use same button from introscreen (make it reusable component)
