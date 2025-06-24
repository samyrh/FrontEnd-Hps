import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String label;

  const NotificationToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label, // 👈 Add this
    this.activeColor = const Color(0xFF30D158),
    this.inactiveColor = const Color(0xFFE5E5EA),
  }) : super(key: key);
  @override
  State<NotificationToggleSwitch> createState() => _NotificationToggleSwitchState();
}

class _NotificationToggleSwitchState extends State<NotificationToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbPosition;
  late Animation<double> _thumbScale;
  late Animation<Color?> _trackColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _thumbPosition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _thumbScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    _trackColor = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.value) _controller.value = 1;
  }

  @override
  void didUpdateWidget(NotificationToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  void _toggleSwitch() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    const trackWidth = 52.0;
    const trackHeight = 32.0;
    const thumbSize = 24.0;
    final margin = (trackHeight - thumbSize) / 2;
    final maxOffset = trackWidth - thumbSize - margin * 2;

    return GestureDetector(
      onTap: _toggleSwitch,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              color: _trackColor.value,
              borderRadius: BorderRadius.circular(trackHeight / 2),
              boxShadow: [
                if (_controller.value > 0.5)
                  BoxShadow(
                    color: widget.activeColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: margin + (maxOffset * _thumbPosition.value),
                  top: margin,
                  child: Transform.scale(
                    scale: _thumbScale.value,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}