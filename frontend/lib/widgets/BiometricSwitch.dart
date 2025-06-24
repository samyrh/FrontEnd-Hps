import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiometricSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const BiometricSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF007AFF), // iOS blue
    this.inactiveColor = const Color(0xFFE5E5EA),
  }) : super(key: key);

  @override
  State<BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<BiometricSwitch>
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
      duration: const Duration(milliseconds: 400),
    );

    _thumbPosition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _thumbScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _trackColor = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_controller);

    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant BiometricSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    const double trackWidth = 52;
    const double trackHeight = 32;
    const double thumbSize = 24;
    final double margin = (trackHeight - thumbSize) / 2;
    final double maxOffset = trackWidth - thumbSize - 2 * margin;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
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
                  left: margin + maxOffset * _thumbPosition.value,
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
                            color: Colors.black.withOpacity(0.12),
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
