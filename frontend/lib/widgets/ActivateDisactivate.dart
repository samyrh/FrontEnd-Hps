import 'package:flutter/material.dart';

class ActivateDisactivate extends StatelessWidget {
  final Widget toggleSwitch;

  const ActivateDisactivate({
    Key? key,
    required this.toggleSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFD1D1D6);
    const bgColor = Color(0xFFF2F2F7);
    const labelColor = Color(0xFF1C1C1E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        // Same styled row as in BlockCardToggle
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
                'Activate / Deactivate Card',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              toggleSwitch,
            ],
          ),
        ),
      ],
    );
  }
}
