import 'dart:convert';

import 'package:http/http.dart' as http;

class VirtualCardOtpService {
  static const String _baseUrl = 'http://10.0.2.2:9999/api/cardholders';

  // Generate Virtual Card OTP
  static Future<bool> generateOtp({required String username}) async {
    final url = Uri.parse('$_baseUrl/virtual-card/generate-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        print('✅ Virtual Card OTP generated successfully');
        return true;
      } else {
        print('❌ Failed to generate Virtual Card OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Error generating Virtual Card OTP: $e');
      return false;
    }
  }

  // Verify Virtual Card OTP
  static Future<bool> verifyOtp({required String username, required String otp}) async {
    final url = Uri.parse('$_baseUrl/virtual-card/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        print('✅ Virtual Card OTP verified');
        return true;
      } else {
        print('❌ Virtual Card OTP verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Error verifying Virtual Card OTP: $e');
      return false;
    }
  }
}
