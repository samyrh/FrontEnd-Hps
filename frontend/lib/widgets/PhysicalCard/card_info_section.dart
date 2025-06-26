import 'package:flutter/material.dart';
import 'package:hps_direct/screens/PhysicalCardDetailsScreen.dart';

class CardInfoSection extends StatelessWidget {
  final bool isRequestSent;
  final TextEditingController cvvController;
  final TextEditingController pinController;
  final VoidCallback onRevealCvv;
  final bool isCvvRevealed;
  final VoidCallback onRevealPin;
  final String cardholderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String pin;

  const CardInfoSection({
    Key? key,
    required this.isRequestSent,
    required this.cvvController,
    required this.pinController,
    required this.onRevealCvv,
    required this.isCvvRevealed,
    required this.onRevealPin,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.pin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maskedCardNumber = isRequestSent
        ? '**** **** *** ${cardNumber.isNotEmpty ? cardNumber.substring(cardNumber.length - 3) : "***"}'
        : cardNumber;

    final displayExpiryDate = isRequestSent ? '**/**' : expiryDate;
    final displayCvv = '•••';
    final displayPin = '••••';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Cardholder Info"),
        _buildInput(
          "Name",
          TextEditingController(text: cardholderName),
          Icons.person,
        ),
        _buildInput(
          "Card Number",
          TextEditingController(text: maskedCardNumber),
          Icons.credit_card,
        ),
        if (!isRequestSent)
          _buildInput(
            "Expiry Date",
            TextEditingController(text: displayExpiryDate),
            Icons.calendar_today,
          ),
        if (!isRequestSent)
          _buildInput(
            "CVV",
            TextEditingController(text: displayCvv),
            Icons.lock_outline,
            isObscured: false,
            onTapSuffix: onRevealCvv,
            suffixIcon: Icons.remove_red_eye_outlined,
          ),
        if (!isRequestSent)
          _buildInput(
            "PIN",
            TextEditingController(text: displayPin),
            Icons.key,
            isObscured: true,
            onTapSuffix: onRevealPin,
            suffixIcon: Icons.remove_red_eye_outlined,
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1E),
        ),
      ),
    );
  }

  Widget _buildInput(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isObscured = false,
        VoidCallback? onTapSuffix,
        IconData? suffixIcon,
      }) {
    return buildLabeledField(
      label,
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
          suffixIcon: (onTapSuffix != null && !isRequestSent)
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
    );
  }

  Widget buildLabeledField(String label, Widget child) {
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
          child,
        ],
      ),
    );
  }
} 