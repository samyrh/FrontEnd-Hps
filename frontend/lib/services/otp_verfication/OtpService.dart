import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String _baseUrl = 'http://10.0.2.2:9999/api/cardholders';

  static Future<bool> verifyOtp({required String username, required String otp}) async {
    final url = Uri.parse('$_baseUrl/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'otp': otp}),
      );

      print('📨 Sent OTP verification request for "$username" with code "$otp"');
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // ✅ Also check for specific error responses
      if (response.statusCode == 200) {
        print('✅ OTP verified successfully!');
        return true;
      } else {
        print('❌ OTP verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Network or parsing error during OTP verification: $e');
      return false;
    }
  }

}
