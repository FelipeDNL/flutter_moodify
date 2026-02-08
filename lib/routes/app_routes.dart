import 'package:flutter/material.dart';
import 'package:flutter_application_test/ui/core/auth/account_creation/account_creation_screen.dart';
import 'package:flutter_application_test/ui/core/auth/auth_wrapper.dart';
import 'package:flutter_application_test/ui/core/auth/login/login_screen.dart';
import 'package:flutter_application_test/ui/core/home/home_screen.dart';

class AppRoutes {
  static const String authWrapper = '/';
  static const String loginScreen = '/login';
  static const String accountCreationScreen = '/account-creation';
  static const String homeScreen = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      authWrapper: (context) => const AuthWrapper(),
      loginScreen: (context) => const LoginScreen(),
      accountCreationScreen: (context) => const AccountCreationScreen(),
      homeScreen: (context) => const HomeScreen(),
    };
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();