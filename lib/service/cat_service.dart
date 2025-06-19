import 'dart:convert';
import 'dart:io';

class CatService {
  final client = HttpClient(); // Create an HttpClient instance

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

  String getImage() {
    return 'https://cataas.com/cat?timestamp=${DateTime.now().millisecondsSinceEpoch}'; // Random cat image
  }
}
