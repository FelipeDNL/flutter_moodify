import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_test/routes/app_routes.dart';
import 'package:flutter_application_test/ui/core/auth/account_creation/account_creation_screen.dart';
import 'package:flutter_application_test/ui/core/auth/auth_wrapper.dart';
import 'package:flutter_application_test/ui/core/auth/login/login_screen.dart';
import 'package:flutter_application_test/ui/core/home/home_screen.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.authWrapper,
      routes: {
        AppRoutes.authWrapper: (_) => const AuthWrapper(),
        AppRoutes.loginScreen: (_) => const LoginScreen(),
        AppRoutes.accountCreationScreen: (_) => const AccountCreationScreen(),
        AppRoutes.homeScreen: (_) => const HomeScreen(),
      },
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}