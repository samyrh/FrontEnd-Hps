import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/card_dto/TravelPlanRequest.dart';
import '../../dto/card_dto/TravelPlanResponse.dart';

class TravelPlanService {
  static const String baseUrl = 'http://10.0.2.2:8084/api/travel-plans';

  Future<String> createTravelPlan(int cardId, TravelPlanRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$baseUrl/cardholder/create/$cardId");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return "✅ Travel plan created successfully";
      } else {
        print("❌ Failed to create travel plan: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        throw Exception("❌ ${response.body}");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("❌ Failed to create travel plan.");
    }
  }

  Future<TravelPlanResponse?> fetchTravelPlanByCardId(int cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception("Not authenticated.");

    final uri = Uri.parse("$baseUrl/card/$cardId");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TravelPlanResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception("❌ ${response.body}");
      }
    } catch (e) {
      print("❌ Failed to fetch travel plan: $e");
      throw Exception("❌ Network error while fetching travel plan.");
    }
  }
}
