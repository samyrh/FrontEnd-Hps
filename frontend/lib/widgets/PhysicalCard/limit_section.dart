import 'dart:math';
import 'package:flutter/material.dart';
import '../CustomDropdown.dart';

class LimitSection extends StatelessWidget {
  final bool isBlocked;
  final DropdownItem? selectedLimitType;
  final List<DropdownItem> limitTypes;
  final Function(DropdownItem) onLimitTypeChanged;
  final double selectedLimit;
  final Function(double) onLimitChanged;
  final Function(double) onChangeEnd;
  final double maxLimit;
  final VoidCallback scrollToBottom;

  const LimitSection({
    Key? key,
    required this.isBlocked,
    this.selectedLimitType,
    required this.limitTypes,
    required this.onLimitTypeChanged,
    required this.selectedLimit,
    required this.onLimitChanged,
    required this.onChangeEnd,
    required this.maxLimit,
    required this.scrollToBottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Manage Limits"),
        Opacity(
          opacity: isBlocked ? 0.4 : 1,
          child: IgnorePointer(
            ignoring: isBlocked,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CustomDropdown(
                icon: Icons.tune,
                selectedItem: selectedLimitType,
                items: limitTypes,
                onChanged: (value) {
                  onLimitTypeChanged(value);
                  scrollToBottom();
                },
                label: '',
              ),
            ),
          ),
        ),
        if (selectedLimitType != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Opacity(
              opacity: isBlocked ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: isBlocked,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD1D1D6)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Spending Limit",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, animation) {
                                  final fade = FadeTransition(
                                      opacity: animation, child: child);
                                  final slide = SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: fade,
                                  );
                                  return slide;
                                },
                                child: Text(
                                  "\$${(isBlocked ? 0 : selectedLimit).toInt()}",
                                  key: ValueKey<int>(
                                      (isBlocked ? 0 : selectedLimit).toInt()),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _limitColor(selectedLimit),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline,
                                      size: 13, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Max: \$${maxLimit.toInt()}",
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor:
                          const Color(0xFF007AFF), // iOS blue
                          inactiveTrackColor: const Color(
                              0xFFCED0D4), // iOS-style dark grey
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.5),
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbColor:
                          const Color(0xFF007AFF), // same as active track
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: selectedLimit.clamp(0, maxLimit),
                          min: 0,
                          max: maxLimit,
                          onChanged: (val) {
                            onLimitChanged(val.clamp(0, maxLimit));
                          },
                          onChangeEnd: (val) {
                            onChangeEnd(val.clamp(0, maxLimit));
                          },
                        ),
                      ),
                      _buildAvailableLimitMessage(
                        isBlocked ? 0 : selectedLimit,
                        maxLimit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  Color _limitColor(double value) {
    if (value <= 1000) return const Color(0xFF34C759);
    if (value <= 3000) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  Widget _buildAvailableLimitMessage(double selected, double max) {
    final double remaining = max - selected;
    final double percentUsed = selected / max;

    IconData icon;
    Color color;
    String message;

    if (percentUsed >= 1.0) {
      icon = Icons.block;
      color = Colors.redAccent;
      message = "Limit Reached";
    } else if (percentUsed >= 0.7) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orangeAccent;
      message = "Almost Reached – \$${remaining.toInt()} left";
    } else {
      icon = Icons.check_circle;
      color = Colors.green;
      message = "Available: \$${remaining.toInt()}";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                color.withOpacity(0.07),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 