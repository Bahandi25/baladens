import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../services/firestore_service.dart';
import 'gym_quiz.dart';
import 'hygiene_quiz.dart';
import 'lesson_screen.dart';

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
  bool _isModuleUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadLevelProgress();
  }

  Future<void> _loadLevelProgress() async {
    // Initialize level completion status
    _levelCompletion = List.filled(widget.totalLevels, false);

    // Load progress from Firestore
    String moduleId = widget.module.toLowerCase().replaceAll(' ', '_');
    int progress = await _firestoreService.getUserProgress(moduleId);
    bool isUnlocked = await _firestoreService.isModuleUnlocked(moduleId);

    setState(() {
      // Calculate completed levels based on progress
      int completedLevels = (progress / 100 * widget.totalLevels).floor();
      for (int i = 0; i < _levelCompletion.length; i++) {
        _levelCompletion[i] = i < completedLevels;
      }
      // Only the next level after the last completed one is unlocked
      _highestUnlockedLevel =
          completedLevels < widget.totalLevels
              ? completedLevels + 1
              : widget.totalLevels;
      _isModuleUnlocked = isUnlocked;
    });
  }

  Future<void> _tryUnlockModule() async {
    String moduleId = widget.module.toLowerCase().replaceAll(' ', '_');
    bool success = await _firestoreService.unlockModule(moduleId);

    if (success) {
      setState(() {
        _isModuleUnlocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Module unlocked successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Not enough coins! You need 20 coins to unlock this module.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLevel(int level) {
    _soundService.playSound("button_click.mp3");

    if (!_isModuleUnlocked && widget.module == "Gym") {
      _tryUnlockModule();
      return;
    }

    // For now, we'll use the existing quiz screens for level 1
    if (level == 1) {
      switch (widget.module) {
        case 'Gym':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GymQuizScreen()),
          );
          break;
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
    }
    // For other levels, we'll show a "Coming Soon" message
    else {
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
              if (!_isModuleUnlocked && widget.module == "Gym")
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade300),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/coin.png', width: 32, height: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Locked Module",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Unlock this module for 20 coins",
                              style: TextStyle(color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _tryUnlockModule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Unlock"),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
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
