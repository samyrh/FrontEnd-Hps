import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const NotificationHeader({Key? key, required this.title, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB).withOpacity(0.98),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.05),
              ),
              child: const Icon(CupertinoIcons.back, size: 20),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(width: 32), // spacing to balance the back icon
        ],
      ),
    );
  }
}
