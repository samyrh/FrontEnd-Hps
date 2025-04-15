import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CreditCardItem extends StatefulWidget {
  final String title;
  final String number;
  final Color color;

  const CreditCardItem({
    Key? key,
    required this.title,
    required this.number,
    required this.color,
  }) : super(key: key);

  @override
  State<CreditCardItem> createState() => _CreditCardItemState();
}

class _CreditCardItemState extends State<CreditCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  bool showCvv = false;
  Timer? _autoFlipTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _flipCard({bool autoFlipBack = true}) {
    if (isFront) {
      _controller.forward();
      setState(() => showCvv = true);

      if (autoFlipBack) {
        _autoFlipTimer?.cancel();
        _autoFlipTimer = Timer(const Duration(seconds: 5), () {
          if (!isFront && mounted) {
            _flipCard(autoFlipBack: false);
          }
        });
      }
    } else {
      _controller.reverse();
      setState(() => showCvv = false);
    }
    isFront = !isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoFlipTimer?.cancel();
    super.dispose();
  }

  Gradient _getCardGradient() {
    if (widget.title.toLowerCase().contains('visa')) {
      return const LinearGradient(
        colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (widget.title.toLowerCase().contains('master')) {
      return const LinearGradient(
        colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Widget _cardContainer({required Widget child, Gradient? gradient}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFront() {
    return _cardContainer(
      gradient: _getCardGradient(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Image.asset(
                widget.title.toLowerCase().contains('visa')
                    ? 'assets/visa_logo.png'
                    : 'assets/mastercard_logo.png',
                width: 40,
                height: 40,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('**** **** ****',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(widget.number,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 3)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARDHOLDER',
                      style: TextStyle(fontSize: 10, color: Colors.white54)),
                  SizedBox(height: 4),
                  Text('Nada S. Rhandor',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES',
                      style: TextStyle(fontSize: 10, color: Colors.white54)),
                  SizedBox(height: 4),
                  Text('08/26',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _cardContainer(
      gradient: _getCardGradient(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CVV',
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: showCvv
                    ? Container(
                  key: const ValueKey('cvv'),
                  width: 80,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('527',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                )
                    : Container(
                  key: const ValueKey('hidden'),
                  width: 80,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.visibility_off,
                      size: 18, color: Colors.black54),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Authorized Signature',
                  style: TextStyle(fontSize: 11, color: Colors.white54)),
              Text('Valid Thru 08/26',
                  style: TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16), // 👈 Pushes the card down by 16 pixels
      child: GestureDetector(
        onTap: _flipCard,
        onLongPressStart: (_) => setState(() => showCvv = true),
        onLongPressEnd: (_) => setState(() => showCvv = false),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isFrontVisible = _animation.value <= pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(
                        16 * sin(_animation.value),
                        8 * cos(_animation.value),
                      ),
                      blurRadius: 20 + 10 * sin(_animation.value.abs()),
                    ),
                  ],
                ),
                child: isFrontVisible
                    ? _buildFront()
                    : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildBack(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
