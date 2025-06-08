import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_service.dart';
import 'hygiene_result.dart';

class HygieneTapToRemoveScreen extends StatefulWidget {
  const HygieneTapToRemoveScreen({super.key});

  @override
  State<HygieneTapToRemoveScreen> createState() => _HygieneTapToRemoveScreenState();
}

class _HygieneTapToRemoveScreenState extends State<HygieneTapToRemoveScreen> {
  final SoundService _soundService = SoundService();
  final List<String> microbes = ['germ', 'virus', 'germ', 'virus', 'germ'];
  final Set<int> removed = {};

  void _removeMicrobe(int index) {
    if (!removed.contains(index)) {
      _soundService.playSound("pop.mp3");
      setState(() {
        removed.add(index);
      });
    }
  }

  void _checkResult() {
    bool allRemoved = removed.length == microbes.length;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HygieneResultScreen(isCorrect: allRemoved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("Tap to Remove Germs"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Tap all the germs and viruses to clean the screen!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: microbes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                if (removed.contains(index)) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () => _removeMicrobe(index),
                  child: Lottie.asset(
                    'assets/animations/${microbes[index]}.json',
                    repeat: true,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _checkResult,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.green.shade600,
              ),
              child: const Text(
                "Check Result",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
