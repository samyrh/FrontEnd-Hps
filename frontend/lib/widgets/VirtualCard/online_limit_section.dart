// online_limit_section.dart
import 'package:flutter/material.dart';
import 'ecommerce_toggle.dart';
import 'section_title.dart';


class OnlineLimitSection extends StatelessWidget {
  final double selectedLimit;
  final double maxLimit;
  final bool isBlocked;
  final bool isCardLocked;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool isSecurityOptionsLoading;
  final bool ecommerceEnabled;

  const OnlineLimitSection({
    super.key,
    required this.selectedLimit,
    required this.maxLimit,
    required this.isBlocked,
    required this.isCardLocked,
    required this.onChanged,
    this.onChangeEnd,
    required this.isSecurityOptionsLoading,
    required this.ecommerceEnabled,
  });

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

  @override
  Widget build(BuildContext context) {
    if (isSecurityOptionsLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Online Purchase Limit (Per Year)"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Opacity(
            opacity: (isBlocked || isCardLocked) ? 0.4 : 1,
            child: IgnorePointer(
              ignoring: (isBlocked || isCardLocked),
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
                          "Set Your Limit",
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
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                              child: Text(
                                "\$${(isBlocked ? 0 : selectedLimit).toInt()}",
                                key: ValueKey<int>((isBlocked ? 0 : selectedLimit).toInt()),
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
                                const Icon(Icons.info_outline, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Annual Cap: \$${maxLimit.toInt()}",
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
                        activeTrackColor: const Color(0xFF007AFF),
                        inactiveTrackColor: const Color(0xFFCED0D4),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbColor: const Color(0xFF007AFF),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: selectedLimit.clamp(0, maxLimit),
                        min: 0,
                        max: maxLimit,
                        onChanged: onChanged,
                        onChangeEnd: onChangeEnd,
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
}
