import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/card_model.dart';

class CardService {
  static const String _baseUrl = "http://10.0.2.2:7777"; // or production base URL

  /// ✅ Fetches all physical cards for the authenticated cardholder
  Future<List<CardModel>> fetchPhysicalCards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("🔐 No JWT token found in storage.");
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/my-physical-cards");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => CardModel.fromJson(json)).toList();
      } else {
        print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load cards.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to fetch cards.");
    }
  }
}
