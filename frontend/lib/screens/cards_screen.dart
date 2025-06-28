import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../dto/card_dto/card_model.dart';
import '../services/card_service/card_service.dart';
import '../widgets/StatusPillBadge.dart';
import '../widgets/Toast.dart';
import '../widgets/card_filter_chip.dart';
import '../widgets/credit_card_item.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({Key? key}) : super(key: key);

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  String selectedFilter = 'All Cards';
  final filters = [
    'All Cards',
    'Physical Cards',
    'Virtual Cards',
    'Blocked Cards',
    'Canceled Cards',
    'New Requests', // 🟢 Add this line
  ];


  final ScrollController _scrollController = ScrollController();

  List<CardModel> allCards = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCards();

    _refreshTimer = Timer.periodic(Duration(seconds: 4), (_) {
      _loadCards();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    try {
      final cards = await CardService().fetchAllCards();
      setState(() {
        allCards = cards;
        isLoading = false;
      });
    } catch (e) {
      showCupertinoGlassToast(context, "❌ Failed to load cards");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCards = switch (selectedFilter) {
      'All Cards' => allCards.where((card) =>
      card.status == 'ACTIVE').toList(),

      'Physical Cards' => allCards.where((card) =>
      card.type == 'PHYSICAL' && card.status == 'ACTIVE').toList(),

      'Virtual Cards' => allCards.where((card) =>
      card.type == 'VIRTUAL' && card.status == 'ACTIVE').toList(),

      'Blocked Cards' => allCards.where((card) =>
          [
            'TEMPORARILY_BLOCKED',
            'PERMANENTLY_BLOCKED',
            'FRAUD_BLOCKED',
            'CLOSED_REQUEST',
            'LOST',
            'STOLEN',
            'DAMAGED',
          ].contains(card.status)).toList(),

      'Canceled Cards' => allCards.where((card) =>
      card.status == 'SUSPENDED').toList(),

      'New Requests' => allCards.where((card) =>
      card.status == 'NEW_REQUEST').toList(),

      _ => allCards,
    };


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
              /// 🟦 Title & Back Button
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
                        onTap: () => context.pop(),
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

              /// 🟨 Filter Chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: filters.map((label) {
                  final isSelected = selectedFilter == label;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedFilter = label);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                    child: FilterCardChip(
                      label: label,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// 📄 Card List or Loader
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCards.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.creditcard_fill,
                          size: 100, // ⬅️ Bigger icon
                          color: Colors.black.withOpacity(0.15),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No ${selectedFilter.toLowerCase()} available.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, // ⬅️ Bigger and bolder
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.65),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Try changing the filter or adding a new card.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Dismissible(
                        key: ValueKey(card.cardNumber),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          final routeExtras = {'id': card.id.toString()};
                          if (card.type == 'PHYSICAL') {
                            context.push('/physical_card_details', extra: routeExtras);
                          } else {
                            context.push('/virtual_card_details', extra: routeExtras);
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        child: CreditCardItem(
                          card: card,
                          isDisabled: [
                            'TEMPORARILY_BLOCKED',
                            'PERMANENTLY_BLOCKED',
                            'FRAUD_BLOCKED',
                            'CLOSED_REQUEST',
                            'LOST',
                            'STOLEN',
                            'DAMAGED',
                            'SUSPENDED',
                            'NEW_REQUEST',
                          ].contains(card.status),
                          customOverlay: () {
                            String? label;
                            Color? bgColor;
                            IconData? icon;

                            switch (card.status) {
                              case 'TEMPORARILY_BLOCKED':
                                label = 'Temporarily Blocked';
                                bgColor = Colors.orange;
                                icon = CupertinoIcons.lock;
                                break;
                              case 'PERMANENTLY_BLOCKED':
                                label = 'Permanently Blocked';
                                bgColor = Colors.redAccent;
                                icon = CupertinoIcons.clear_circled_solid;
                                break;
                              case 'FRAUD_BLOCKED':
                                label = 'Fraud Blocked';
                                bgColor = Colors.deepPurple;
                                icon = CupertinoIcons.shield_lefthalf_fill;
                                break;
                              case 'CLOSED_REQUEST':
                                label = 'Closed by Request';
                                bgColor = Colors.blueGrey;
                                icon = CupertinoIcons.multiply_circle_fill;
                                break;
                              case 'LOST':
                                label = 'Card Lost';
                                bgColor = Colors.amber;
                                icon = CupertinoIcons.exclamationmark_circle;
                                break;
                              case 'STOLEN':
                                label = 'Card Stolen';
                                bgColor = Colors.deepPurpleAccent;
                                icon = CupertinoIcons.exclamationmark_triangle_fill;
                                break;
                              case 'DAMAGED':
                                label = 'Card Damaged';
                                bgColor = Colors.indigo;
                                icon = CupertinoIcons.wrench_fill;
                                break;
                              case 'SUSPENDED':
                                label = 'Canceled';
                                bgColor = Colors.grey;
                                icon = CupertinoIcons.pause_circle;
                                break;
                              case 'NEW_REQUEST':
                                label = 'New Request';
                                bgColor = Colors.teal;
                                icon = CupertinoIcons.doc_on_doc;
                                break;
                              default:
                                return null;
                            }

                            return StatusPillBadge(
                              label: label!,
                              backgroundColor: bgColor!,
                              icon: icon!,
                            );
                          }(),
                          onTap: (cardId) {
                            if (card.type == 'PHYSICAL') {
                              context.push('/physical_card_details', extra: {'id': cardId.toString()});
                            } else {
                              context.push('/virtual_card_details', extra: {'id': cardId.toString()});
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// ➕ Add Card Button
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
