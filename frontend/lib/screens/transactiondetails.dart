import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final IconData icon;
  final Color color;
  final String type;

  const TransactionDetailScreen({
    Key? key,
    this.title = 'Uber Ride',
    this.date = 'Today',
    this.amount = -12.00,
    this.icon = Icons.directions_car,
    this.color = Colors.blueAccent,
    this.type = 'Daily',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Back Button + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 30),
                  ),
                  const Spacer(),
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Opacity(
                    opacity: 0,
                    child: Icon(Icons.chevron_left),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Main Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: color),
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    Text(
                      '\$${amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? Colors.redAccent : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 0, thickness: 1),
                    const SizedBox(height: 20),

                    // Additional Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction Type', style: TextStyle(color: Colors.grey)),
                        Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Payment Method', style: TextStyle(color: Colors.grey)),
                        Text('Visa •••• 3412', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Card Number', style: TextStyle(color: Colors.grey)),
                        Text('**** **** **** 3412', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Transaction ID', style: TextStyle(color: Colors.grey)),
                        Text('#TXN982132', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Status', style: TextStyle(color: Colors.grey)),
                        Text('Completed', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
