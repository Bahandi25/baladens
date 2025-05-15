import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HygieneScreen extends StatelessWidget {
  const HygieneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hygiene Tips"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Center(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animations/hand_wash.json',
                    height: 220,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Let’s Learn About Hygiene!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Hygiene keeps us safe and healthy. Tap on the tips below to learn more!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const HygieneCard(
              title: "Wash Your Hands",
              description: "Always wash hands for 20 seconds with soap and water.",
              animationPath: "assets/animations/soap.lottie",
            ),
            const HygieneCard(
              title: "Don’t Touch Your Face",
              description: "Avoid touching eyes, nose, and mouth with unwashed hands.",
              animationPath: "assets/animations/no_touch.lottie",
            ),
            const HygieneCard(
              title: "Wear a Mask",
              description: "Masks help stop the spread of germs.",
              animationPath: "assets/animations/mask.lottie",
            ),
            const HygieneCard(
              title: "Brush Your Teeth",
              description: "Brush twice a day for a bright, healthy smile!",
              animationPath: "assets/animations/brush_teeth.lottie",
            ),
          ],
        ),
      ),
    );
  }
}

class HygieneCard extends StatelessWidget {
  final String title;
  final String description;
  final String animationPath;

  const HygieneCard({
    super.key,
    required this.title,
    required this.description,
    required this.animationPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Lottie.asset(animationPath, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
