import 'dart:convert';
import 'package:flutter/material.dart';

class AIAssistantService {
  static const List<String> validModules = ['Healthy Food', 'Hygiene', 'Gym'];

  Future<Map<String, dynamic>> processUserQuery(String query) async {
    try {
      if (!_isAppropriateQuery(query)) {
        return {
          'success': false,
          'message':
              'Please rephrase your question to be more specific about the module or feature you need help with.',
          'suggestedModules': [],
        };
      }

      final lowercaseQuery = query.toLowerCase();
      List<String> suggestedModules = [];
      String message = '';

      if (lowercaseQuery.contains('muscle') ||
          lowercaseQuery.contains('gym') ||
          lowercaseQuery.contains('exercise') ||
          lowercaseQuery.contains('workout') ||
          lowercaseQuery.contains('fitness') ||
          lowercaseQuery.contains('strong') ||
          lowercaseQuery.contains('thin') ||
          lowercaseQuery.contains('build')) {
        suggestedModules.add('Gym');
        message =
            'To build muscles and get stronger, I recommend starting with the Gym module. It will teach you proper exercise techniques and help you develop a fitness routine suitable for muscle building.';

        if (lowercaseQuery.contains('thin') ||
            lowercaseQuery.contains('food') ||
            lowercaseQuery.contains('eat') ||
            lowercaseQuery.contains('diet')) {
          suggestedModules.add('Healthy Food');
          message +=
              ' Additionally, proper nutrition is crucial for muscle growth, so you might want to check out the Healthy Food module as well.';
        }
      }
      else if (lowercaseQuery.contains('food') ||
          lowercaseQuery.contains('eat') ||
          lowercaseQuery.contains('diet') ||
          lowercaseQuery.contains('healthy') ||
          lowercaseQuery.contains('fast food')) {
        suggestedModules.add('Healthy Food');
        message =
            'Based on your question about food and healthy eating, I recommend starting with the Healthy Food module. It will teach you about balanced nutrition and making better food choices.';
      }

      if (lowercaseQuery.contains('clean') ||
          lowercaseQuery.contains('wash') ||
          lowercaseQuery.contains('hygiene') ||
          lowercaseQuery.contains('health')) {
        suggestedModules.add('Hygiene');
        if (message.isEmpty) {
          message =
              'Good hygiene is essential for overall health. The Hygiene module will help you learn about proper personal care and cleanliness habits.';
        } else {
          message +=
              ' Don\'t forget that good hygiene is also important for your overall health and well-being.';
        }
      }

      if (suggestedModules.isEmpty) {
        message =
            'I understand you want to improve your health. I recommend starting with the Healthy Food module to learn about proper nutrition, and then exploring the Gym module for physical activity.';
        suggestedModules.addAll(['Healthy Food', 'Gym']);
      }

      return {
        'success': true,
        'message': message,
        'suggestedModules': suggestedModules,
      };
    } catch (e) {
      debugPrint('Error processing AI query: $e');
      return {
        'success': false,
        'message':
            'Sorry, I encountered an error while processing your request. Please try again.',
        'suggestedModules': [],
      };
    }
  }

  bool _isAppropriateQuery(String query) {
    final inappropriateWords = ['inappropriate', 'offensive', 'explicit'];
    final lowercaseQuery = query.toLowerCase();

    if (inappropriateWords.any((word) => lowercaseQuery.contains(word))) {
      return false;
    }

    if (query.length < 3 || query.length > 500) {
      return false;
    }

    final healthRelatedWords = [
      'health',
      'healthy',
      'food',
      'eat',
      'diet',
      'exercise',
      'gym',
      'fitness',
      'clean',
      'wash',
      'hygiene',
      'help',
      'how',
      'what',
      'where',
      'when',
      'why',
      'learn',
      'want',
      'need',
      'muscle',
      'strong',
      'build',
      'thin',
      'workout',
    ];
    return healthRelatedWords.any((word) => lowercaseQuery.contains(word));
  }
}
