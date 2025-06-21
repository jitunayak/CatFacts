import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class TTSResponse {
  final Uint8List? data;
  final int statusCode;
  final String? errorMessage;

  TTSResponse({this.data, required this.statusCode, this.errorMessage});

  bool get success => statusCode == 200 && data != null;
}

class ElevenLabsTTS {
  final String apiKey;
  final String voiceId;

  ElevenLabsTTS({required this.apiKey, required this.voiceId});

  Future<TTSResponse> synthesize(String text) async {
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
      return TTSResponse(
        data: response.bodyBytes,
        statusCode: response.statusCode,
      );
    } else {
      print('TTS failed: ${response.statusCode} ${response.body}');
      String? errorMessage = response.body;
      try {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('detail')) {
          final detail = decodedBody['detail'];
          if (detail is Map<String, dynamic> && detail.containsKey('message')) {
            errorMessage = detail['message'];
          } else if (detail is String) {
            errorMessage = detail;
          }
        }
      } catch (e) {
        // Not a JSON response, or unexpected format. Use the raw body.
      }
      return TTSResponse(
        statusCode: response.statusCode,
        errorMessage: errorMessage,
      );
    }
  }
}
