import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedAvatar = "avatar1.png";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          _nicknameController.text = userDoc['name'] ?? "";
          _selectedAvatar = userDoc['avatar'] ?? "avatar1.png";
        });
      }
    }
  }

  Future<void> _updateNickname() async {
    if (_nicknameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': _nicknameController.text});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nickname updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating nickname: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAvatar(String avatar) async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatar': avatar});

        setState(() => _selectedAvatar = avatar);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating avatar: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();

          await user.delete();

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Nickname',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nicknameController,
                              decoration: const InputDecoration(
                                labelText: 'Nickname',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _updateNickname,
                              child: const Text('Update Nickname'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Avatar',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: 8, 
                              itemBuilder: (context, index) {
                                final avatar = "avatar${index + 1}.png";
                                return GestureDetector(
                                  onTap: () => _updateAvatar(avatar),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            _selectedAvatar == avatar
                                                ? Colors.deepPurple
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      "assets/avatars/$avatar",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _deleteAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete Account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
