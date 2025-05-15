import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_service.dart';
import 'lesson_screen.dart';
import 'hygiene_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleModuleTap(BuildContext context, String module) {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    if (module == "Healthy Food") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LessonScreen()));
    } else if (module == "Hygiene") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HygieneScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Will be available soon"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What Will We Learn Today? 📚",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85, 
                  children: [
                    _buildModuleCard(
                      context,
                      title: "Hygiene",
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      animation: "assets/animations/soap.json",
                    ),
                    _buildModuleCard(
                      context,
                      title: "Gym",
                      colors: [Color(0xFFE94E77), Color(0xFFD43F61)],
                      animation: "assets/animations/gym.json",
                    ),
                    _buildModuleCard(
                      context,
                      title: "Healthy Food",
                      colors: [Color(0xFFF5A623), Color(0xFFE68400)],
                      animation: "assets/animations/food.json",
                    ),
                    _buildModuleCard(
                      context,
                      title: "More Soon",
                      colors: [Color(0xFF7B8D93), Color(0xFF5A6D72)],
                      animation: "assets/animations/lock.json",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required List<Color> colors,
    required String animation,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleModuleTap(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(animation, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
