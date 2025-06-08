import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  _BadgesScreenState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _moduleProgress = {
    'healthy_food': 0,
    'hygiene': 0,
    'gym': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    for (String moduleId in _moduleProgress.keys) {
      int progress = await _firestoreService.getUserProgress(moduleId);
      setState(() {
        _moduleProgress[moduleId] = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Badges',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/badgelogo.png', width: 32, height: 32),
                const SizedBox(width: 12),
                Text(
                  'Your Achievements',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildBadgeCard(
              'Healthy Food Master',
              'assets/badges/foodbadge.png',
              _moduleProgress['healthy_food'] == 100,
              'Complete the Healthy Food module with 100% score',
            ),
            const SizedBox(height: 16),
            _buildBadgeCard(
              'Hygiene Expert',
              'assets/badges/hygienebadge.png',
              _moduleProgress['hygiene'] == 100,
              'Complete the Hygiene module with 100% score',
            ),
            const SizedBox(height: 16),
            _buildBadgeCard(
              'Fitness Champion',
              'assets/badges/gymbadge.png',
              _moduleProgress['gym'] == 100,
              'Complete the Gym module with 100% score',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(
    String title,
    String imagePath,
    bool isUnlocked,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isUnlocked
                    ? [Colors.deepPurple.shade100, Colors.deepPurple.shade50]
                    : [Colors.grey.shade300, Colors.grey.shade200],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isUnlocked
                              ? Colors.deepPurple.shade900
                              : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isUnlocked
                              ? Colors.deepPurple.shade700
                              : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUnlocked ? 'Unlocked!' : 'Locked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnlocked ? Colors.green : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
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
