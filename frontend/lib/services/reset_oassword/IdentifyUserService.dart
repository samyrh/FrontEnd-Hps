import 'dart:convert';
import 'package:http/http.dart' as http;

class IdentifyUserService {
  final String baseUrl = 'http://10.0.2.2:9999'; // Adjust if needed

  Future<bool> verifyUsername(String username) async {
    final url = Uri.parse('$baseUrl/api/cardholders/verify-username');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying username: $e');
      return false;
    }
  }
}
