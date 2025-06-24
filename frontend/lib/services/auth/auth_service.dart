import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/auth_dto/LoginUserDto.dart';
import '../../dto/card_dto/UserInfoDto.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:9999';

  Future<http.Response?> login(LoginUserDto dto) async {
    final url = Uri.parse('$baseUrl/auth/login'); // ✅ Correct endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ Optional but good practice
        },
        body: json.encode(dto.toJson()),
      );

      // ✅ Debug output
      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      return response;
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }


  Future<UserInfoDto?> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("🔐 No token found.");
      return null;
    }

    final uri = Uri.parse('$baseUrl/api/cardholders/me');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserInfoDto.fromJson(data);
      } else {
        print('❌ Failed to fetch user info.');
        return null;
      }
    } catch (e) {
      print('❌ Network error: $e');
      return null;
    }
  }
}
