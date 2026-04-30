import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oxdo/feature/auth/screen/login.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Oxdo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: LoginScreen(),
      );
    }
    );
  }
}

