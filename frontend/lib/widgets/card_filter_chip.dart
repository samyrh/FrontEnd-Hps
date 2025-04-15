import 'package:flutter/material.dart';

class FilterCardChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterCardChip({
    Key? key,
    required this.label,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: 110,
      height: 40,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFF2F2F7) // iOS selected grey
            : const Color(0xFFD1D1D6), // iOS unselected grey
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected
              ? Colors.black.withOpacity(0.2) // ✅ visible dark border
              : const Color(0xFFBEBEBE),
          width: isSelected ? 1.4 : 1.0,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF000000) // black text for selected
                : const Color(0xFF5F5F62), // grey for unselected
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
