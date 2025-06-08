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
      if (widget.module == 'Gym') {
        _highestUnlockedLevel = widget.totalLevels;
      } else {
        _highestUnlockedLevel =
            completedLevels < widget.totalLevels
                ? completedLevels + 1
                : widget.totalLevels;
      }
    });
  }

  void _navigateToLevel(int level) {
    _soundService.playSound("button_click.mp3");

    if (widget.module == 'Gym') {
      switch (level) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymLevel1Screen()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymLevel2Screen()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymLevel3Screen()),
          );
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymLevel4Screen()),
          );
          break;
        case 5:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymLevel5Screen()),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This level will be available soon!"),
              duration: Duration(seconds: 2),
            ),
          );
      }
      return;
    }

    if (level == 1) {
      switch (widget.module) {
        case 'Hygiene':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HygieneQuizScreen()),
          );
          break;
        case 'Healthy Food':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LessonScreen()),
          );
          break;
      }
    } else if (level == 2 && widget.module == 'Healthy Food') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizScreenLevel2()),
      );
    } else if (level == 3 && widget.module == 'Healthy Food') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizScreenLevel3()),
      );
    } else if (level == 4 && widget.module == 'Healthy Food') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizScreenLevel4()),
      );
    } else if (level == 5 && widget.module == 'Healthy Food') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizScreenLevel5()),
      );
    } else if (level == 2 && widget.module == 'Hygiene') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HygieneLevelTwoScreen()),
      );
    } else if (level == 3 && widget.module == 'Hygiene') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HygieneTapToRemoveScreen(),
        ),
      );
    } else if (level == 4 && widget.module == 'Hygiene') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ToothbrushGameScreen()),
      );
    } else if (level == 5 && widget.module == 'Hygiene') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HygienePuzzleLevel5Screen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This level will be available soon!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
          color:
              isLocked
                  ? Colors.grey.shade300
                  : isCompleted
                  ? Colors.lightGreen.shade200
                  : Colors.purple.shade100,
          shape: BoxShape.rectangle,
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
                      color:
                          isCompleted
                              ? Colors.green.shade800
                              : Colors.purple.shade800,
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
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
                  itemBuilder:
                      (context, index) => _buildHexagonLevel(index + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
