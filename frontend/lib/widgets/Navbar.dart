import 'package:flutter/material.dart';

class IOSBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const IOSBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF007AFF); // iOS blue
    final inactiveColor = Colors.grey.shade600;

    final items = [
      _NavItem(icon: Icons.home_outlined, label: 'Home'),
      _NavItem(icon: Icons.credit_card_rounded, label: 'Cards'),
      _NavItem(icon: Icons.smart_toy_outlined, label: 'AI Support'),
      _NavItem(icon: Icons.menu_rounded, label: 'Menu'),
    ];

    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: width,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4), // Move everything up a bit
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) => ScaleTransition(
                            scale: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: Icon(
                            item.icon,
                            key: ValueKey(isSelected),
                            size: 25,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                          child: Text(item.label),
                        ),
                        const SizedBox(height: 2.5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          width: isSelected ? 20 : 0,
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
