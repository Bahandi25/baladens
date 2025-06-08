import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../services/firestore_service.dart';
import 'gym_quiz.dart';
import 'hygiene_quiz.dart';
import 'lesson_screen.dart';
import 'quiz_screen_level2.dart';
import 'quiz_screen_level3.dart';
import 'quiz_screen_level4.dart';
import 'quiz_screen_level5.dart';
import 'quiz_screen_level6.dart';
import 'quiz_screen_level7.dart';
import 'hygiene_quiz_level2.dart';
import 'hygiene_quiz_level3.dart';
import 'hygiene_quiz_level4.dart';
import 'hygiene_quiz_level5.dart';
import 'gym_level1.dart';
import 'gym_level2.dart';
import 'gym_level3.dart';
import 'gym_level4.dart';
import 'gym_level5.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String module;
  final int totalLevels;

  const LevelSelectionScreen({
    super.key,
    required this.module,
    required this.totalLevels,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();
  List<bool> _levelCompletion = [];
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadLevelProgress();
  }

  Future<void> _loadLevelProgress() async {
    _levelCompletion = List.filled(widget.totalLevels, false);
    String moduleId = widget.module.toLowerCase().replaceAll(' ', '_');
    int progress = await _firestoreService.getUserProgress(moduleId);

    setState(() {
      int completedLevels = (progress / 100 * widget.totalLevels).floor();
      for (int i = 0; i < _levelCompletion.length; i++) {
        _levelCompletion[i] = i < completedLevels;
      }
      _highestUnlockedLevel =
          completedLevels < widget.totalLevels ? completedLevels + 1 : widget.totalLevels;
    });
  }

  void _navigateToLevel(int level) {
    _soundService.playSound("button_click.mp3");

    if (widget.module == 'Gym') {
      switch (level) {
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GymLevel1Screen()));
          return;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GymLevel2Screen()));
          return;
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GymLevel3Screen()));
          return;
        case 4:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GymLevel4Screen()));
          return;
        case 5:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GymLevel5Screen()));
          return;
        default:
          _showComingSoon();
          return;
      }
    }

    if (widget.module == 'Healthy Food') {
      switch (level) {
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonScreen()));
          return;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel2()));
          return;
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel3()));
          return;
        case 4:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel4()));
          return;
        case 5:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel5()));
          return;
        case 6:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel6()));
          return;
        case 7:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreenLevel7()));
          return;
        default:
          _showComingSoon();
          return;
      }
    }

    if (widget.module == 'Hygiene') {
      switch (level) {
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HygieneQuizScreen()));
          return;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HygieneLevelTwoScreen()));
          return;
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HygieneTapToRemoveScreen()));
          return;
        case 4:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ToothbrushGameScreen()));
          return;
        case 5:
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HygienePuzzleLevel5Screen()));
          return;
        default:
          _showComingSoon();
          return;
      }
    }

    _showComingSoon();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("This level will be available soon!"),
      duration: Duration(seconds: 2),
    ));
  }

  Widget _buildHexagonLevel(int level) {
    bool isCompleted = _levelCompletion[level - 1];
    bool isLocked = level > _highestUnlockedLevel;

    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToLevel(level),
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey.shade300
              : isCompleted
                  ? Colors.lightGreen.shade200
                  : Colors.purple.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLocked)
              const Icon(Icons.lock, color: Colors.grey, size: 24)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green.shade800 : Colors.purple.shade800,
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.module} Levels'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Complete levels to unlock new challenges!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: widget.totalLevels,
                  itemBuilder: (context, index) => _buildHexagonLevel(index + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
