import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final IconData icon;
  final Color color;

  const TransactionCard({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 26,
              color: color,
            ),
          ),

          const SizedBox(width: 16),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D7D87),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            (amount < 0 ? '-' : '+') + '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: amount < 0 ? Colors.redAccent : Colors.green,
              letterSpacing: -0.3,
              fontFamily: 'SF Pro Display', // Optional: use a rounded or modern font
            ),
          ),

        ],
      ),
    );
  }
}
