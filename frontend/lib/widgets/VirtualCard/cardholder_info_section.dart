import 'package:flutter/material.dart';
import 'form_input_field.dart';
import 'section_title.dart';

class CardholderInfoSection extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController cvvController;
  final bool isRequestSent;
  final bool isCvvRevealed;
  final VoidCallback? onTapRevealCvv;
  final VoidCallback? onTapHideCvv;
  final String cardNumber;
  final String expiryDate;

  const CardholderInfoSection({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.cvvController,
    required this.isRequestSent,
    required this.isCvvRevealed,
    required this.cardNumber,
    required this.expiryDate,
    this.onTapRevealCvv,
    this.onTapHideCvv,
  });

  @override
  Widget build(BuildContext context) {
    final maskedCardNumber = isRequestSent
        ? '**** **** *** ${cardNumber.substring(cardNumber.length - 3)}'
        : cardNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Cardholder Info"),

        FormInputField(
          label: "Name",
          controller: usernameController,
          icon: Icons.person,
        ),

        FormInputField(
          label: "Email",
          controller: emailController,
          icon: Icons.email,
        ),

        FormInputField(
          label: "Card Number",
          controller: TextEditingController(text: maskedCardNumber),
          icon: Icons.credit_card,
        ),

        if (!isRequestSent)
          FormInputField(
            label: "Expiry Date",
            controller: TextEditingController(text: expiryDate),
            icon: Icons.calendar_today,
          ),

        if (!isRequestSent)
          FormInputField(
            label: "CVV",
            controller: cvvController,
            icon: Icons.lock_outline,
            isObscured: false,
            onTapSuffix: isCvvRevealed ? onTapHideCvv : onTapRevealCvv,
            suffixIcon: isCvvRevealed
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
          ),
      ],
    );
  }
}
