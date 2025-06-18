import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'telugu_keyboard.dart'; // Import the Telugu keyboard

class DiseaseRecognitionPage extends StatefulWidget {
  const DiseaseRecognitionPage({Key? key}) : super(key: key);

  @override
  _DiseaseRecognitionPageState createState() => _DiseaseRecognitionPageState();
}

class _DiseaseRecognitionPageState extends State<DiseaseRecognitionPage> {
  Uint8List? _webImageBytes; 
  File? _mobileImageFile; 
  bool _isLoading = false;
  String _prediction = ""; 
  String _confidence = ""; 
  List<Map<String, String>> _top3Predictions = []; 
  final ImagePicker _picker = ImagePicker();
  bool _showChat = false;
  
  // Chat-related variables
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isChatLoading = false;
  final ScrollController _scrollController = ScrollController();
  
  // Telugu keyboard variables
  bool _showTeluguKeyboard = false;

// final String backendUrl = 'https://4561-2401-4900-2080-68f9-a4fe-ef26-7371-2cb.ngrok-free.app/predict';
// final String chatUrl = 'https://4561-2401-4900-2080-68f9-a4fe-ef26-7371-2cb.ngrok-free.app/chat';

final String backendUrl = 'https://ww-heavy-portugal-shaved.trycloudflare.com/predict';
final String chatUrl = 'https://ww-heavy-portugal-shaved.trycloudflare.com/chat';


  @override
  void initState() {
    super.initState();
    _testApiConnection(); 
  }

  void _testApiConnection() async {
    try {
      var response = await http.get(Uri.parse("https://ww-heavy-portugal-shaved.trycloudflare.com/"));
      // var response = await http.get(Uri.parse("http://127.0.0.1:5000/"));
      print("🔥 Flask API Test Response: ${response.body}");
    } catch (e) {
      print("❌ Error connecting to API: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
          _prediction = "";
          _confidence = "";
          _top3Predictions = [];
          _showChat = false;
          _messages.clear();
        });

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          _webImageBytes = bytes;
          _mobileImageFile = null;
          await _predictDiseaseWeb(bytes);
        } else {
          _mobileImageFile = File(pickedFile.path);
          _webImageBytes = null;
          await _predictDiseaseMobile(File(pickedFile.path));
        }
      }
    } catch (e) {
      _showError("⚠ Failed to select image: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _predictDiseaseWeb(Uint8List imageBytes) async {
    try {
      print("🔄 Sending image to backend (Web)...");

      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'file', imageBytes, 
        filename: "image.jpg",
      ));

      var response = await request.send();
      await _handleResponse(response);
    } catch (e) {
      _showError("❌ Error predicting disease (Web): $e");
    }
  }

  Future<void> _predictDiseaseMobile(File imageFile) async {
    try {
      print("📷 Sending image to backend (Mobile)...");

      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      await _handleResponse(response);
    } catch (e) {
      _showError("❌ Error predicting disease (Mobile): $e");
    }
  }

  Future<void> _handleResponse(http.StreamedResponse response) async {
    print("📡 Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print("✅ Raw Response Data: $responseData");

      try {
        var jsonData = json.decode(responseData);
        print("✅ Parsed JSON: $jsonData");

        setState(() {
          _prediction = jsonData['prediction'] ?? "Unknown";
          _confidence = jsonData['confidence'] ?? "0%";
          _top3Predictions = (jsonData['top_3_predictions'] as List?)
              ?.map((e) => {
                    "disease": e['class_name'].toString(),
                    "confidence": e['confidence'].toString(),
                  })
              .toList() ??
              [];
        });

        print("🔹 Final Prediction: $_prediction");
        print("🔹 Confidence: $_confidence");
        print("🔹 Top 3 Predictions: $_top3Predictions");
        
      } catch (e) {
        _showError("❌ Error parsing JSON: $e");
      }
    } else {
      print("❌ Failed to predict disease. Status Code: ${response.statusCode}");
      _showError("Failed to predict disease. Please check the backend.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Chat-related methods
  void _toggleChat() {
    setState(() {
      _showChat = !_showChat;
      if (_showChat && _messages.isEmpty && _prediction.isNotEmpty) {
        _addSystemMessage("I've identified your plant may have $_prediction. What would you like to know about this disease?");
      }
    });
  }

  void _scrollToBottom() {
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

  // Telugu keyboard handling
  void _handleKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_messageController.text.isNotEmpty) {
          final currentText = _messageController.text;
          _messageController.text = currentText.substring(0, currentText.length - 1);
        }
      } else {
        final currentText = _messageController.text;
        final selection = _messageController.selection;
        
        // Insert the key at the current cursor position
        if (selection.isValid) {
          final newText = currentText.substring(0, selection.start) + 
                          key + 
                          currentText.substring(selection.end);
          _messageController.text = newText;
          // Move cursor position after the inserted character
          _messageController.selection = TextSelection.collapsed(
            offset: selection.start + key.length,
          );
        } else {
          // If no valid selection, append to the end
          _messageController.text = currentText + key;
        }
      }
    });
  }

  void _toggleTeluguKeyboard() {
    setState(() {
      _showTeluguKeyboard = !_showTeluguKeyboard;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final String messageText = _messageController.text;
    
    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isUser: true,
      ));
      _isChatLoading = true;
      _messageController.clear();
    });
    
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': messageText,
          'disease': _prediction,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(ChatMessage(
            text: data['response'] ?? "Sorry, I couldn't get information about that.",
            isUser: false,
          ));
        });
      } else {
        _showError("Failed to get response from the server");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() {
        _isChatLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _addSystemMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        isSystem: true,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Recognition"),
        actions: [
          if (_prediction.isNotEmpty)
            IconButton(
              icon: Icon(_showChat ? Icons.image : Icons.chat),
              tooltip: _showChat ? "View Image" : "Ask About Disease",
              onPressed: _toggleChat,
            ),
        ],
      ),
      body: _showChat && _prediction.isNotEmpty
          ? _buildChatInterface()
          : _buildImageInterface(),
    );
  }
  
  Widget _buildImageInterface() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_mobileImageFile == null && _webImageBytes == null)
          const Expanded(
            child: Center(
              child: Text("No image selected", style: TextStyle(fontSize: 18)),
            ),
          )
        else if (kIsWeb)
          Expanded(child: Image.memory(_webImageBytes!, fit: BoxFit.contain))
        else
          Expanded(child: Image.file(_mobileImageFile!, fit: BoxFit.contain)),

        const SizedBox(height: 20),

        if (_isLoading)
          const CircularProgressIndicator()
        else if (_prediction.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
            children: [
              Text("🌿 Disease: $_prediction", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center), // Added text alignment
              Text("📊 Confidence: $_confidence", 
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center), // Added text alignment
              const SizedBox(height: 10),
              if (_top3Predictions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
                  children: [
                    const Text("Top Predictions:", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center), // Added text alignment
                    const SizedBox(height: 5),
                    ...(_top3Predictions
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                "🔎 ${e['disease']} - ${e['confidence']}",
                                textAlign: TextAlign.center, // Added text alignment
                              ),
                            ))
                        .toList()),
                  ],
                ),
              if (_prediction.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: _toggleChat,
                    icon: const Icon(Icons.chat),
                    label: const Text("Ask about this disease"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

        const SizedBox(height: 20),

        // Removed the camera button, keeping only the gallery button
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.image),
          label: const Text("Select Image"),
        ),
      ],
    ),
  );
}
  
  Widget _buildChatInterface() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleChat,
                tooltip: "Back to image",
              ),
              Expanded(
                child: Text(
                  "Chat about $_prediction",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              // Add Telugu keyboard toggle button
              IconButton(
                icon: Icon(_showTeluguKeyboard ? Icons.keyboard_hide : Icons.language),
                onPressed: _toggleTeluguKeyboard,
                tooltip: _showTeluguKeyboard ? "Hide Telugu Keyboard" : "Show Telugu Keyboard",
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _messages[index];
            },
          ),
        ),
        if (_isChatLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Ask a question about the disease...",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Colors.green,
              ),
            ],
          ),
        ),
        // Show Telugu keyboard when toggled
        if (_showTeluguKeyboard)
          Container(
            color: Colors.grey[200],
            child: TeluguKeyboard(onKeyTap: _handleKeyTap),
          ),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isSystem;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    this.isSystem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) 
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: isSystem ? Colors.green[200] : Colors.blue[200],
                child: Icon(
                  isSystem ? Icons.eco : Icons.smart_toy,
                  color: isSystem ? Colors.green[900] : Colors.blue[900],
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : (isSystem ? Colors.green[50] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(text),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}