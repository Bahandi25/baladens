import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_service.dart';
import 'hygiene_result.dart';

class HygienePuzzleLevel5Screen extends StatefulWidget {
  const HygienePuzzleLevel5Screen({super.key});

  @override
  State<HygienePuzzleLevel5Screen> createState() => _HygienePuzzleLevel5ScreenState();
}

class _HygienePuzzleLevel5ScreenState extends State<HygienePuzzleLevel5Screen> {
  final SoundService _soundService = SoundService();

  List<String> pieces = List.generate(9, (index) => 'puzzle/${index + 1}.png');
  late List<String> shuffledPieces;

  @override
  void initState() {
    super.initState();
    shuffledPieces = List.from(pieces);
    shuffledPieces.shuffle();
  }

  void swap(int fromIndex, int toIndex) {
    setState(() {
      final temp = shuffledPieces[fromIndex];
      shuffledPieces[fromIndex] = shuffledPieces[toIndex];
      shuffledPieces[toIndex] = temp;
    });
  }

  bool get isCorrect {
    for (int i = 0; i < pieces.length; i++) {
      if (shuffledPieces[i] != pieces[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width * 0.9;
    double tileSize = gridSize / 3 - 8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Lottie.asset("animations/puzzle.json", height: 150),
                const SizedBox(height: 16),
                const Text(
                  "Arrange the puzzle pieces!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Container(
                  width: gridSize,
                  height: gridSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return Draggable<int>(
                            data: index,
                            feedback: _buildTile(shuffledPieces[index], tileSize, dragging: true),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildTile(shuffledPieces[index], tileSize),
                            ),
                            child: _buildTile(shuffledPieces[index], tileSize),
                          );
                        },
                        onAccept: (fromIndex) {
                          swap(fromIndex, index);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _soundService.playSound("button_click.mp3");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HygieneResultScreen(isCorrect: isCorrect),
                      ),
                    );
                  },
                  child: const Text(
                    "Check Result",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String imgPath, double size, {bool dragging = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.cover,
        ),
        boxShadow: dragging
            ? []
            : [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                )
              ],
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
