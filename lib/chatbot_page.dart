import 'package:flutter/material.dart';
import 'disease_data.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  String? _selectedDisease;
  String? _selectedOption;

  void _showOptionsDialog() {
    if (_selectedDisease == null) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select an option for more information:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text("Prevention Mechanism"),
                onTap: () => _showInfo("Prevention"),
              ),
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text("Causes"),
                onTap: () => _showInfo("Causes"),
              ),
              ListTile(
                leading: const Icon(Icons.grass),
                title: const Text("Fertilizers to be Used"),
                onTap: () => _showInfo("Fertilizers"),
              ),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text("Treatment Methods"),
                onTap: () => _showInfo("Treatment"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfo(String option) {
    if (_selectedDisease != null) {
      String info = diseaseData[_selectedDisease!]?[option] ?? "No information available.";
      setState(() {
        _selectedOption = "$option: $info";
      });
      Navigator.of(context).pop(); // Close bottom sheet safely
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Disease Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select the detected disease:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedDisease,
              hint: const Text("Choose a disease"),
              isExpanded: true,
              items: diseaseData.keys.map((disease) {
                return DropdownMenuItem<String>(
                  value: disease,
                  child: Text(disease),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDisease = value;
                  _selectedOption = null;
                });
                _showOptionsDialog();
              },
            ),
            const SizedBox(height: 20),
            _selectedOption != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _selectedOption!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : const Text(
                    "Select a disease and choose an option to view information.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}
