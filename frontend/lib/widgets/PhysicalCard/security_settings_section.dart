import 'package:flutter/material.dart';
import '../UltraSwitch.dart';

class SecuritySettingsSection extends StatelessWidget {
  final bool isBlocked;
  final bool isContactlessEnabled;
  final bool isEcommerceEnabled;
  final bool isTpePaymentEnabled;
  final Function(bool) onContactlessChanged;
  final Function(bool) onEcommerceChanged;
  final Function(bool) onTpeChanged;
  final bool isPendingApproval;

  const SecuritySettingsSection({
    Key? key,
    required this.isBlocked,
    required this.isContactlessEnabled,
    required this.isEcommerceEnabled,
    required this.isTpePaymentEnabled,
    required this.onContactlessChanged,
    required this.onEcommerceChanged,
    required this.onTpeChanged,
    this.isPendingApproval = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Security Settings"),
        _buildContactlessToggle(),
        _buildEcommerceToggle(),
        _buildTpeToggle(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1E),
        ),
      ),
    );
  }

  Widget _buildContactlessToggle() {
    return _buildToggleItem(
      label: "Contactless Payments",
      icon: Icons.nfc,
      value: isContactlessEnabled,
      onChanged: onContactlessChanged,
    );
  }

  Widget _buildEcommerceToggle() {
    return _buildToggleItem(
      label: "E-Commerce Payments",
      icon: Icons.shopping_cart_checkout,
      value: isEcommerceEnabled,
      onChanged: onEcommerceChanged,
    );
  }

  Widget _buildTpeToggle() {
    return _buildToggleItem(
      label: "TPE Payments",
      icon: Icons.point_of_sale,
      value: isTpePaymentEnabled,
      onChanged: onTpeChanged,
    );
  }

  Widget _buildToggleItem({
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDisabled = isBlocked || isPendingApproval;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1,
        child: IgnorePointer(
          ignoring: isDisabled,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1D1D6)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                UltraSwitch(
                  value: isDisabled ? false : value,
                  onChanged: onChanged,
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 