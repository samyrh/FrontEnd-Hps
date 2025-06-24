import 'package:flutter/material.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class FormInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isObscured;
  final VoidCallback? onTapSuffix;
  final IconData? suffixIcon;

  const FormInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isObscured = false,
    this.onTapSuffix,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          TextField(
            controller: controller,
            readOnly: true,
            obscureText: isObscured,
            focusNode: AlwaysDisabledFocusNode(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade700, size: 20),
              filled: true,
              fillColor: const Color(0xFFE5E5EA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
              ),
              suffixIcon: onTapSuffix != null
                  ? GestureDetector(
                onTap: onTapSuffix,
                child: Icon(
                  suffixIcon ?? Icons.remove_red_eye_outlined,
                  color: Colors.grey.shade700,
                ),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
