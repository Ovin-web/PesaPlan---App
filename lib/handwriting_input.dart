import 'package:flutter/material.dart';
import 'package:google_mlkit_handwriting/google_mlkit_handwriting.dart';

class HandwritingInputPage extends StatefulWidget {
  @override
  _HandwritingInputPageState createState() => _HandwritingInputPageState();
}

class _HandwritingInputPageState extends State<HandwritingInputPage> {
  final HandwritingScanner _scanner = HandwritingScanner();
  String _recognizedText = "Write something...";

  void _recognizeTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _scanner.process(inputImage);
    setState(() {
      _recognizedText = result.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Handwriting Recognition")),
      body: Column(
        children: [
          Text(_recognizedText),
          ElevatedButton(
            onPressed: () {
              // Trigger camera or image picker to capture handwriting
            },
            child: Text('Capture Handwriting'),
          ),
        ],
      ),
    );
  }
}
