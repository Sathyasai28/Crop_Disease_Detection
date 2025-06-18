import 'dart:convert';
import 'package:flutter/services.dart';

class ChatbotService {
  static Map<String, String> _responses = {};

  static Future<void> loadResponses() async {
    String jsonString = await rootBundle.loadString('assets/chatbot_data/chatbot_responses.json');
    _responses = Map<String, String>.from(json.decode(jsonString));
  }

  static String getResponse(String query) {
    return _responses[query.toLowerCase()] ?? "Sorry, I don't understand.";
  }
}
