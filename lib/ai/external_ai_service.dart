import 'dart:convert';
import 'package:http/http.dart' as http;

class ExternalAiService {
  final String apiKey;

  ExternalAiService({required this.apiKey});

  // --------------------------------------------------
  // Generic LLM call (OpenAI / Gemini style)
  // --------------------------------------------------
  Future<String?> getAiResponse({
    required String userMessage,
    required String context,
  }) async {
    // ⚠️ Replace URL when switching providers
    const String endpoint =
        'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a smart financial planning assistant.',
            },
            {
              'role': 'system',
              'content': context,
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'temperature': 0.4,
        }),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content'];
    } catch (e) {
      // Network / API error
      return null;
    }
  }
}
