import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import 'dashboard_screen.dart';

class ToothbrushGameScreen extends StatefulWidget {
  const ToothbrushGameScreen({super.key});

  @override
  State<ToothbrushGameScreen> createState() => _ToothbrushGameScreenState();
}

class _ToothbrushGameScreenState extends State<ToothbrushGameScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isClean = false;

  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  void _increaseProgress(double distance) {
    if (_isClean) return;

    setState(() {
      _progress += distance / 200; 
      if (_progress >= 100) {
        _progress = 100;
        _isClean = true;
        _fadeController.forward();

        _firestoreService.saveLessonProgress("hygiene", 100);
        _soundService.playSound("lesson_complete.mp3");
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Brush the Teeth"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          double distance =
              details.delta.distance; 
          _increaseProgress(distance);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Swipe on teeth to clean them!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 600),
                      firstChild: Image.asset(
                        'assets/images/dirty_teeth.png',
                        width: screenWidth * 0.85,
                        fit: BoxFit.contain,
                      ),
                      secondChild: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          'assets/images/clean_teeth.png',
                          width: screenWidth * 0.85,
                          fit: BoxFit.contain,
                        ),
                      ),
                      crossFadeState: _isClean
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isClean)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Back to Dashboard"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
