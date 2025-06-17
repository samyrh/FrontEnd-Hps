import 'dart:convert';
import 'package:hps_direct/screens/NewCard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/card_dto/ReplaceVirtualCardRequest.dart';
import '../../dto/card_dto/card_request_dto.dart';
import '../../dto/card_dto/card_model.dart';

class CardService {
  static const String _baseUrl = "http://10.0.2.2:7777";


  Future<List<CardModel>> fetchPhysicalCards() async {
    return _fetchCardsFrom("/api/cards/my-physical-cards");
  }
  Future<List<CardModel>> fetchAllCards() async {
    return _fetchCardsFrom("/api/cards/my-cards");
  }
  Future<List<CardModel>> _fetchCardsFrom(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("🔐 No JWT token found in storage.");
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl$endpoint");

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
  Future<bool> requestNewCard(CardRequestDTO dto) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/add");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to request card: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Network error: $e");
      return false;
    }
  }
  Future<CardModel> fetchCardById(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/$cardId");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CardModel.fromJson(data);
      } else {
        print("❌ Failed to fetch card by ID: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        throw Exception("Failed to load card details.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to fetch card by ID.");
    }
  }
  Future<String?> viewVirtualCardCVV(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception("Not authenticated.");

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/$cardId/view-cvv");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('cvv')) {
          return data['cvv'] as String?;
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<bool> updateVirtualCardLimit(String cardId, double newAnnualLimit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/$cardId/update-limit");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'newAnnualLimit': newAnnualLimit,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to update card limit: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Network error: $e");
      return false;
    }
  }
  Future<bool> requestVirtualCardReplacement(ReplaceVirtualCardRequest requestDto) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/replace");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestDto.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to request virtual card replacement: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Network error: $e");
      return false;
    }
  }
  Future<void> cancelVirtualCard(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/$cardId/cancel");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("❌ Failed to cancel virtual card: ${response.statusCode}");
        print("🔍 Body: ${response.body}");
        throw Exception("Failed to cancel virtual card");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to cancel virtual card.");
    }
  }
}
