import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLessonProgress(String moduleId, int score) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user ID available for saving progress');
      return;
    }

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    // First, get current progress to check for daily/weekly completion
    DocumentSnapshot doc = await userDoc.get();
    Map<String, dynamic> currentData =
        doc.data() as Map<String, dynamic>? ?? {};
    Map<String, dynamic> currentProgress = currentData['progress'] ?? {};
    int currentPoints = currentData['points'] ?? 0;

    print('=== Progress Update Debug ===');
    print('Module being updated: $moduleId with score: $score');
    print('Current progress before update: $currentProgress');
    print('Current points before update: $currentPoints');

    // Check if this is a new completion (score is 100 and wasn't completed before)
    bool isNewCompletion =
        score == 100 && (currentProgress[moduleId] ?? 0) < 100;

    // Award 50 points for completing a module
    if (isNewCompletion) {
      currentPoints += 50;
      print('Awarded 50 points for completing module $moduleId');
    }

    // Update progress and points
    await userDoc.set({
      'progress': {moduleId: score},
      'points': currentPoints,
    }, SetOptions(merge: true));

    // Check and update daily challenge
    String dailyChallengeId = 'daily_1';
    if (!currentData.containsKey('challenges') ||
        !currentData['challenges'].containsKey(dailyChallengeId) ||
        !_isChallengeCompletedToday(
          currentData['challenges'][dailyChallengeId],
        )) {
      await updateChallengeStatus(dailyChallengeId, true);
    }

    // Check and update weekly challenge
    String weeklyChallengeId = 'weekly_1';
    bool allLessonsCompleted = true;
    print('\nChecking weekly challenge completion:');
    ['healthy_food', 'hygiene', 'gym'].forEach((lessonId) {
      int lessonScore = currentProgress[lessonId] ?? 0;
      print('$lessonId score: $lessonScore');
      if (lessonScore != 100) {
        allLessonsCompleted = false;
      }
    });

    print('All lessons completed: $allLessonsCompleted');
    print('Current challenges: ${currentData['challenges']}');

    // If all lessons are completed for the first time, award 100 points
    bool isWeeklyNewCompletion =
        allLessonsCompleted &&
        (!currentData.containsKey('challenges') ||
            !currentData['challenges'].containsKey(weeklyChallengeId) ||
            !_isChallengeCompletedThisWeek(
              currentData['challenges'][weeklyChallengeId],
            ));

    print('Weekly challenge new completion: $isWeeklyNewCompletion');

    if (isWeeklyNewCompletion) {
      print('All lessons completed! Awarding 100 points for weekly challenge');
      await updateChallengeStatus(weeklyChallengeId, true);
    }

    // Get final points after all updates
    doc = await userDoc.get();
    int finalPoints = (doc.data() as Map<String, dynamic>?)?['points'] ?? 0;
    print('Final points after all updates: $finalPoints');
    print('=============================');
  }

  Future<int> getUserProgress(String moduleId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user ID available for getting progress');
      return 0;
    }

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
    if (userId == null) {
      print('Error: No user ID available for getting challenges');
      return [];
    }

    print('Fetching challenges for user: $userId');

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      print('Error: User document does not exist');
      return [];
    }

    // Get user's progress and completed challenges
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> progress = userData['progress'] ?? {};
    Map<String, dynamic> completedChallenges = userData['challenges'] ?? {};

    print('User progress: $progress');
    print('Completed challenges: $completedChallenges');

    // Generate challenges based on progress
    List<Map<String, dynamic>> challenges = [];

    // Food challenges
    if (progress['healthy_food'] != null) {
      String challengeId = 'food_1';
      challenges.add({
        'id': challengeId,
        'title': 'Healthy Food Master',
        'description': 'Complete the Healthy Food lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed':
            progress['healthy_food'] == 100 ||
            completedChallenges.containsKey(challengeId),
        'icon': '🥗',
      });
    }

    // Hygiene challenges
    if (progress['hygiene'] != null) {
      String challengeId = 'hygiene_1';
      challenges.add({
        'id': challengeId,
        'title': 'Hygiene Expert',
        'description': 'Complete the Hygiene lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed':
            progress['hygiene'] == 100 ||
            completedChallenges.containsKey(challengeId),
        'icon': '🧼',
      });
    }

    // Gym challenges
    if (progress['gym'] != null) {
      String challengeId = 'gym_1';
      challenges.add({
        'id': challengeId,
        'title': 'Fitness Champion',
        'description': 'Complete the Gym lesson with 100% score',
        'type': 'achievement',
        'reward': 50,
        'completed':
            progress['gym'] == 100 ||
            completedChallenges.containsKey(challengeId),
        'icon': '💪',
      });
    }

    // Daily challenge
    String dailyChallengeId = 'daily_1';
    bool isDailyCompleted =
        completedChallenges.containsKey(dailyChallengeId) &&
        _isChallengeCompletedToday(completedChallenges[dailyChallengeId]);
    challenges.add({
      'id': dailyChallengeId,
      'title': 'Daily Learner',
      'description': 'Complete any lesson today',
      'type': 'daily',
      'reward': 25,
      'completed': isDailyCompleted,
      'icon': '📚',
    });

    // Weekly challenge
    String weeklyChallengeId = 'weekly_1';
    bool allLessonsCompleted = [
      'healthy_food',
      'hygiene',
      'gym',
    ].every((lessonId) => progress[lessonId] == 100);
    bool isWeeklyCompleted =
        completedChallenges.containsKey(weeklyChallengeId) &&
        _isChallengeCompletedThisWeek(completedChallenges[weeklyChallengeId]);

    challenges.add({
      'id': weeklyChallengeId,
      'title': 'Weekly Master',
      'description': 'Complete all three lessons this week',
      'type': 'weekly',
      'reward': 100,
      'completed': allLessonsCompleted || isWeeklyCompleted,
      'icon': '🏆',
    });

    print('Generated challenges: ${challenges.length}');
    return challenges;
  }

  bool _isChallengeCompletedToday(Map<String, dynamic>? challengeData) {
    if (challengeData == null || challengeData['completedAt'] == null)
      return false;

    Timestamp completedAt = challengeData['completedAt'] as Timestamp;
    DateTime now = DateTime.now();
    DateTime completedDate = completedAt.toDate();

    return completedDate.year == now.year &&
        completedDate.month == now.month &&
        completedDate.day == now.day;
  }

  bool _isChallengeCompletedThisWeek(Map<String, dynamic>? challengeData) {
    if (challengeData == null || challengeData['completedAt'] == null)
      return false;

    Timestamp completedAt = challengeData['completedAt'] as Timestamp;
    DateTime now = DateTime.now();
    DateTime completedDate = completedAt.toDate();

    // Get the start of the current week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    // Get the start of the week when the challenge was completed
    DateTime completedWeekStart = completedDate.subtract(
      Duration(days: completedDate.weekday - 1),
    );
    completedWeekStart = DateTime(
      completedWeekStart.year,
      completedWeekStart.month,
      completedWeekStart.day,
    );

    return startOfWeek.isAtSameMomentAs(completedWeekStart);
  }

  Future<void> updateChallengeStatus(String challengeId, bool completed) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user ID available for updating challenge status');
      return;
    }

    print('Updating challenge status: $challengeId to $completed');

    // Get the challenge reward
    int reward = 0;
    if (challengeId == 'daily_1')
      reward = 25;
    else if (challengeId == 'weekly_1')
      reward = 100;
    else
      reward = 50; // achievement challenges

    print('Challenge reward: $reward points');

    // Get current points and challenges before update
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>? ?? {};
    int currentPoints = userData['points'] ?? 0;
    Map<String, dynamic> currentChallenges = userData['challenges'] ?? {};

    print('Current points before challenge update: $currentPoints');
    print('Current challenges: $currentChallenges');

    // Only award points if this is a new completion
    bool isNewCompletion =
        !currentChallenges.containsKey(challengeId) ||
        !currentChallenges[challengeId]['completed'];

    if (completed && isNewCompletion) {
      currentPoints += reward;
      print('Awarding $reward points for new challenge completion');
    }

    // Update challenge status and points
    await _firestore.collection('users').doc(userId).set({
      'challenges': {
        challengeId: {
          'completed': completed,
          'completedAt': FieldValue.serverTimestamp(),
        },
      },
      'points': currentPoints,
    }, SetOptions(merge: true));

    // Get final points after update
    doc = await _firestore.collection('users').doc(userId).get();
    int finalPoints = (doc.data() as Map<String, dynamic>?)?['points'] ?? 0;
    print('Final points after challenge update: $finalPoints');
  }

  Future<Map<String, dynamic>> getUserLevelInfo() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null)
      return {'level': 1, 'points': 0, 'pointsToNextLevel': 100};

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return {'level': 1, 'points': 0, 'pointsToNextLevel': 100};

    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    int points = userData['points'] ?? 0;

    // Calculate level (each level requires 100 points)
    int level = (points ~/ 100) + 1;
    // Calculate points needed for next level (remaining points to next 100)
    int pointsToNextLevel = 100 - (points % 100);

    print('=== Level Calculation Debug ===');
    print('Total points: $points');
    print('Level calculation: ($points ~/ 100) + 1 = $level');
    print('Points to next level: 100 - ($points % 100) = $pointsToNextLevel');
    print('=============================');

    return {
      'level': level,
      'points': points,
      'pointsToNextLevel': pointsToNextLevel,
    };
  }
}
