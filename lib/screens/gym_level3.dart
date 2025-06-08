import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/sound_service.dart';
import 'quiz_result_screen.dart';

class GymLevel3Screen extends StatefulWidget {
  const GymLevel3Screen({super.key});

  @override
  State<GymLevel3Screen> createState() => _GymLevel3ScreenState();
}

class _GymLevel3ScreenState extends State<GymLevel3Screen> {
  final SoundService _soundService = SoundService();
  int _tapCount = 0;
  bool _animationPlayed = false;

  void _handleTap() {
    if (_animationPlayed) return;
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _animationPlayed = true;
      }
    });
    _soundService.playSound("button_click.mp3");
  }

  void _completeLevel() {
    _soundService.playSound("button_click.mp3");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(isCorrect: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade100, Colors.purple.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        _animationPlayed
                            ? ModelViewer(
                              src: 'assets/situps.glb',
                              alt: "Sit-ups animation",
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                              autoPlay: true,
                            )
                            : Center(
                              child: Text(
                                'Tap the screen 5 times to start the animation!\n(${5 - _tapCount} taps left)',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Sit-ups",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Sit-ups build strong abdominal muscles. Lie on your back with your knees bent and feet on the floor. Cross your arms on your chest or behind your head. Use your core to lift your upper body, then lower back down slowly.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                if (_animationPlayed)
                  ElevatedButton(
                    onPressed: _completeLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Complete Level",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
