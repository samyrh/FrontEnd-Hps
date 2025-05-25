import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordService {
  final String baseUrl = 'http://10.0.2.2:9999';

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('No token found');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/cardholders/password');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      print('🔄 Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Change password failed: $e');
      return false;
    }
  }
}
