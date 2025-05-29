import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/CardSecurityOptionsModel.dart';

class SecurityOptionsService {
  static const String _baseUrl = "http://10.0.2.2:7777";

  Future<List<CardSecurityOptionsModel>> fetchCardSecurityOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("$_baseUrl/api/cards/security-options");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CardSecurityOptionsModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load security options: ${response.body}");
    }
  }
  Future<void> updateCardSecurityOption({
    required String label,
    bool? contactlessEnabled,
    bool? ecommerceEnabled,
    bool? tpeEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("$_baseUrl/api/cards/security-options/update");

    final body = {
      'label': label,
      if (contactlessEnabled != null) 'contactlessEnabled': contactlessEnabled,
      if (ecommerceEnabled != null) 'ecommerceEnabled': ecommerceEnabled,
      if (tpeEnabled != null) 'tpeEnabled': tpeEnabled,
    };

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update security option: ${response.body}");
    }
  }

}
