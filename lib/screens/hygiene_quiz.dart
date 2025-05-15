import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'hygiene_result.dart';
import '../services/sound_service.dart';

class HygieneQuizScreen extends StatefulWidget {
  const HygieneQuizScreen({super.key});

  @override
  State<HygieneQuizScreen> createState() => _HygieneQuizScreenState();
}

class _HygieneQuizScreenState extends State<HygieneQuizScreen> {
  final SoundService _soundService = SoundService();
  String? selectedAnswer;
  bool isCorrect = false;

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == "Wash your hands");
    });

    _soundService.playSound(isCorrect ? "correct.mp3" : "wrong.mp3");

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HygieneResultScreen(isCorrect: isCorrect),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/thinking.json', height: 140),
                const SizedBox(height: 20),
                const Text(
                  "What should you do before eating?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Grid ответов
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    _buildAnswerOption("Wash your hands", "🧼"),
                    _buildAnswerOption("Play outside", "⚽"),
                    _buildAnswerOption("Watch TV", "📺"),
                    _buildAnswerOption("Eat immediately", "🍔"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String answer, String emoji) {
    final bool isSelected = selectedAnswer == answer;

    return GestureDetector(
      onTap: () => checkAnswer(answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrect ? Colors.greenAccent : Colors.redAccent)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.4)
                  : Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 10),
            Text(
              answer,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
