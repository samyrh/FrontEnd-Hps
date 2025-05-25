// services/reset_password_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  final String baseUrl = 'http://10.0.2.2:9999';

  Future<bool> resetPassword(String username, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/cardholders/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'newPassword': newPassword,
        }),
      );

      print('🔁 Reset status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
