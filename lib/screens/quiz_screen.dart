import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'quiz_result_screen.dart';
import '../services/sound_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SoundService _soundService = SoundService();
  String? selectedAnswer;
  bool isCorrect = false;

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == "Salad");
    });

    _soundService.playSound(isCorrect ? "correct.mp3" : "wrong.mp3");

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizResultScreen(isCorrect: isCorrect)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/thinking.json', height: 120),
            const SizedBox(height: 20),
            const Text("What should I eat?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: [
                _buildAnswerOption("Hamburger"),
                _buildAnswerOption("Salad"),
                _buildAnswerOption("Pizza"),
                _buildAnswerOption("Burrito"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String answer) {
    return GestureDetector(
      onTap: () => checkAnswer(answer),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedAnswer == answer
              ? (isCorrect ? Colors.green : Colors.red)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(answer, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
