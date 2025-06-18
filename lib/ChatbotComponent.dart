import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'telugu_keyboard.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  final String diseasePrediction;

  const ChatbotPage({Key? key, required this.diseasePrediction}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final String backendUrl = 'http://127.0.0.1:5000/chat';

  @override
  void initState() {
    super.initState();
    _addBotMessage("I detected ${widget.diseasePrediction}. What would you like to know about this disease?");
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text) {
    _addMessage(text, false);
  }

  void _addUserMessage(String text) {
    _addMessage(text, true);
  }

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    if (text.trim().isEmpty) return;

    _addUserMessage(text);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': text,
          'disease': widget.diseasePrediction,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _addBotMessage(responseData['response']);
      } else {
        _addBotMessage("Sorry, I couldn't process your request. Please try again.");
      }
    } catch (e) {
      _addBotMessage("Network error. Please check your connection and try again.");
      print("Error sending message to chatbot: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTeluguKeyTap(String char) {
    final currentText = _textController.text;
    if (char == '⌫') {
      if (currentText.isNotEmpty) {
        _textController.text = currentText.substring(0, currentText.length - 1);
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    } else {
      _textController.text += char;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Assistant"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) {
                ChatMessage message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          const Divider(height: 1.0),
          _buildTextComposer(),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(message.text),
                ),
              ],
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _isLoading ? null : _handleSubmitted,
                  decoration: const InputDecoration(
                    hintText: "Ask something about the disease...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ],
          ),
        ),
        TeluguKeyboard(onKeyTap: _onTeluguKeyTap),
      ],
    );
  }
}
