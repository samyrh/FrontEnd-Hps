import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  /// ✅ Generate OTP for Physical Card
  static Future<bool> generatePhysicalCardOtp(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print("❌ No token found.");
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('$_baseUrl/physical-card/generate-otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username}),
      );

      print('📨 Sent generate Physical Card OTP request for "$username"');
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Physical Card OTP generated successfully.');
        return true;
      } else {
        print('❌ Failed to generate Physical Card OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Network or parsing error during OTP generation: $e');
      return false;
    }
  }

  /// ✅ Verify OTP for Physical Card
  static Future<bool> verifyPhysicalCardOtp({
    required String username,
    required String otp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print("❌ No token found.");
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('$_baseUrl/physical-card/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'otp': otp}),
      );

      print('📨 Sent verify Physical Card OTP request for "$username" with code "$otp"');
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Physical Card OTP verified successfully.');
        return true;
      } else {
        print('❌ Physical Card OTP verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Network or parsing error during Physical Card OTP verification: $e');
      return false;
    }
  }

}
