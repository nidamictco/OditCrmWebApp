import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/firebase_auth_service/firebase_auth_service.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/cubit/auth_cubit.dart';
import 'package:oxdo/feature/auth/screen/auth_gate.dart';
import 'package:oxdo/feature/auth/screen/login.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const OxdoApp());
  } catch (e) {
    // Fallback UI or log error
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Failed to start: $error')),
      ),
    );
  }
}
class OxdoApp extends StatelessWidget {
  const OxdoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(
  authService: FirebaseAuthService(),
  sessionService: SessionService(),
)..checkSession(), 
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Oxdo',
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
          home: AuthGate(),
        );
      }
      ),
    );
  }
}

