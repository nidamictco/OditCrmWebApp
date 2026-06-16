import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'feature/auth/data/firebase_auth_service.dart';
import 'core/shared_preference/session_service.dart';
import 'feature/auth/cubit/auth/auth_cubit.dart';
import 'feature/auth/screen/auth_gate.dart';
import 'feature/auth/screen/login.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'feature/sub_company/staff_managment/staff/data/add_staff_repo.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // await windowManager.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
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
            staffRepository: StaffRepository(),
          ),
        ),
        BlocProvider<PermissionCubit>(
          create: (_) => PermissionCubit(),
        ),
      ],
      child: MaterialApp(
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [CountryLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        title: 'Oditbiz',
       theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
        home:Sizer(  // ✅ Sizer gets MediaQuery from MaterialApp above it
          builder: (context, orientation, deviceType) {
            return AuthGate();
          },
        ),
      ),
    );
  }
}
