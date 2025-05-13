import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => authService.signInAsGuest(context), 
                child: const Text("Continue as Guest")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => authService.signInWithGoogle(context), 
                child: const Text("Sign in with Google")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {}, 
                child: const Text("Sign in with Email"))
          ],
        ),
      ),
    );
  }
}
