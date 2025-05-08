import 'package:flutter/material.dart';
import '../widgets/Toast.dart';
import '../widgets/card_filter_chip.dart';
import '../widgets/credit_card_item.dart';
import 'package:go_router/go_router.dart';

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
                    final title = card['title'] as String;
                    final number = card['number'] as String;
                    final color = card['color'] as Color;
                    final type = card['type'] as String;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Dismissible(
                        key: ValueKey(number),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text('Confirm Selection'),
                                content: Text(
                                  'Do you want to manage the "$title" card?',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed == true) {
                            if (type == 'Physical Cards') {
                              context.push('/physical_card_details');
                            } else {
                              context.push('/virtual_card_details');
                            }
                          }

                          // Always return false to prevent auto-dismiss
                          return false;
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                        ),
                        child: CreditCardItem(
                          title: title,
                          number: number,
                          color: color,
                        ),
                      ),
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
                    onPressed: () {
                      context.push('/add_card');

                      // ✅ Show the toast after navigating
                      Future.delayed(const Duration(milliseconds: 300), () {
                        showCupertinoGlassToast(
                          context,
                          'Choose your card type first, then select your preferred pack.',
                          isSuccess: true,
                          position: ToastPosition.top,
                        );
                      });
                    },
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
