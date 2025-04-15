import 'package:flutter/material.dart';

class TransactionsWidget extends StatelessWidget {
  const TransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                backgroundColor: const Color(0xFFEBEBEC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF201F1F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transactions List
        ..._transactions.map((tx) => _buildTransactionItem(tx)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(_Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tx.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(tx.icon, color: tx.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            tx.amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: tx.amount.startsWith('-')
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF32D74B),
            ),
          ),
        ],
      ),
    );
  }
}

// 💳 Model
class _Transaction {
  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final Color color;

  const _Transaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

// 💼 Sample Data
const List<_Transaction> _transactions = [
  _Transaction(
    title: 'Netflix Subscription',
    date: 'Apr 8, 2025',
    amount: '-\$15.99',
    icon: Icons.tv,
    color: Color(0xFFFF3B30),
  ),
  _Transaction(
    title: 'Salary - Hps',
    date: 'Apr 7, 2025',
    amount: '+\$2,200.00',
    icon: Icons.attach_money_rounded,
    color: Color(0xFF32D74B),
  ),
  _Transaction(
    title: 'Apple Store',
    date: 'Apr 6, 2025',
    amount: '-\$129.99',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFF007AFF),
  ),
  _Transaction(
    title: 'Coffee - Starbucks',
    date: 'Apr 5, 2025',
    amount: '-\$4.75',
    icon: Icons.local_cafe_outlined,
    color: Color(0xFFFF9500),
  ),
  _Transaction(
    title: 'Freelance Project',
    date: 'Apr 4, 2025',
    amount: '+\$600.00',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF32D74B),
  ),
  _Transaction(
    title: 'Uber Ride',
    date: 'Apr 3, 2025',
    amount: '-\$18.20',
    icon: Icons.directions_car_filled_rounded,
    color: Color(0xFF5856D6),
  ),
];
