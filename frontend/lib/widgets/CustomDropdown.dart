import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<DropdownItem> items;
  final DropdownItem? selectedItem;
  final ValueChanged<DropdownItem> onChanged;
  final IconData? icon;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.selectedItem,
  }) : super(key: key);

  void _showModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Dropdown",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, _, __) {
        return _DropdownModal(
          items: items,
          selectedItem: selectedItem,
          onSelected: onChanged,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInExpo,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF8E8E93);
    const textColor = Color(0xFF1C1C1E);
    const bg = Color(0xFFE5E5EA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: muted,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        GestureDetector(
          onTap: () => _showModal(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD1D1D6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: muted, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      selectedItem?.label ?? 'Select',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right_rounded, color: muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownItem {
  final String label;
  final String? value;
  final IconData? icon;

  const DropdownItem({required this.label, this.value, this.icon});
}

class _DropdownModal extends StatelessWidget {
  final List<DropdownItem> items;
  final DropdownItem? selectedItem;
  final ValueChanged<DropdownItem> onSelected;

  const _DropdownModal({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF1C1C1E);
    const muted = Color(0xFF8E8E93);
    const selectedBackground = Color(0xFFE5E5EA);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              ...items.map((item) {
                final isSelected = item.label == selectedItem?.label;
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(item);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: isSelected
                        ? BoxDecoration(
                      color: selectedBackground,
                      borderRadius: BorderRadius.circular(16),
                    )
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon,
                            color: isSelected ? selectedColor : muted, size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? selectedColor : muted,
                              fontFamily: 'SF Pro Text',
                              shadows: [
                                Shadow(
                                  color: isSelected
                                      ? Colors.black.withOpacity(0.05)
                                      : Colors.transparent,
                                  offset: const Offset(0, 1),
                                  blurRadius: 1.2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              size: 20, color: Color(0xFF007AFF)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
