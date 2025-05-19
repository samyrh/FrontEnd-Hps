import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../dto/LoginUserDto.dart';

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
}
