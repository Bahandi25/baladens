import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/dashboard_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String selectedAvatar = 'assets/avatars/avatar1.png'; 

  Future<void> saveProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': _nameController.text,
      'avatar': selectedAvatar.split('/').last,
      'progress': {},
      'badges': [],
      'soundEnabled': true,
      'createdAt': Timestamp.now(),
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Choose an Avatar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatarOption('assets/avatars/avatar1.png'),
                _buildAvatarOption('assets/avatars/avatar2.png'),
                _buildAvatarOption('assets/avatars/avatar3.png'),
                _buildAvatarOption('assets/avatars/avatar4.png'),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Enter Your Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveProfile, child: const Text("Continue"))
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String avatarPath) {
    return GestureDetector(
      onTap: () => setState(() => selectedAvatar = avatarPath),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
              color: selectedAvatar == avatarPath ? Colors.blue : Colors.transparent,
              width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(avatarPath, height: 50),
      ),
    );
  }
}
