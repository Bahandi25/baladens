import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../screens/profile_creation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../screens/dashboard_screen.dart';
import '../screens/auth_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        final userDocByUid =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDocByUid.exists) {
          await _firestore.collection('users').doc(user.uid).update({
            'isGoogleSignIn': true,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'lastSignIn': Timestamp.now(),
          });

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          final userDocByEmail =
              await _firestore
                  .collection('users')
                  .where('email', isEqualTo: user.email)
                  .get();

          if (userDocByEmail.docs.isNotEmpty) {
            final existingDoc = userDocByEmail.docs.first;
            await _firestore.collection('users').doc(user.uid).set({
              ...existingDoc.data(),
              'uid': user.uid,
              'isGoogleSignIn': true,
              'email': user.email,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'lastSignIn': Timestamp.now(),
            });

            await _firestore.collection('users').doc(existingDoc.id).delete();

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            }
          } else {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfileCreationScreen(
                        user: user,
                        isGoogleSignIn: true,
                      ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Google: $e')),
      );
    }
  }

  Future<void> signInAsGuest(BuildContext context) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProfileCreationScreen(user: user, isGuest: true),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing in as guest: $e')));
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }
}
