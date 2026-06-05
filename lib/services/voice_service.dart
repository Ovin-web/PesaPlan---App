import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;

  // --------------------------------------------------
  // Initialize voice services
  // --------------------------------------------------
  Future<void> initialize() async {
    if (_initialized) return;

    await _speech.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _initialized = true;
  }

  // --------------------------------------------------
  // Start listening
  // --------------------------------------------------
  Future<String> listen() async {
    if (!_initialized) {
      await initialize();
    }

    String recognizedText = '';

    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
    );

    // Listen for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    await _speech.stop();

    return recognizedText.toLowerCase();
  }

  // --------------------------------------------------
  // Speak response
  // --------------------------------------------------
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
