import 'package:flutter/material.dart';

Widget dateLabel(String label, DateTime date) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9FB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD1D1D6)),
    ),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(date.toString().split(' ')[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
} 