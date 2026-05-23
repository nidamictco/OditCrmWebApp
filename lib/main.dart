import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/auth/data/firebase_auth_service.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/cubit/auth_cubit.dart';
import 'package:oxdo/feature/auth/screen/auth_gate.dart';
import 'package:oxdo/feature/auth/screen/login.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/cubit/permission_cubit.dart';
// import 'package:intl/date_symbol_data_http_request.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
  // await FirebaseMessaging.instance.requestPermission(  alert: true,
  //     badge: true,
  //     sound: true,);
  final settings =
    await FirebaseMessaging.instance.requestPermission();

print(
  'Notification permission: ${settings.authorizationStatus}',
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
  Widget build(BuildContext context) =>
      MaterialApp(home: Scaffold(body: Center(child: Text('Failed to start: $error'))));
}

class OxdoApp extends StatelessWidget {
  const OxdoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authService: FirebaseAuthService(),
            sessionService: SessionService(),
          ),
        ),
        BlocProvider<PermissionCubit>(   // ← NEW
          create: (_) => PermissionCubit(),
        ),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            supportedLocales: const [Locale('en')],
            localizationsDelegates: const [CountryLocalizations.delegate],
            debugShowCheckedModeBanner: false,
            title: 'Oxdo',
           theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
  ),
),
            home: AuthGate(),
          );
        },
      ),
    );
  }
}
