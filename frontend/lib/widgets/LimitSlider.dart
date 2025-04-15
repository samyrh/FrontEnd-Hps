import 'package:flutter/material.dart';

class LimitSliderWidget extends StatefulWidget {
  final double currentValue;
  final double maxValue;
  final ValueChanged<double> onChanged;

  const LimitSliderWidget({
    Key? key,
    required this.currentValue,
    required this.maxValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LimitSliderWidget> createState() => _LimitSliderWidgetState();
}

class _LimitSliderWidgetState extends State<LimitSliderWidget> with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _bubbleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    );
  }

  void _onDragStart() {
    setState(() => _isDragging = true);
    _bubbleController.forward();
  }

  void _onDragEnd() {
    _bubbleController.reverse().then((_) {
      setState(() => _isDragging = false);
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        margin: const EdgeInsets.symmetric(vertical: 4), // Reduced vertical margin
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Less padding
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                trackShape: const RoundedRectSliderTrackShape(),
                activeTrackColor: const Color(0xFFBDBDBD),   // Same grey for left side
                inactiveTrackColor: const Color(0xFFBDBDBD), // Same grey for right side
                thumbColor: const Color(0xFFBDBDBD),         // Grey thumb
                overlayColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: widget.currentValue,
                min: 0,
                max: widget.maxValue,
                divisions: 100,
                onChanged: widget.onChanged,
                onChangeStart: (_) => _onDragStart(),
                onChangeEnd: (_) => _onDragEnd(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _label(String value, {bool isActive = false}) {
    return Text(
      value,
      style: TextStyle(
        fontSize: isActive ? 14 : 12,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive ? const Color(0xFF1C1C1E) : const Color(0xFF8E8E93),
      ),
    );
  }
}

class _ModernGlassThumbWithBubble extends SliderComponentShape {
  final bool isDragging;
  final double currentValue;
  final Animation<double> bubbleScale;
  final Animation<double> bubbleOpacity;

  _ModernGlassThumbWithBubble({
    required this.isDragging,
    required this.currentValue,
    required this.bubbleScale,
    required this.bubbleOpacity,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 70);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final canvas = context.canvas;

    // Thumb
    const double thumbRadius = 10;
    final Paint thumbPaint = Paint()..color = const Color(0xFF007AFF);
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, thumbPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);

    if (isDragging) {
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            const TextSpan(
              text: '\$',
              style: TextStyle(
                fontSize: 18, // Bigger $
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            TextSpan(
              text: '${currentValue.toInt()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: textDirection,
      )..layout();

      final double scale = bubbleScale.value;
      final double opacity = bubbleOpacity.value;
      final double width = textPainter.width + 20;
      const double height = 34; // Slightly taller for a cleaner look

      // Applying glassmorphism-style effect
      final Paint bubblePaint = Paint()
        ..color = const Color(0xFFE5E5EA).withAlpha((opacity * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3) // Subtle blur for glass effect
        ..style = PaintingStyle.fill;

      // Bubble's rounded pill shape
      final RRect bubble = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 40), // Higher bubble position
          width: width * scale,
          height: height * scale,
        ),
        Radius.circular(16 * scale), // More rounded for iOS elegance
      );

      // Drawing the bubble with light shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1) // Light shadow for modern depth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      // Adding shadow before drawing the bubble
      canvas.drawRRect(bubble, shadowPaint);
      canvas.drawRRect(bubble, bubblePaint);

      // Drawing the text within the bubble
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - 40 - textPainter.height / 2),
      );
    }
  }
}
