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
  String avatar = "assets/avatars/avatar1.png";

  int foodProgress = 0;
  int hygieneProgress = 0;
  int gymProgress = 0;

  String username = "User";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (user != null) {
      if (!mounted) return; // Check mounted before setState
      setState(() {
        username = user.displayName ?? "User";
      });
    }

    if (userId != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists) {
        final progress = userDoc['progress'] ?? {};
        if (!mounted) return; // Check mounted before setState
        setState(() {
          foodProgress = (progress['healthy_food'] ?? 0) as int;
          hygieneProgress = (progress['hygiene'] ?? 0) as int;
          gymProgress = (progress['gym'] ?? 0) as int;
          avatar = "assets/avatars/${userDoc['avatar']}";
        });
      }
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Your Profile",
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: AssetImage(avatar),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text("Username"),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text("Avatar"),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Text(
                "Lessons",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  color: Colors.deepPurple.shade700,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildLessonProgress(
                      "Healthy Food",
                      "assets/covers/food.png",
                      foodProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLessonProgress(
                      "Hygiene",
                      "assets/covers/hygiene.png",
                      hygieneProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLessonProgress(
                      "Gym",
                      "assets/covers/gym.png",
                      gymProgress,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonProgress(String title, String imagePath, int progress) {
    double progressFraction = progress / 100;
    String attemptText =
        progress == 100
            ? "1/1"
            : progress == 50
            ? "0.5/1"
            : "0/1";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 100),
            painter: OvalProgressPainter(progressFraction),
          ),
          Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 50),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$progress% • $attemptText",
                      style: TextStyle(
                        fontSize: 14,
                        color: progress == 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OvalProgressPainter extends CustomPainter {
  final double progress;

  OvalProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke;

    final Paint progressPaint =
        Paint()
          ..color =
              progress == 1
                  ? Colors.green
                  : (progress == 0.5 ? Colors.orange : Colors.red)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(50),
    );
    final Path ovalPath = Path()..addRRect(rRect);

    canvas.drawPath(ovalPath, basePaint);

    final metrics = ovalPath.computeMetrics();
    for (final metric in metrics) {
      final Path extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
