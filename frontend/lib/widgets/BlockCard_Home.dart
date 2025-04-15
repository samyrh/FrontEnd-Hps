import 'package:flutter/material.dart';
import 'CustomDropdown.dart';
import 'UltraSwitch.dart';

class BlockCardToggle extends StatefulWidget {
  const BlockCardToggle({super.key});

  @override
  State<BlockCardToggle> createState() => _BlockCardToggleState();
}

class _BlockCardToggleState extends State<BlockCardToggle> {
  bool _isBlocked = false;

  final List<DropdownItem> reasons = const [
    DropdownItem(label: 'Lost Card', icon: Icons.block),
    DropdownItem(label: 'Stolen', icon: Icons.warning_amber),
    DropdownItem(label: 'Damaged', icon: Icons.credit_card),
  ];

  DropdownItem? selectedReason;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFD1D1D6);
    const bgColor = Color(0xFFF2F2F7);
    const labelColor = Color(0xFF1C1C1E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 14),

        // ⏹ Row styled like an input field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Block this card',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              UltraSwitch(
                value: _isBlocked,
                onChanged: (val) {
                  setState(() => _isBlocked = val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 🔽 Show dropdown if blocked
        if (_isBlocked)
          AnimatedOpacity(
            opacity: _isBlocked ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: CustomDropdown(
              label: 'Reason for Blocking',
              icon: Icons.error_outline,
              items: reasons,
              selectedItem: selectedReason,
              onChanged: (item) {
                setState(() => selectedReason = item);
              },
            ),
          ),
      ],
    );
  }
}
