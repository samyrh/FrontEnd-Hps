import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SecurityCodeService {
  final String baseUrl = 'http://10.0.2.2:9999'; // Use 10.0.2.2 for Android emulator
  Future<bool> submitSecurityCode({
    required String code,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('❌ JWT token not found.');
      return false;
    }

    final Uri url = Uri.parse('$baseUrl/api/cardholders/security-code');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'securityCode': code,
        }),
      );

      print('✅ [SecurityCode] status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [SecurityCode] error: $e');
      return false;
    }
  }

}
