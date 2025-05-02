import 'package:flutter/material.dart';

class AlertsWidget extends StatelessWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alerts',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                backgroundColor: const Color(0xFFEAEAEC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF1C1C1E),
                  ),
                ],
              ),
            ),

          ],
        ),
        const SizedBox(height: 12),
        ..._alerts.map((alert) => _buildAlertCard(alert)).toList(),
      ],
    );
  }

  Widget _buildAlertCard(_Alert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, color: alert.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Alert {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Alert({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<_Alert> _alerts = [
  _Alert(
    title: 'Unusual Login Attempt',
    description: 'Someone tried logging in from a new device.',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFFF3B30),
  ),
  _Alert(
    title: 'Payment Received',
    description: 'You received \$150.00 from Axians.',
    icon: Icons.attach_money,
    color: Color(0xFF32D74B),
  ),
  _Alert(
    title: 'New Offer Available',
    description: 'Check out your new cashback rewards.',
    icon: Icons.local_offer_outlined,
    color: Color(0xFF007AFF),
  ),
];