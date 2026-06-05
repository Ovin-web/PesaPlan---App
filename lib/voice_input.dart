import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputPage extends StatefulWidget {
  @override
  _VoiceInputPageState createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Press the button and speak";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
    }
  }

  void _startListening() async {
    await _speech.listen(onResult: (result) {
      setState(() {
        _text = result.recognizedWords;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Input')),
      body: Column(
        children: [
          Text(_text),
          ElevatedButton(
            onPressed: _startListening,
            child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
          ),
        ],
      ),
    );
  }
}
