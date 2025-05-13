import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'lesson_screen.dart';

class LessonLoadingScreen extends StatefulWidget {
  const LessonLoadingScreen({super.key});

  @override
  State<LessonLoadingScreen> createState() => _LessonLoadingScreenState();
}

class _LessonLoadingScreenState extends State<LessonLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LessonScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/loading.json', height: 150),
            const SizedBox(height: 20),
            const Text("Loading lesson...", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}
