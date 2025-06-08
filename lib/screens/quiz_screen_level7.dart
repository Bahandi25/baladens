import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'quiz_result_screen.dart';
import '../services/sound_service.dart';

class QuizScreenLevel7 extends StatefulWidget {
  const QuizScreenLevel7({super.key});

  @override
  State<QuizScreenLevel7> createState() => _QuizScreenLevel7State();
}

class _QuizScreenLevel7State extends State<QuizScreenLevel7> {
  final SoundService _soundService = SoundService();
  String? selectedAnswer;
  bool isCorrect = false;

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == "Mother's food");
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
      backgroundColor: Colors.purple.shade50,
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
                  "Which of these is the most wholesome meal?",
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
                    _buildAnswerOption("Doner", "🥙"),
                    _buildAnswerOption("Rollton", "🍜"),
                    _buildAnswerOption("Sushi", "🍣"),
                    _buildAnswerOption("Mother's food", "🍲"), // ✅ Correct
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
              offset: const Offset(0, 3),
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
