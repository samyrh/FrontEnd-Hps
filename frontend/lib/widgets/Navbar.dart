import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const inactiveColor = Color(0xFF8E8E93); // iOS grey
    const activeColor = Color(0xFF007AFF);   // iOS blue

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.credit_card_rounded, label: 'My Cards'),
      _NavItem(icon: Icons.airplane_ticket_rounded, label: 'Travel Plan'),
      _NavItem(icon: Icons.smart_toy_outlined, label: 'AI Chat'),
      _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.8),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
