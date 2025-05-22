import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLessonProgress(String moduleId, int score) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'progress': {moduleId: score},
    }, SetOptions(merge: true));
  }

  Future<int> getUserProgress(String moduleId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc['progress'] != null) {
      return (doc['progress'][moduleId] ?? 0) as int;
    }
    return 0;
  }

  // New methods for challenges
  Future<List<Map<String, dynamic>>> getUserChallenges() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    // Get user's progress
    Map<String, dynamic> progress = userDoc['progress'] ?? {};

    // Generate challenges based on progress
    List<Map<String, dynamic>> challenges = [];

    // Food challenges
    if (progress['healthy_food'] != null) {
      challenges.add({
        'id': 'food_1',
        'title': 'Healthy Food Master',
        'description': 'Complete the Healthy Food lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed': progress['healthy_food'] == 100,
        'icon': '🥗',
      });
    }

    // Hygiene challenges
    if (progress['hygiene'] != null) {
      challenges.add({
        'id': 'hygiene_1',
        'title': 'Hygiene Expert',
        'description': 'Complete the Hygiene lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed': progress['hygiene'] == 100,
        'icon': '🧼',
      });
    }

    // Gym challenges
    if (progress['gym'] != null) {
      challenges.add({
        'id': 'gym_1',
        'title': 'Fitness Champion',
        'description': 'Complete the Gym lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed': progress['gym'] == 100,
        'icon': '💪',
      });
    }

    // Daily challenge
    challenges.add({
      'id': 'daily_1',
      'title': 'Daily Learner',
      'description': 'Complete any lesson today',
      'type': 'daily',
      'reward': 25,
      'completed': false, // This will be updated based on today's activity
      'icon': '📚',
    });

    // Weekly challenge
    challenges.add({
      'id': 'weekly_1',
      'title': 'Weekly Master',
      'description': 'Complete all three lessons this week',
      'type': 'weekly',
      'reward': 100,
      'completed': false, // This will be updated based on weekly activity
      'icon': '🏆',
    });

    return challenges;
  }

  Future<void> updateChallengeStatus(String challengeId, bool completed) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      'challenges': {
        challengeId: {
          'completed': completed,
          'completedAt': FieldValue.serverTimestamp(),
        },
      },
    }, SetOptions(merge: true));
  }
}
