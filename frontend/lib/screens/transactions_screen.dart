import 'package:flutter/material.dart';

import '../widgets/filter_pill.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String selectedFilter = 'All';
  int currentIndex = 0;

  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Daily',
      'title': 'Starbucks Coffee',
      'amount': -6.50,
      'date': 'Today',
      'icon': Icons.local_cafe,
      'color': Colors.brown,
    },
    {
      'type': 'Monthly',
      'title': 'Netflix Subscription',
      'amount': -13.99,
      'date': 'Mar 15',
      'icon': Icons.tv,
      'color': Colors.redAccent,
    },
    {
      'type': 'Online',
      'title': 'Amazon Purchase',
      'amount': -59.20,
      'date': 'Mar 12',
      'icon': Icons.shopping_bag,
      'color': Colors.deepPurple,
    },
    {
      'type': 'Daily',
      'title': 'Uber Ride',
      'amount': -12.00,
      'date': 'Today',
      'icon': Icons.directions_car,
      'color': Colors.blueAccent,
    },
  ];

  final filters = ['All', 'Daily', 'Monthly', 'Online'];


  @override
  Widget build(BuildContext context) {
    final filteredList = selectedFilter == 'All'
        ? transactions
        : transactions.where((tx) => tx['type'] == selectedFilter).toList();

    final totalAmount = filteredList.fold<double>(
        0, (sum, tx) => sum + (tx['amount'] as double));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF7F5), // pastel teal
            Color(0xFFFDF3F6), // soft blush pink
            Color(0xFFF2EDF9), // light lavender
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E2D),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // iOS-style filter pills
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: filters.map((label) {
                      final isSelected = selectedFilter == label;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedFilter = label),
                          child: FilterPill(
                            label: label,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Total Spent card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E5EA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE4E4E7),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 34,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Spent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Transactions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];
                    return TransactionCard(
                      title: tx['title'],
                      date: tx['date'],
                      amount: tx['amount'],
                      icon: tx['icon'],
                      color: tx['color'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}