import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int progress = 0;
  String avatar = "assets/avatars/avatar1.png";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        progress = (userDoc['progress']['healthy_food'] ?? 0) as int;
        avatar = "assets/avatars/${userDoc['avatar']}";
      });
    }
  }

  void _logout(BuildContext context) async {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 40, backgroundImage: AssetImage(avatar)),
            const SizedBox(height: 10),
            const Text("Your Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("$progress% Completed", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Change Username")),
            ElevatedButton(onPressed: () {}, child: const Text("Change Avatar")),
            ElevatedButton(onPressed: () => _logout(context), child: const Text("Logout")),

            const SizedBox(height: 30),
            const Text("Lessons", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildLessonCover("Healthy Food", "assets/covers/healthy_food.png"),
                  _buildLessonCover("Hygiene", "assets/covers/hygiene.png"),
                  _buildLessonCover("Gym", "assets/covers/gym.png"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCover(String title, String imagePath) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
