import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dto/card_model.dart';

class AccountSummary extends StatelessWidget {
  final CardModel card;

  const AccountSummary({super.key, required this.card});

  String formatAmount(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 📸 Banner with balance
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/Banner.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatAmount(card.balance)} MAD',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 🟩 Limit + Status
        Row(
          children: [
            // 💰 Yearly Limit - Remaining
            Expanded(
              child: _buildBox(
                title: 'Yearly Limit',
                value: '${formatAmount(card.annualLimit - card.balance)}',
                sub: '/ ${formatAmount(card.annualLimit)} MAD',
                gradient: const [Color(0xFFB4C9FF), Color(0xFF92AEE5)],
              ),
            ),

            // ✅ Card Status
            Expanded(
              child: _buildBox(
                title: 'Card Status',
                value: card.status.toString().split('.').last.toUpperCase(),
                sub: '',
                gradient: _getStatusGradient(card.status),
              ),
            ),
          ],
        ),

      ],
    );
  }

  List<Color> _getStatusGradient(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const [Color(0xFFA0CFA1), Color(0xFF78B48F)];
      case 'BLOCKED':
        return const [Color(0xFFF59E9E), Color(0xFFE06A6A)];
      case 'CANCELED':
        return const [Color(0xFFB0B0B0), Color(0xFF8A8A8A)];
      default:
        return const [Color(0xFFCCCCCC), Color(0xFF999999)];
    }
  }

  Widget _buildBox({
    required String title,
    required String value,
    required String sub,
    required List<Color> gradient,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }
}
