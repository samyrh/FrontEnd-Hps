import 'dart:ui';
import 'package:flutter/material.dart';

class CardScroller extends StatefulWidget {
  const CardScroller({super.key});

  @override
  State<CardScroller> createState() => _CardScrollerState();
}

class _CardScrollerState extends State<CardScroller> {
  final PageController _pageController =
  PageController(viewportFraction: 0.75, initialPage: 1000);
  int _currentPage = 1000;

  final List<List<Color>> _cardGradients = [
    [Color(0xFF6E8EF5), Color(0xFF4961DC)],
    [Color(0xFF00C6FB), Color(0xFF005BEA)],
    [Color(0xFFFFA69E), Color(0xFF861657)],
    [Color(0xFF4ECDC4), Color(0xFF556270)],
    [Color(0xFF74EBD5), Color(0xFFACB6E5)],
  ];

  int get visibleIndex => _currentPage % _cardGradients.length;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final index = _pageController.page?.round() ?? 0;
      if (_currentPage != index) {
        setState(() {
          _currentPage = index;
        });
      }
    });
  }

  Widget _buildCard(int index) {
    final actualIndex = index % _cardGradients.length;
    final isFocused = index == _currentPage;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: isFocused ? 0.9 : 0.9, end: isFocused ? 1.0 : 0.9),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: _buildCardContainer(_cardGradients[actualIndex]),
    );
  }

  Widget _buildCardContainer(List<Color> colors) {
    const double radius = 28; // very rounded

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(20),
        width: 320,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
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
              children: const [
                Text(
                  'My Physical Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Image(
                  image: AssetImage('assets/visa_logo.png'),
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            const Text(
              '1234 5678 9012',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARDHOLDER',
                        style: TextStyle(fontSize: 10, color: Colors.white54)),
                    SizedBox(height: 2),
                    Text('Nada S. Rhandor',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EXPIRES',
                        style: TextStyle(fontSize: 10, color: Colors.white54)),
                    SizedBox(height: 2),
                    Text('08/26',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7), // 🍎 iOS soft grey
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFE5E5EA)), // subtle border
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_cardGradients.length, (index) {
            final isActive = index == visibleIndex;

            return GestureDetector(
              onTap: () {
                final current = _currentPage;
                final base = current - (current % _cardGradients.length);
                int target = base + index;

                if ((current % _cardGradients.length) - index > 2) {
                  target = base + _cardGradients.length + index;
                }

                _pageController.animateToPage(
                  target,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.black.withOpacity(0.9)
                      : Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          }),
        ),
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
        const SizedBox(height: 0), // 🔹 Minimized space below cards
        _buildPageIndicator(),
        const SizedBox(height: 8), // Optional: very light spacing
      ],
    );
  }

}
