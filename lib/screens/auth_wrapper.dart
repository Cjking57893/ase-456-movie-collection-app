import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/service_locator.dart';
import 'login_page.dart';
import 'home_page.dart';

/// Wrapper that displays login or home page based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = ServiceLocator().authService;

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
