import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/card_dto/EventResponseDTO.dart';

class EventService {
  static const String _baseUrl = "http://10.0.2.2:9988/api/events";

  Future<List<EventResponseDTO>> fetchCardholderEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => EventResponseDTO.fromJson(e)).toList();
      } else {
        print("❌ Failed to fetch events: ${response.statusCode}");
        print("🔍 Response: ${response.body}");
        throw Exception("Failed to fetch events.");
      }
    } catch (e) {
      print("❌ Network error: $e");
      throw Exception("Unable to fetch events.");
    }
  }

  /// Mark all events as read for the cardholder (uses token to extract identity)
  Future<void> markAllEventsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder/mark-all-read");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ ${response.body}");
      } else {
        print("❌ Failed to mark as read: ${response.statusCode}");
        print("🔍 Response: ${response.body}");
        throw Exception("Failed to mark notifications as read.");
      }
    } catch (e) {
      print("❌ Error calling mark-all-read: $e");
      throw Exception("Unable to mark events as read.");
    }
  }
  /// Fetch only unread events
  Future<List<EventResponseDTO>> fetchUnreadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder/unread");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => EventResponseDTO.fromJson(e)).toList();
      } else {
        print("❌ Failed to fetch unread events: ${response.statusCode}");
        print("🔍 Response: ${response.body}");
        throw Exception("Failed to fetch unread events.");
      }
    } catch (e) {
      print("❌ Error fetching unread events: $e");
      throw Exception("Unable to fetch unread events.");
    }
  }

  Future<int> fetchUnreadEventCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder/unread/count");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return int.parse(response.body); // ✅ This works as long as backend returns plain number
      } else {
        print("❌ Failed to fetch unread count: ${response.statusCode}");
        print("🔍 Response: ${response.body}");
        throw Exception("Failed to fetch unread count.");
      }
    } catch (e) {
      print("❌ Error fetching unread count: $e");
      throw Exception("Unable to fetch unread count.");
    }
  }
  Future<void> deleteEventById(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("🔐 Not authenticated.");
    }

    final uri = Uri.parse("$_baseUrl/cardholder/delete/$eventId");

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Event deleted successfully: ${response.body}");
      } else if (response.statusCode == 404) {
        print("⚠️ Event not found.");
        throw Exception("Event not found.");
      } else if (response.statusCode == 403) {
        print("⛔ Unauthorized: ${response.body}");
        throw Exception("You are not allowed to delete this event.");
      } else {
        print("❌ Failed to delete event: ${response.statusCode}");
        print("🔍 Response: ${response.body}");
        throw Exception("Failed to delete event.");
      }
    } catch (e) {
      print("❌ Error deleting event: $e");
      throw Exception("Unable to delete event.");
    }
  }

}