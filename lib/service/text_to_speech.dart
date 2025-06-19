import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ElevenLabsTTS {
  final String apiKey;
  final String voiceId;

  ElevenLabsTTS({required this.apiKey, required this.voiceId});

  Future<Uint8List?> synthesize(String text) async {
    final url = Uri.parse(
      'https://api.elevenlabs.io/v1/text-to-speech/$voiceId',
    );
    final response = await http.post(
      url,
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: jsonEncode({
        'text': text,
        'model_id': 'eleven_multilingual_v2', // or another model if you prefer
        'voice_settings': {'stability': 0.5, 'similarity_boost': 0.5},
      }),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('TTS failed: ${response.statusCode} ${response.body}');
      return null;
    }
  }
}
