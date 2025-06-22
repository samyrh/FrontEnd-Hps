import 'package:flutter/material.dart';
import '../../../dto/card_dto/EventResponseDTO.dart';
import '../services/event/EventService.dart';

class AlertsWidget extends StatefulWidget {
  final VoidCallback? onViewAll;

  const AlertsWidget({super.key, this.onViewAll});

  @override
  State<AlertsWidget> createState() => _AlertsWidgetState();
}

class _AlertsWidgetState extends State<AlertsWidget> {
  List<EventResponseDTO> _latestEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventService().fetchCardholderEvents();
      setState(() {
        _latestEvents = events.take(5).toList(); // Only 5 latest events
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading alerts: $e");
      setState(() {
        _latestEvents = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
              onPressed: widget.onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                backgroundColor: const Color(0xFFEAEAEC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_latestEvents.isEmpty)
          const Text(
            "No alerts available.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          )
        else
          ..._latestEvents.map((event) => _buildAlertCard(event)).toList(),
      ],
    );
  }

  Widget _buildAlertCard(EventResponseDTO event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Enlarged icon with perfect centering
          SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Icon(
                _getIconByCategory(event.category),
                size: 30, // 🔥 ~40% bigger than before (was 22)
                color: _getIconColor(event.category),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFormattedCategory(event.category),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.message ?? "No message available.",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF3C3C43),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconByCategory(String? category) {
    switch (category) {
      case 'VIRTUAL_CARD_BLOCKED':
      case 'PHYSICAL_CARD_BLOCKED':
        return Icons.lock_outline_rounded;
      case 'VIRTUAL_CARD_UNBLOCKED':
      case 'PHYSICAL_CARD_UNBLOCKED':
        return Icons.lock_open_rounded;
      case 'VIRTUAL_CARD_CANCELED':
      case 'PHYSICAL_CARD_CANCELED':
        return Icons.cancel_rounded;
      case 'PAYMENT_RECEIVED':
        return Icons.attach_money;
      case 'SECURITY_ALERT':
        return Icons.shield_outlined;
      case 'CARD_CREATED':
        return Icons.credit_card;
      case 'LOGIN_ATTEMPT':
        return Icons.login_rounded;
      case 'OFFER_AVAILABLE':
        return Icons.local_offer_outlined;
      case 'CARD_REPLACED':
        return Icons.swap_horiz;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getIconColor(String? category) {
    switch (category) {
      case 'VIRTUAL_CARD_BLOCKED':
      case 'PHYSICAL_CARD_BLOCKED':
        return const Color(0xFFFF3B30); // iOS Red
      case 'VIRTUAL_CARD_UNBLOCKED':
      case 'PHYSICAL_CARD_UNBLOCKED':
        return const Color(0xFF30D158); // iOS Green
      case 'VIRTUAL_CARD_CANCELED':
      case 'PHYSICAL_CARD_CANCELED':
        return const Color(0xFFFF9F0A); // iOS Orange
      case 'PAYMENT_RECEIVED':
        return const Color(0xFF32D74B); // iOS Green
      case 'SECURITY_ALERT':
        return const Color(0xFF5856D6); // iOS Purple
      case 'LOGIN_ATTEMPT':
        return const Color(0xFFFFCC00); // iOS Yellow
      case 'OFFER_AVAILABLE':
        return const Color(0xFF007AFF); // iOS Blue
      case 'CARD_REPLACED':
        return const Color(0xFF5AC8FA); // iOS Cyan
      case 'CARD_CREATED':
        return const Color(0xFF34C759); // iOS Green
      default:
        return const Color(0xFF8E8E93); // iOS Gray
    }
  }

  String _getFormattedCategory(String? category) {
    return category?.replaceAll("_", " ").toUpperCase() ?? 'UNKNOWN';
  }
}
