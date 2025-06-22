import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventResponseDTO {
  final int id;
  final String message;
  final String category;
  final String sentAt;
  final bool isRead;

  EventResponseDTO({
    required this.id,
    required this.message,
    required this.category,
    required this.sentAt,
    required this.isRead,
  });

  factory EventResponseDTO.fromJson(Map<String, dynamic> json) {
    return EventResponseDTO(
      id: json['id'],
      message: json['message'],
      category: json['category'],
      sentAt: json['sentAt'],
      isRead: json['read'] ?? false,
    );
  }
}

