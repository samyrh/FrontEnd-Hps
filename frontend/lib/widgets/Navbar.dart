import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Toast.dart';

class IOSBottomNavbar extends StatelessWidget {
  const IOSBottomNavbar({super.key});

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

    // ✅ Dynamically detect current route
    final currentIndex = _getIndexFromRoute(context);

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
                  onTap: () {
                    if (index != currentIndex) {
                      _handleNavigation(context, index); // ✅ Handle routing
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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

  // ✅ Get index based on route
  int _getIndexFromRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/cards')) return 1;
    if (location.startsWith('/ai_support')) return 2;
    if (location.startsWith('/menu')) return 3;
    return 0; // default: home
  }

  // ✅ Handle routing logic + toasts here
  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push('/home'); // ✅ use push now
        Future.delayed(const Duration(milliseconds: 300), () {
          showCupertinoGlassToast(
            context,
            'Welcome back to Home 🏠.',
            isSuccess: true,
            position: ToastPosition.top,
          );
        });
        break;
      case 1:
        context.push('/cards'); // ✅ push
        Future.delayed(const Duration(milliseconds: 300), () {
          showCupertinoGlassToast(
            context,
            'Here are all your Physical & Virtual cards, tap a card to flip the card and swipe left for card details.',
            isSuccess: true,
            position: ToastPosition.top,
          );
        });
        break;
      case 2:
        context.push('/ai_support'); // ✅ push
        Future.delayed(const Duration(milliseconds: 300), () {
          showCupertinoGlassToast(
            context,
            'Get instant AI assistance here anytime, ask questions, manage your account, or solve issues with smart help.',
            isSuccess: true,
            position: ToastPosition.top,
          );
        });
        break;
      case 3:
        context.push('/menu'); // ✅ push
        Future.delayed(const Duration(milliseconds: 300), () {
          showCupertinoGlassToast(
            context,
            'Here you’ll find all the services you need.',
            isSuccess: true,
            position: ToastPosition.top,
          );
        });
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
