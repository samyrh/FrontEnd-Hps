import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dto/card_dto/card_model.dart';

class CreditCardItem extends StatefulWidget {
  final CardModel card;
  final bool isDisabled;
  final String? badgeLabel;
  final Color? badgeColor;
  final void Function(String cardId)? onTap;
  final Widget? customOverlay;

  const CreditCardItem({
    Key? key,
    required this.card,
    this.isDisabled = false,
    this.badgeLabel,
    this.badgeColor,
    this.onTap,
    this.customOverlay, // ✅ Add this here
  }) : super(key: key);


  @override
  State<CreditCardItem> createState() => _CreditCardItemState();
}

class _CreditCardItemState extends State<CreditCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  bool showCvv = false;
  Timer? _autoFlipTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoFlipTimer?.cancel();
    super.dispose();
  }

  void _flipCard({bool autoFlipBack = true}) {
    if (widget.isDisabled) return;

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

  Gradient _getGradient() {
    if (widget.isDisabled) {
      return const LinearGradient(
        colors: [Color(0xFFBDBDBD), Color(0xFFE0E0E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final start = widget.card.gradientStartColor;
    final end = widget.card.gradientEndColor;
    return LinearGradient(
      colors: [_hexToColor(start), _hexToColor(end)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Widget _cardContainer({required Widget child}) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: width * 0.9,
          height: height * 0.26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: _getGradient(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Padding(padding: const EdgeInsets.all(24), child: child),
                if (widget.isDisabled)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                    child: Container(
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.isDisabled && widget.customOverlay != null)
          Positioned.fill(
            child: Center(child: widget.customOverlay!),
          ),
      ],
    );
  }

  Widget _buildFront() => _cardContainer(child: _buildFrontContent());
  Widget _buildBack() => _cardContainer(child: _buildBackContent());

  Widget _buildFrontContent() {
    final card = widget.card;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(card.cardPack.label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            Image.asset(
              card.cardPack.label.toLowerCase().contains('visa')
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
                style: TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(
              _maskCardNumber(card.cardNumber),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 3),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CARDHOLDER', style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(card.cardholderName, style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('EXPIRES', style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(card.expirationDate, style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackContent() {
    final card = widget.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CVV', style: TextStyle(fontSize: 14, color: Colors.white70)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
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
                child: const Text('***',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2)),
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
                child: const Icon(Icons.visibility_off, size: 18, color: Colors.black54),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Authorized Signature', style: TextStyle(fontSize: 11, color: Colors.white54)),
            Text('Valid Thru ${card.expirationDate}',
                style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () {
          // ✅ Always allow tap to go to details, even if disabled
          if (widget.card.type == 'PHYSICAL') {
            context.push('/physical_card_details', extra: {'id': widget.card.id.toString()});
          } else {
            context.push('/virtual_card_details', extra: {'id': widget.card.id.toString()});
          }
        },

        onDoubleTap: () {
          // ✅ Double tap: Flip card
          if (!widget.isDisabled) _flipCard();
        },
        onLongPressStart: (_) {
          if (!widget.isDisabled) setState(() => showCvv = true);
        },
        onLongPressEnd: (_) {
          if (!widget.isDisabled) setState(() => showCvv = false);
        },
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
                      offset: Offset(16 * sin(_animation.value), 8 * cos(_animation.value)),
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

  String _maskCardNumber(String number) {
    final trimmed = number.replaceAll(' ', '');
    if (trimmed.length <= 3) return '**** **** **** $trimmed';
    final last3 = trimmed.substring(trimmed.length - 3);
    return '**** **** **** $last3';
  }
}
