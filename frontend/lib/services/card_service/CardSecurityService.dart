import 'dart:convert';
import 'package:hps_direct/dto/card_dto/BlockVirtualCardRequest.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/card_dto/CardSecurityOptionsModel.dart';
import '../../dto/card_dto/PhysicalCardSecurityOption.dart';
import '../../dto/card_dto/UpdatePhysicalSecurityOptionRequest.dart';
import '../../dto/card_dto/UpdateSecurityOptionRequest.dart';
import '../../dto/card_dto/VirtualSecurityOption.dart';

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
  Future<void> updateCardSecurityOptions(UpdateSecurityOptionRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("$_baseUrl/api/cards/security-options/update");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update security option: ${response.body}");
    }
  }
  Future<List<VirtualSecurityOption>> fetchVirtualCardSecurityOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-security-options");

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
        return data.map((json) => VirtualSecurityOption.fromJson(json)).toList();
      } else {
        print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load virtual card security options.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to fetch virtual card security options.");
    }
  }
  Future<VirtualSecurityOption> fetchVirtualCardSecurityOptionById(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-cards/$cardId/security-option");

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
        return VirtualSecurityOption.fromJson(data);
      } else {
        print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load virtual card security option by ID.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to fetch virtual card security option by ID.");
    }
  }
  Future<void> setEcommerceStatus(String cardId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception("Not authenticated.");

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-security-options/$cardId/ecommerce");
    final response = await http.put(
      uri,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'ecommerceEnabled': enabled}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update e-commerce status: "+response.body);
    }
  }
  Future<void> updateSecurityOptions(UpdateSecurityOptionRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/security-options/update");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update security options: ${response.body}");
    }
  }
  Future<void> blockVirtualCard(String cardId, BlockVirtualCardRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/$cardId/block");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to block virtual card: ${response.body}");
    }
  }
  Future<void> unblockVirtualCard(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/virtual-card/$cardId/unblock");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to unblock virtual card: ${response.body}");
    }
  }
  Future<void> blockPhysicalCard(String cardId, String blockReason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/physical-card/$cardId/block");

    final body = {
      'blockReason': blockReason, // This must match your backend DTO field
    };

    final response = await http.put(
      uri,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to block physical card: ${response.body}");
    }
  }

  Future<PhysicalCardSecurityOption> fetchPhysicalCardSecurityOptionById(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/physical-cards/$cardId/security-option");

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
        return PhysicalCardSecurityOption.fromJson(data);
      } else {
        print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load physical card security option.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Failed to fetch physical card security option.");
    }
  }
  Future<void> updatePhysicalCardSecurityOptions(UpdatePhysicalSecurityOptionRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/physical-card/security-options/update");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update physical card security options: ${response.body}");
    }
  }


  Future<void> unblockPhysicalCard(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/api/cards/physical-card/$cardId/unblock");

    final response = await http.put(
      uri,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to unblock physical card: ${response.body}");
    }
  }


}
