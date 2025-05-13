import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLessonProgress(String moduleId, int score) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'progress': {
        moduleId: score, 
      }
    }, SetOptions(merge: true));
  }

  Future<int> getUserProgress(String moduleId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc['progress'] != null) {
      return (doc['progress'][moduleId] ?? 0) as int;
    }
    return 0;
  }
}
