import 'dart:ui';
import 'package:flutter/material.dart';
import '../dto/card_dto/card_model.dart';
import '../services/card_service/card_service.dart';

class CardScroller extends StatefulWidget {
  final Function(CardModel selectedCard)? onCardChanged;
  final Function(CardModel selectedCard)? onCardTap;

  const CardScroller({
    super.key,
    this.onCardChanged,
    this.onCardTap,
  });

  @override
  State<CardScroller> createState() => _CardScrollerState();
}

class _CardScrollerState extends State<CardScroller> {
  final PageController _pageController = PageController(viewportFraction: 0.75, initialPage: 10000);
  int _currentPage = 0;

  final CardService _cardService = CardService();
  List<CardModel> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();

    _pageController.addListener(() {
      if (_cards.isEmpty) return;
      final index = (_pageController.page?.round() ?? 0) % _cards.length;
      if (_currentPage != index) {
        setState(() => _currentPage = index);
        widget.onCardChanged?.call(_cards[index]);
      }
    });
  }

  Future<void> _loadCards() async {
    try {
      final cards = await _cardService.fetchPhysicalCards();
      setState(() => _cards = cards);
      if (_cards.isNotEmpty) {
        widget.onCardChanged?.call(_cards[0]);
      }
    } catch (e) {
      print('❌ Failed to load cards: $e');
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Widget _buildCardContainer(CardModel card) {
    const double radius = 28;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(20),
        width: 320,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexToColor(card.gradientStartColor),
              hexToColor(card.gradientEndColor),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.cardPack.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Image(
                  image: AssetImage('assets/visa_logo.png'),
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            Text(
              card.cardNumber
                  ?.replaceAll(RegExp(r'[^0-9]'), '')
                  .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
                  .trim() ??
                  '**** **** ****',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CARDHOLDER', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 2),
                    Text(card.cardholderName, style: const TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('EXPIRES', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 2),
                    Text(
                      card.expirationDate.split('T').first,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    if (_cards.isEmpty) return const SizedBox();
    final realIndex = index % _cards.length;
    final card = _cards[realIndex];
    final isFocused = realIndex == _currentPage;

    return GestureDetector(
      onTap: () => widget.onCardTap?.call(card),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isFocused ? 1.0 : 0.9),
        duration: const Duration(milliseconds: 300),
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: _buildCardContainer(card),
      ),
    );
  }

  Widget _buildPageIndicator() {
    const int visibleDots = 6;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(visibleDots, (i) {
          int adjustedIndex = (_currentPage % visibleDots);

          final isActive = i == adjustedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1C1C1E)
                  : const Color(0xFF3C3C43).withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) => _buildCard(index),
            physics: const BouncingScrollPhysics(),
          ),
        ),
        const SizedBox(height: 0),
        if (_cards.isNotEmpty) _buildPageIndicator(),
        const SizedBox(height: 8),
      ],
    );
  }
}