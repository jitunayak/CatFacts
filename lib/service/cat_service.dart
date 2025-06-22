import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CatService {
  final client = HttpClient(); // Create an HttpClient instance

  Uint8List? _imageBytes;

  Future<String> getFact() async {
    final url = Uri.parse('https://catfact.ninja/fact'); // API endpoint
    final request = await client.getUrl(url); // Create the request
    final response = await request.close();
    final jsonString = await response
        .transform(utf8.decoder)
        .join(); // Read the response body as a string
    final jsonResponse = jsonDecode(jsonString); // Decode the JSON string
    return jsonResponse['fact']; // Extract the fact from the JSON response
  }

  Future<Uint8List?> fetchAndCacheImage() async {
    final response = await http.get(Uri.parse(_getImage()));
    if (response.statusCode == 200) {
      _imageBytes = response.bodyBytes;
      return _imageBytes;
    }
    return null;
  }

  Uint8List? getImageBytes() {
    return _imageBytes;
  }

  String _getImage() {
    return 'https://cataas.com/cat?timestamp=${DateTime.now().millisecondsSinceEpoch}'; // Random cat image
  }
}
