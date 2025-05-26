import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveLessonProgress(String moduleId, int score) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: No user ID available for saving progress');
      return;
    }

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot doc = await userDoc.get();
    Map<String, dynamic> currentData =
        doc.data() as Map<String, dynamic>? ?? {};
    Map<String, dynamic> currentProgress = currentData['progress'] ?? {};
    int currentPoints = currentData['points'] ?? 0;

    print('=== Progress Update Debug ===');
    print('Module being updated: $moduleId with score: $score');
    print('Current progress before update: $currentProgress');
    print('Current points before update: $currentPoints');

    bool isNewCompletion =
        score == 100 && (currentProgress[moduleId] ?? 0) < 100;

    if (isNewCompletion) {
      currentPoints += 50;
      print('Awarded 50 points for completing module $moduleId');
      await addCoins(2); 
    }

    await userDoc.set({
      'progress': {moduleId: score},
      'points': currentPoints,
    }, SetOptions(merge: true));

    String dailyChallengeId = 'daily_1';
    if (!currentData.containsKey('challenges') ||
        !currentData['challenges'].containsKey(dailyChallengeId) ||
        !_isChallengeCompletedToday(
          currentData['challenges'][dailyChallengeId],
        )) {
      await updateChallengeStatus(dailyChallengeId, true);
    }

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

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> progress = userData['progress'] ?? {};
    Map<String, dynamic> completedChallenges = userData['challenges'] ?? {};

    print('User progress: $progress');
    print('Completed challenges: $completedChallenges');

    List<Map<String, dynamic>> challenges = [];

    if (progress['healthy_food'] == 100) {
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

    if (progress['hygiene'] == 100) {
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

    if (progress['gym'] == 100) {
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
        'icon': '��',
      });
    }

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

    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

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

    int reward = 0;
    if (challengeId == 'daily_1')
      reward = 25;
    else if (challengeId == 'weekly_1')
      reward = 100;
    else
      reward = 50; 

    print('Challenge reward: $reward points');

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>? ?? {};
    int currentPoints = userData['points'] ?? 0;
    Map<String, dynamic> currentChallenges = userData['challenges'] ?? {};

    print('Current points before challenge update: $currentPoints');
    print('Current challenges: $currentChallenges');

    bool isNewCompletion =
        !currentChallenges.containsKey(challengeId) ||
        !currentChallenges[challengeId]['completed'];

    if (completed && isNewCompletion) {
      currentPoints += reward;
      print('Awarding $reward points for new challenge completion');
    }

    await _firestore.collection('users').doc(userId).set({
      'challenges': {
        challengeId: {
          'completed': completed,
          'completedAt': FieldValue.serverTimestamp(),
        },
      },
      'points': currentPoints,
    }, SetOptions(merge: true));

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

    int level = (points ~/ 100) + 1;
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

  Future<int> getUserCoins() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return (userDoc.data() as Map<String, dynamic>?)?['coins'] ?? 0;
    } catch (e) {
      print('Error getting user coins: $e');
      return 0;
    }
  }

  Future<void> addCoins(int amount) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      DocumentReference userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        int currentCoins =
            (userDoc.data() as Map<String, dynamic>?)?['coins'] ?? 0;
        transaction.update(userRef, {'coins': currentCoins + amount});
      });
    } catch (e) {
      print('Error adding coins: $e');
    }
  }

  Future<bool> isModuleUnlocked(String moduleId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      List<String> unlockedModules = List<String>.from(
        (userDoc.data() as Map<String, dynamic>?)?['unlocked_modules'] ?? [],
      );
      return unlockedModules.contains(moduleId);
    } catch (e) {
      print('Error checking module unlock status: $e');
      return false;
    }
  }

  Future<bool> unlockModule(String moduleId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      DocumentReference userRef = _firestore.collection('users').doc(userId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        int currentCoins =
            (userDoc.data() as Map<String, dynamic>?)?['coins'] ?? 0;

        if (currentCoins < 20) return false;

        List<String> unlockedModules = List<String>.from(
          (userDoc.data() as Map<String, dynamic>?)?['unlocked_modules'] ?? [],
        );

        if (!unlockedModules.contains(moduleId)) {
          unlockedModules.add(moduleId);
          transaction.update(userRef, {
            'unlocked_modules': unlockedModules,
            'coins': currentCoins - 20,
          });
        }

        return true;
      });
    } catch (e) {
      print('Error unlocking module: $e');
      return false;
    }
  }
}
