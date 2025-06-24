import 'package:flutter/material.dart';
import '../UltraSwitch.dart';

class EcommerceToggle extends StatelessWidget {
  final bool isBlocked;
  final bool isCardLocked;
  final bool isEcommerceEnabled;
  final ValueChanged<bool> onChanged;

  const EcommerceToggle({
    Key? key,
    required this.isBlocked,
    required this.isCardLocked,
    required this.isEcommerceEnabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = isBlocked || isCardLocked;

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
                Icon(Icons.shopping_cart_checkout, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "E-Commerce Payments",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                UltraSwitch(
                  value: isBlocked ? false : isEcommerceEnabled,
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
