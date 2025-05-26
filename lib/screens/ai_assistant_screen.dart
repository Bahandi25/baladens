import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  final AIAssistantService _aiService = AIAssistantService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Ask about any module or feature...',
                border: const OutlineInputBorder(),
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
            else if (_responseMessage.isNotEmpty) ...[
              Card(
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _suggestedModules.map((module) {
                                return Chip(
                                  label: Text(module),
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
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
