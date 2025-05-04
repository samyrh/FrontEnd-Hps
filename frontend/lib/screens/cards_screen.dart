import 'package:flutter/material.dart';
import '../widgets/card_filter_chip.dart';
import '../widgets/credit_card_item.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({Key? key}) : super(key: key);

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  String selectedFilter = 'All Cards';
  int currentIndex = 1;

  final filters = [
    'All Cards',
    'Physical Cards',
    'Virtual Cards',
  ];

  final cards = [
    {
      'type': 'Physical Cards',
      'title': 'Visa Youth',
      'number': '**** **** **** 0001',
      'color': Color(0xFFFFAB91), // orange
    },
    {
      'type': 'Physical Cards',
      'title': 'Visa Classic',
      'number': '**** **** **** 0002',
      'color': Color(0xFFAED581), // light green
    },
    {
      'type': 'Physical Cards',
      'title': 'Visa Gold',
      'number': '**** **** **** 0003',
      'color': Color(0xFFFFD54F), // yellow
    },
    {
      'type': 'Physical Cards',
      'title': 'Visa Business',
      'number': '**** **** **** 0004',
      'color': Color(0xFF4DB6AC), // teal
    },
    {
      'type': 'Physical Cards',
      'title': 'Visa Premium+',
      'number': '**** **** **** 0005',
      'color': Color(0xFFBA68C8), // purple
    },
    {
      'type': 'Physical Cards',
      'title': 'Visa International',
      'number': '**** **** **** 0006',
      'color': Color(0xFF7986CB), // blue
    },
    {
      'type': 'Virtual Cards',
      'title': 'Virtual Standard',
      'number': '**** **** **** 1001',
      'color': Color(0xFFCE93D8), // violet
    },
    {
      'type': 'Virtual Cards',
      'title': 'Virtual Plus',
      'number': '**** **** **** 1002',
      'color': Color(0xFFFFF176), // lemon yellow
    },
    {
      'type': 'Virtual Cards',
      'title': 'Virtual Premium',
      'number': '**** **** **** 1003',
      'color': Color(0xFF90CAF9), // light blue
    },
    {
      'type': 'Virtual Cards',
      'title': 'Virtual Business',
      'number': '**** **** **** 1004',
      'color': Color(0xFFE57373), // red
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = selectedFilter == 'All Cards'
        ? cards
        : cards.where((c) => c['type'] == selectedFilter).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6F2F0),
            Color(0xFFE3E4F7),
            Color(0xFFF5F6FA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Column(
            children: [
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
              Expanded(
                child: ListView.builder(
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
      ),
    );
  }
}
