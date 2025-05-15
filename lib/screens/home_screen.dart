import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import 'lesson_screen.dart';
import 'hygiene_screen.dart';  // импорт HygieneScreen

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What We Will Learn Today? 📚",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildModuleCard(
                  context,
                  "Hygiene",
                  const [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  Icons.shield,
                ),
                _buildModuleCard(
                  context,
                  "Gym",
                  const [Color(0xFFE94E77), Color(0xFFD43F61)],
                  Icons.fitness_center,
                ),
                _buildModuleCard(
                  context,
                  "Healthy Food",
                  const [Color(0xFFF5A623), Color(0xFFE68400)],
                  Icons.restaurant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
      BuildContext context, String title, List<Color> colors, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleModuleTap(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
