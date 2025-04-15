import 'package:flutter/material.dart';
import '../widgets/card_filter_chip.dart';
import '../widgets/credit_card_item.dart';
import 'package:animations/animations.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({Key? key}) : super(key: key);

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  String selectedFilter = 'All';
  int currentIndex = 1; // This screen is at index 1 in the navbar

  final filters = [
    'All',
    'Virtual Cards',
    'Cards',
    'Visa Cards',
    'MasterCards',
  ];

  final cards = [
    {
      'type': 'Visa Cards',
      'title': 'Visa Gold',
      'number': '**** **** **** 1234',
      'color': Colors.deepPurple,
    },
    {
      'type': 'MasterCards',
      'title': 'MasterCard Platinum',
      'number': '**** **** **** 9876',
      'color': Colors.indigo,
    },
    {
      'type': 'Virtual Cards',
      'title': 'Virtual Shopping Card',
      'number': '**** **** **** 4455',
      'color': Colors.teal,
    },
    {
      'type': 'Visa Cards',
      'title': 'Visa Infinite',
      'number': '**** **** **** 2233',
      'color': Color(0xFF1B1B1F),
    },
    {
      'type': 'MasterCards',
      'title': 'MasterCard World Elite',
      'number': '**** **** **** 8899',
      'color': Color(0xFF4A148C),
    },
    {
      'type': 'Virtual Cards',
      'title': 'Crypto Virtual Card',
      'number': '**** **** **** 6622',
      'color': Color(0xFF00ACC1),
    },
    {
      'type': 'Cards',
      'title': 'Business Travel Card',
      'number': '**** **** **** 3412',
      'color': Color(0xFF37474F),
    },
    {
      'type': 'Visa Cards',
      'title': 'Visa Signature',
      'number': '**** **** **** 7741',
      'color': Color(0xFF3949AB),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = selectedFilter == 'All'
        ? cards
        : cards.where((c) => c['type'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'My Cards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E2D),
                      fontFamily: 'Inter',
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

            // Filter chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: filters.map((label) {
                final isSelected = selectedFilter == label;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = label),
                  child: FilterCardChip(
                    label: label,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Cards List
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation, secondaryAnimation) =>
                    SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    ),
                child: ListView.builder(
                  key: ValueKey(selectedFilter),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final card = filteredList[index];
                    return CreditCardItem(
                      title: card['title'] as String,
                      number: card['number'] as String,
                      color: card['color'] as Color,
                    );
                  },
                ),
              ),
            ),

            // Add Card Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {},
                  child: const Text(
                    '+ Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
