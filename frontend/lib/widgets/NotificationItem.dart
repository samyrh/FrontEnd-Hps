import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String message;
  final String timeAgo;
  final String type;
  final VoidCallback onClear;

  const NotificationItem({
    Key? key,
    required this.icon,
    required this.message,
    required this.timeAgo,
    required this.type,
    required this.onClear,
  }) : super(key: key);

  Future<bool> showiOS18ConfirmModal(BuildContext context, GlobalKey itemKey) async {
    // ✅ Smooth scroll into view
    await Scrollable.ensureVisible(
      itemKey.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // ✅ Add this small delay to allow swipe animation to reset
    await Future.delayed(const Duration(milliseconds: 100));

    // ✅ Then show modal
    return await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDFEFF), Color(0xFFECEFF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Clear Notification?",
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label,
                      letterSpacing: -0.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This action cannot be undone.",
                    style: TextStyle(
                      fontSize: 14.5,
                      color: CupertinoColors.systemGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(20),
                          color: CupertinoColors.systemGrey5,
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(20),
                          color: CupertinoColors.systemRed,
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Clear",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final itemKey = GlobalKey(); // for auto-scroll

    return Dismissible(
      key: Key(message + timeAgo),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showiOS18ConfirmModal(context, itemKey),
      onDismissed: (_) => onClear(),
      background: Container(),
      child: Padding(
        key: itemKey,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FFFB), Color(0xFFEFF5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: type.contains("BLOCKED") || type.contains("CANCELED")
                            ? CupertinoColors.systemRed
                            : CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'APP NAME',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.systemGrey2,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                            letterSpacing: -0.1,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '3 more notifications',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
