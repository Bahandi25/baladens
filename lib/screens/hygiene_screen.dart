import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'hygiene_quiz.dart';
import '../services/sound_service.dart';

class HygieneScreen extends StatelessWidget {
  const HygieneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  Lottie.asset(
                    'assets/animations/hand_wash.json', 
                    height: 200,
                  ),
                  const SizedBox(height: 24),

                 
                  const Text(
                    "Why is hygiene important?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                 
                  const Text(
                    "Good hygiene keeps us healthy and happy. Washing hands, brushing teeth, and taking showers help fight germs.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

             
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black45,
                      ),
                      onPressed: () {
                        soundService.playSound("button_click.mp3");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HygieneQuizScreen()),
                        );
                      },
                      child: const Text(
                        "I Understand!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
