import 'package:tflite/tflite.dart';

class ModelService {
  static Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/models/trained_model.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  static Future<String> predictDisease(String imagePath) async {
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 3,
      threshold: 0.2,
    );

    if (output != null && output.isNotEmpty) {
      return output[0]['label'];
    }
    return "Unknown Disease";
  }
}
