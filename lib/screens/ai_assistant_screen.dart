import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';
import '../services/sound_service.dart';
import 'level_selection_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  final AIAssistantService _aiService = AIAssistantService();
  final SoundService _soundService = SoundService();
  bool _isLoading = false;
  String _responseMessage = '';
  List<String> _suggestedModules = [];

  Future<void> _processQuery() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _responseMessage = '';
      _suggestedModules = [];
    });

    try {
      final result = await _aiService.processUserQuery(_queryController.text);

      setState(() {
        _responseMessage = result['message'];
        _suggestedModules = List<String>.from(result['suggestedModules']);
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToModule(String module) {
    _soundService.playSound("button_click.mp3");

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                LevelSelectionScreen(module: module, totalLevels: totalLevels),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'Ask about any module or feature...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading ? null : _processQuery,
                  ),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_responseMessage.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _responseMessage,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (_suggestedModules.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Suggested Modules:',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _suggestedModules.map((module) {
                                  return InkWell(
                                    onTap: () => _navigateToModule(module),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.purple.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            module,
                                            style: TextStyle(
                                              color: Colors.purple.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 16,
                                            color: Colors.purple.shade800,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
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

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
