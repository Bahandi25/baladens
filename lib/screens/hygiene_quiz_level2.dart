import 'package:flutter/material.dart';
import 'hygiene_result.dart';

class HygieneLevelTwoScreen extends StatefulWidget {
  const HygieneLevelTwoScreen({super.key});

  @override
  State<HygieneLevelTwoScreen> createState() => _HygieneLevelTwoScreenState();
}

class _HygieneLevelTwoScreenState extends State<HygieneLevelTwoScreen> {
  final List<String> hygienicItems = ['🪥 Toothbrush', '🧼 Soap'];
  final List<String> unhygienicItems = ['🐞 Bug', '🗑️ Trash'];

  List<String> droppedHygienic = [];
  List<String> droppedUnhygienic = [];

  void onItemDropped(String item, bool isHygienicTarget) {
    setState(() {
      droppedHygienic.remove(item);
      droppedUnhygienic.remove(item);

      if (isHygienicTarget) {
        droppedHygienic.add(item);
      } else {
        droppedUnhygienic.add(item);
      }
    });
  }

  bool isAllCorrect() {
    return droppedHygienic.toSet().containsAll(hygienicItems) &&
        droppedUnhygienic.toSet().containsAll(unhygienicItems);
  }

  void checkResult() {
    final correct = isAllCorrect();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HygieneResultScreen(isCorrect: correct),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = hygienicItems + unhygienicItems;
    final draggedItems = droppedHygienic + droppedUnhygienic;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Hygiene Level 2"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Drag the items into the correct boxes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Drag sources
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: allItems
                  .where((item) => !draggedItems.contains(item))
                  .map((item) => Draggable<String>(
                        data: item,
                        feedback: _buildItemCard(item, isDragging: true),
                        childWhenDragging:
                            Opacity(opacity: 0.3, child: _buildItemCard(item)),
                        child: _buildItemCard(item),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 30),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropTargetBox("Hygienic ✅", droppedHygienic, true),
                _buildDropTargetBox("Unhygienic ❌", droppedUnhygienic, false),
              ],
            ),

            const SizedBox(height: 40),

            
            ElevatedButton.icon(
              onPressed: checkResult,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Check Result"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildItemCard(String item, {bool isDragging = false}) {
    return Card(
      color: isDragging ? Colors.white : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(item, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

 
  Widget _buildDropTargetBox(String title, List<String> items, bool isHygienic) {
    return DragTarget<String>(
      onAccept: (item) => onItemDropped(item, isHygienic),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 160,
          height: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              ...items.map((e) =>
                  Padding(padding: const EdgeInsets.only(top: 4), child: Text(e))),
            ],
          ),
        );
      },
    );
  }
}
