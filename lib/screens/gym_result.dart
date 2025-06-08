import 'package:flutter/material.dart';
import 'gym_screen.dart';
import 'dashboard_screen.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';

class GymResultScreen extends StatefulWidget {
  final bool isCorrect;

  const GymResultScreen({super.key, required this.isCorrect});

  @override
  State<GymResultScreen> createState() => _GymResultScreenState();
}

class _GymResultScreenState extends State<GymResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();

    int score = widget.isCorrect ? 100 : 50;
    _firestoreService.saveLessonProgress("gym", score);
    _soundService.playSound("lesson_complete.mp3");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isCorrect ? Colors.green[100] : Colors.red[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isCorrect ? Icons.check_circle : Icons.cancel,
                size: 120,
                color: widget.isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 30),
              Text(
                widget.isCorrect ? "Great job!" : "Oops, try again!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isCorrect ? Colors.green[800] : Colors.red[800],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.isCorrect ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (widget.isCorrect) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GymScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      widget.isCorrect ? "Back to Dashboard" : "Try Again",
                    ),
                  ),
                  if (!widget.isCorrect) ...[
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Back to Dashboard"),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
