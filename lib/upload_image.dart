import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  String prediction = "";
  String confidence = "";

  void uploadImage() async {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((event) async {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;

        final url = Uri.parse("http://127.0.0.1:5000/predict");
        var request = http.MultipartRequest("POST", url);
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          reader.result as List<int>,
          filename: file.name,
        ));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(responseData);
          setState(() {
            prediction = jsonResponse['prediction'];
            confidence = jsonResponse['confidence'];
          });
        } else {
          print("Error: ${json.decode(responseData)['error']}");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plant Disease Detector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: uploadImage,
              child: Text("Upload Image"),
            ),
            SizedBox(height: 20),
            Text("Prediction: $prediction", style: TextStyle(fontSize: 18)),
            Text("Confidence: $confidence", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
