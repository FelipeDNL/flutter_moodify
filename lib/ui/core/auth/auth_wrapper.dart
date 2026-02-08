import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_test/ui/core/auth/login/login_screen.dart';
import 'package:flutter_application_test/ui/core/home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica o estado de autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Se o usuário está autenticado
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        // Se o usuário não está autenticado
        return const LoginScreen();
      },
    );
  }
}