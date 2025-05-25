import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPasswordService {
  final String baseUrl = 'http://10.0.2.2:9999';

  /// ✅ Checks if the current password is correct by calling the backend
  Future<bool> verifyCurrentPassword(String currentPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('No JWT token found.');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/cardholders/password/verify');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': currentPassword,
        }),
      );

      print('🔐 Verification status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print(' Password verification failed: $e');
      return false;
    }
  }
}
