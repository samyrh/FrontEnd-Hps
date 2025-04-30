import 'package:flutter/cupertino.dart';

Widget buildScrollableCountryRow(List<String> countries) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: countries.map((country) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF111827).withOpacity(0.25), width: 0.8),
            ),
            child: Text(
              country,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
