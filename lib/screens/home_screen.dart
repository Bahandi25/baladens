import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_service.dart';
import '../services/ai_assistant_service.dart';
import 'lesson_screen.dart';
import 'hygiene_screen.dart';
import 'gym_screen.dart';
import 'ai_assistant_screen.dart';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'level_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _inactivityTimer;
  int _reminderCount = 0;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  void _showInactivityBanner() {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;

    Flushbar(
      title: "Don't Forget! 🧠",
      message: "It's time to learn something new. Tap a module to begin!",
      icon: const Icon(Icons.access_time, color: Colors.white),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.indigo.shade400,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
    ).show(context);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // очистим старый таймер
    _inactivityTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _showInactivityBanner();
    });
  }

  void _handleModuleTap(BuildContext context, String module) {
    final soundService = SoundService();
    soundService.playSound("button_click.mp3");

    _inactivityTimer?.cancel(); // остановить таймер

    int totalLevels;
    switch (module) {
      case "Gym":
        totalLevels = 12;
        break;
      case "Hygiene":
        totalLevels = 9;
        break;
      case "Healthy Food":
        totalLevels = 7;
        break;
      default:
        totalLevels = 0;
    }

    if (module != "More Soon") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => LevelSelectionScreen(
                module: module,
                totalLevels: totalLevels,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Will be available soon")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        "title": "Hygiene",
        "animation": "assets/animations/soap.json",
        "color": Colors.blueAccent,
      },
      {
        "title": "Gym",
        "animation": "assets/animations/gym.json",
        "color": Colors.pinkAccent,
      },
      {
        "title": "Healthy Food",
        "animation": "assets/animations/food.json",
        "color": Colors.orangeAccent,
      },
      {
        "title": "More Soon",
        "animation": "assets/animations/lock.json",
        "color": Colors.grey,
      },
    ];

    return Container(
      color: Colors.blue.shade50,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset('assets/animations/logo.gif', height: 100),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Explore Healthy Habits! 🌟",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // AI Assistant Widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.assistant, color: Colors.indigo.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Need help? Ask me anything about the modules!",
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AIAssistantScreen(),
                          ),
                        );
                      },
                      color: Colors.indigo.shade400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final cardSize = 240.0;

                  return Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children:
                          modules.map((m) {
                            return _HexagonCard(
                              title: m['title'] as String,
                              animation: m['animation'] as String,
                              color: m['color'] as Color,
                              onTap:
                                  () => _handleModuleTap(
                                    context,
                                    m['title'] as String,
                                  ),
                              size: cardSize,
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HexagonCard extends StatefulWidget {
  final String title;
  final String animation;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _HexagonCard({
    required this.title,
    required this.animation,
    required this.color,
    required this.onTap,
    this.size = 220,
  });

  @override
  State<_HexagonCard> createState() => _HexagonCardState();
}

class HexagonBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HexagonBorderPainter({required this.color, this.strokeWidth = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;
    final double centerY = h / 2;
    final double radius = w / 2;

    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i - pi / 2;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HexagonCardState extends State<_HexagonCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.05),
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 1.1),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Свечение за шестиугольником
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // Обводка-шестиугольник
              CustomPaint(
                size: Size(size, size),
                painter: HexagonBorderPainter(
                  color: Colors.white.withOpacity(0.5),
                  strokeWidth: 8,
                ),
              ),
              ClipPath(
                clipper: HexagonClipper(),
                child: Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        widget.color,
                        widget.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        offset: const Offset(4, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(widget.animation, height: size / 2.6),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  final double inset;

  HexagonClipper({this.inset = 0.0});

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    final double centerX = w / 2;
    final double centerY = h / 2;
    final double radius = w / 2 + inset;

    final Path path = Path();

    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i - pi / 2;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
