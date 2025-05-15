// hygiene_result.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import 'dashboard_screen.dart';

class HygieneResultScreen extends StatelessWidget {
  final bool isCorrect;
  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();

  HygieneResultScreen({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    int score = isCorrect ? 100 : 50;

    _firestoreService.saveLessonProgress("hygiene", score);
    _soundService.playSound("lesson_complete.mp3");

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isCorrect
                ? Lottie.asset("assets/animations/correct_answer.json", height: 150)
                : Lottie.asset("assets/animations/wrong_answer.json", height: 150),
            const SizedBox(height: 20),
            Text(
              isCorrect ? "Great job!" : "Keep practicing!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()),
                );
              },
              child: const Text("Back to Dashboard"),
            )
          ],
        ),
      ),
    );
  }
}
