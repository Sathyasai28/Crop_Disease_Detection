import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'chatbot_page.dart'; // ✅ Correct import for ChatbotPage
import 'package:flutter_markdown/flutter_markdown.dart';


class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  Map<String, String> _responses = {};
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatbotResponses();
  }

  // Load chatbot responses from JSON
  Future<void> _loadChatbotResponses() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/chatbot_data/chatbot_responses.json');
      setState(() {
        _responses = Map<String, String>.from(json.decode(jsonString));
      });
    } catch (e) {
      debugPrint("Error loading chatbot responses: $e");
    }
  }

  // Handle user input and bot response
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return; // Prevent empty messages

    setState(() {
      _messages.add({"user": message});
      _isBotTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate bot delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        String response = _responses[message.toLowerCase()] ??
            "I'm not sure about that. Try asking something else!";
        _messages.add({"bot": response});
        _isBotTyping = false;
      });
      _scrollToBottom();
    });
  }

  // Auto-scroll to the latest message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                bool isUser = message.keys.first == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[300] : Colors.green[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.values.first,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bot typing indicator
          if (_isBotTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Bot is typing...", style: TextStyle(color: Colors.grey)),
            ),

          // User input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_controller.text),
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
