import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String imageUrl;
  final String message;
  final String timeAgo;
  final String type;

  const NotificationItem({
    Key? key,
    required this.imageUrl,
    required this.message,
    required this.timeAgo,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                type == 'Block Card'
                    ? Icons.warning_amber_rounded
                    : Icons.notifications,
                color: type == 'Block Card' ? Colors.redAccent : Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
