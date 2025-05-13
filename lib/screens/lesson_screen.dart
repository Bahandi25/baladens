import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../services/sound_service.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("What should you eat to stay healthy?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text(
              "Healthy food includes fruits, vegetables, and balanced meals. Avoid junk food and processed sugars.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: () {
                  soundService.playSound("button_click.mp3");
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const QuizScreen()));
                },
                child: const Text("I Understand!"))
          ],
        ),
      ),
    );
  }
}
