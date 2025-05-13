import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleModuleTap(BuildContext context, String module) {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    if (module == "Healthy Food") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LessonScreen()));
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
          const Text("What We Will Learn Today?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildModuleCard(context, "Hygiene", Colors.blue),
                _buildModuleCard(context, "Gym", Colors.red),
                _buildModuleCard(context, "Healthy Food", Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () => _handleModuleTap(context, title),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
