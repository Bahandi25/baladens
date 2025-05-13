import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../screens/profile_creation_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "682412988526-6bcls8kl54c80a7vbnk64eqm16bk48fh.apps.googleusercontent.com", 
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ProfileCreationScreen()));
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In Failed")));
    }
  }

  Future<void> signInAsGuest(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ProfileCreationScreen()));
    } catch (e) {
      print("Anonymous Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guest Sign-In Failed")));
    }
  }

  Future<void> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ProfileCreationScreen()));
    } catch (e) {
      print("Email Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email Sign-In Failed: $e")));
    }
  }

  Future<void> signUpWithEmail(BuildContext context, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ProfileCreationScreen()));
    } catch (e) {
      print("Email Sign-Up Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email Sign-Up Failed: $e")));
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e) {
      print("Sign-Out Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign-Out Failed")));
    }
  }
}
