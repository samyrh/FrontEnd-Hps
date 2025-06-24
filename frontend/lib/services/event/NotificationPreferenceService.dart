import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/NotificationPreferencesDTO.dart';

class NotificationPreferenceService {
  static const String _baseUrl = "http://10.0.2.2:9988/api/notification-preferences";

  /// Get current preferences of authenticated cardholder
  Future<NotificationPreferencesDTO> fetchPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationPreferencesDTO.fromJson(data);
      } else {
        print("❌ Failed to fetch preferences: ${response.statusCode}");
        throw Exception("Failed to fetch preferences.");
      }
    } catch (e) {
      print("❌ Error fetching preferences: $e");
      throw Exception("Unable to fetch preferences.");
    }
  }

  /// Update preferences of authenticated cardholder
  Future<bool> updatePreferences(NotificationPreferencesDTO dto) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder/update");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        print("✅ ${response.body}");
        return true;
      } else {
        print("❌ Failed to update preferences: ${response.statusCode}");
        print("🔍 ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating preferences: $e");
      return false;
    }
  }
}
