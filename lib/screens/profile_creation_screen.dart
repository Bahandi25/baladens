import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/dashboard_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final User user;
  final bool isGoogleSignIn;
  final bool isGuest;

  const ProfileCreationScreen({
    super.key,
    required this.user,
    this.isGoogleSignIn = false,
    this.isGuest = false,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String selectedAvatar = 'assets/avatars/avatar1.png';
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .set({
          'uid': widget.user.uid,
          'email': widget.user.email,
          'name': _nameController.text.trim(),
          'avatar': selectedAvatar.split('/').last,
          'progress': {},
          'badges': [],
          'soundEnabled': true,
          'createdAt': Timestamp.now(),
          'isGoogleSignIn': widget.isGoogleSignIn,
          'isGuest': widget.isGuest,
          'lastSignIn': Timestamp.now(),
        });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SlideTransition(
              position: _offsetAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Choose Your Avatar 👤",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildAvatarOption('assets/avatars/avatar1.png'),
                      _buildAvatarOption('assets/avatars/avatar2.png'),
                      _buildAvatarOption('assets/avatars/avatar3.png'),
                      _buildAvatarOption('assets/avatars/avatar4.png'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter Your Name",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: saveProfile,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Continue"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String avatarPath) {
    return GestureDetector(
      onTap: () => setState(() => selectedAvatar = avatarPath),
      child: CircleAvatar(
        radius: 40,
        backgroundColor:
            selectedAvatar == avatarPath
                ? Colors.blueAccent
                : Colors.transparent,
        child: CircleAvatar(
          radius: 36,
          backgroundImage: AssetImage(avatarPath),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
