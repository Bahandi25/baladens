import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'quiz_result_screen.dart';
import '../services/sound_service.dart';

class QuizScreenLevel4 extends StatefulWidget {
  const QuizScreenLevel4({super.key});

  @override
  State<QuizScreenLevel4> createState() => _QuizScreenLevel4State();
}

class _QuizScreenLevel4State extends State<QuizScreenLevel4> {
  final SoundService _soundService = SoundService();
  String? selectedAnswer;
  bool isCorrect = false;

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == "Nuts");
    });

    _soundService.playSound(isCorrect ? "correct.mp3" : "wrong.mp3");

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(isCorrect: isCorrect),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
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
                  "Which of these is a healthy snack?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    _buildAnswerOption("Chips", "🥔"),
                    _buildAnswerOption("Nuts", "🥜"),
                    _buildAnswerOption("Candy", "🍬"),
                    _buildAnswerOption("Cake", "🍰"),
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
          color:
              isSelected
                  ? (isCorrect ? Colors.greenAccent : Colors.redAccent)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.4)
                      : Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
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