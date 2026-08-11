import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/text_theme_extension.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feature/auth/data/firebase_auth_service.dart';
import 'core/shared_preference/session_service.dart';
import 'feature/auth/cubit/auth/auth_cubit.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'feature/sub_company/staff_managment/staff/data/add_staff_repo.dart';
import 'firebase_options.dart';

import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // await windowManager.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.instance.requestPermission();
    initializeDateFormatting();

    // print(
    //   'Notification permission: ${settings.authorizationStatus}',
    // );

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
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(body: Center(child: Text('Failed to start: $error'))),
  );
}

class OxdoApp extends StatefulWidget {
  const OxdoApp({super.key});

  @override
  State<OxdoApp> createState() => _OxdoAppState();
}

class _OxdoAppState extends State<OxdoApp> {
  late final AuthCubit _authCubit;
  late final PermissionCubit _permissionCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(
      authService: FirebaseAuthService(),
      sessionService: SessionService(),
      staffRepository: StaffRepository(),
    );
    _permissionCubit = PermissionCubit();
    _router = AppRouter.createRouter(_authCubit, observers: [routeObserver]);

    // Kick off auth session restoration on app start
    _authCubit.checkSession(permissionCubit: _permissionCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _permissionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<StaffCubit>(create: (_) => StaffCubit()),
        BlocProvider<PermissionCubit>.value(value: _permissionCubit),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [CountryLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        title: 'Odit CRM',

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppThemeColors.appPrimaryColor,
          ),
          scaffoldBackgroundColor: AppThemeColors.scaffoldBg,

          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.light().textTheme,
          ).withLetterSpacing(0.3, 11.5),
        ),
        builder: (context, child) {
          return Sizer(
            builder: (context, orientation, deviceType) {
              return BlocListener<AuthCubit, AuthState>(
                bloc: _authCubit,
                listener: (context, state) {
                  if (state is AuthError) {
                    if (state.message.toLowerCase().contains('suspended') ||
                        state.message.toLowerCase().contains('upgrade plan')) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: const [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Account Suspended',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // NEW — every other AuthError (wrong password, empty fields,
                      // deactivated, no account found, etc.) shown here now. This
                      // listener is set up once in OxdoApp's build tree, above
                      // MaterialApp.router, so it can never be duplicated the way
                      // LoginScreen can during a GoRouter page transition.
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: const Color.fromARGB(
                              255,
                              180,
                              27,
                              24,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    }
                  }
                },
                //   }
                // },
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
