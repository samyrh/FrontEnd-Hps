import 'package:flutter/material.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterPill({
    Key? key,
    required this.label,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFD1D1D6), // iOS system gray
        borderRadius: BorderRadius.circular(28),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
        border: isSelected
            ? Border.all(color: Colors.black12)
            : Border.all(color: const Color(0xFFE5E5EA), width: 1),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 280),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF111111) : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
