import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String avatar = "assets/avatars/avatar1.png";
  bool _useDefaultAvatar = false;

  int foodProgress = 0;
  int hygieneProgress = 0;
  int gymProgress = 0;

  String username = "User";
  String nickname = "User";

  Map<String, dynamic> _levelInfo = {
    'level': 1,
    'points': 0,
    'pointsToNextLevel': 100,
  };

  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadLevelInfo();
    _loadUserCoins();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (user != null) {
      if (!mounted) return;
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
        if (!mounted) return;
        setState(() {
          foodProgress = (progress['healthy_food'] ?? 0) as int;
          hygieneProgress = (progress['hygiene'] ?? 0) as int;
          gymProgress = (progress['gym'] ?? 0) as int;
          avatar = "assets/avatars/${userDoc['avatar']}";
          nickname = userDoc['name'] ?? "User";
        });
      }
    }
  }

  Future<void> _loadLevelInfo() async {
    final levelInfo = await _firestoreService.getUserLevelInfo();
    setState(() {
      _levelInfo = levelInfo;
    });
  }

  Future<void> _loadUserCoins() async {
    int coins = await _firestoreService.getUserCoins();
    if (!mounted) return;
    setState(() {
      _coins = coins;
    });
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
    final user = FirebaseAuth.instance.currentUser;

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

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/coin.png', width: 20, height: 20),
                        const SizedBox(width: 6),
                        Text(
                          _coins.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child:
                              _useDefaultAvatar
                                  ? Text(
                                    nickname[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  )
                                  : Image.asset(avatar),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nickname,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${_levelInfo['level']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value:
                          _levelInfo['points'] /
                          _levelInfo['pointsToNextLevel'],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_levelInfo['points']}/${_levelInfo['pointsToNextLevel']} points to next level',
                      style: TextStyle(
                        color: Colors.deepPurple.withOpacity(0.8),
                        fontSize: 14,
                      ),
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
                  _buildLessonProgress(
                    "Healthy Food",
                    "assets/covers/food.png",
                    foodProgress,
                  ),
                  const SizedBox(width: 12),
                  _buildLessonProgress(
                    "Hygiene",
                    "assets/covers/hygiene.png",
                    hygieneProgress,
                  ),
                  const SizedBox(width: 12),
                  _buildLessonProgress(
                    "Gym",
                    "assets/covers/gym.png",
                    gymProgress,
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
    int totalLessons = 2; 
    int completedLessons = (progress / 100 * totalLessons).round();
    String attemptText = "$completedLessons/$totalLessons";

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 100),
              painter: OvalProgressPainter(progressFraction),
            ),
            Container(
              width: double.infinity,
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$progress% • $attemptText",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                progress == 100 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
