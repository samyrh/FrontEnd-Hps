import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FlippableCard extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onTap; // Card tap event
  final bool isRequestSent;
  final String cardholderName;
  final String cardNumber;
  final String cvv;
  final String expiryDate;
  final Gradient cardGradient;
  final bool showCvv;
  final VoidCallback? onCvvInputTap; // CVV input tap event
  final bool isFront;
  final bool isFlippedByCvv;
  final String packName;

  const FlippableCard({
    super.key,
    required this.animation,
    required this.onTap,
    required this.isRequestSent,
    required this.cardholderName,
    required this.cardNumber,
    required this.cvv,
    required this.expiryDate,
    required this.cardGradient,
    required this.showCvv,
    required this.onCvvInputTap,
    required this.isFront,
    required this.isFlippedByCvv,
    required this.packName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Card tap event will just flip without revealing CVV
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final isFrontVisible = animation.value <= pi / 2;

          return Stack(
            children: [
              // Front card face (will show only when animation value is less than pi/2)
              _buildCardFace(isFrontVisible),
              // Back card face (will show only when animation value is greater than pi/2)
              _buildBackFace(isFrontVisible),
            ],
          );
        },
      ),
    );
  }

  // Build front face of the card
  Widget _buildCardFace(bool isFrontVisible) {
    return IgnorePointer(
      ignoring: !isFrontVisible,
      child: Opacity(
        opacity: isFrontVisible ? 1.0 : 0.0,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value),
          child: _buildFrontCard(),
        ),
      ),
    );
  }

  // Build back face of the card
  Widget _buildBackFace(bool isFrontVisible) {
    return IgnorePointer(
      ignoring: isFrontVisible,
      child: Opacity(
        opacity: isFrontVisible ? 0.0 : 1.0,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value + pi),
          child: _buildBackCard(),
        ),
      ),
    );
  }

  // Container for card (both front and back cards)
  Widget _cardContainer({required Widget child}) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.7, sigmaY: 0.7),
                child: Container(color: Colors.white.withOpacity(0.01)),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // Front card design
  Widget _buildFrontCard() => _cardContainer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              packName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            Image.asset('assets/visa_logo.png', width: 50, height: 50),
          ],
        ),
        Text(
          isRequestSent
              ? '**** **** *** ${cardNumber.substring(cardNumber.length - 3)}'
              : cardNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CARDHOLDER',
                    style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 2),
                Text(cardholderName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('EXPIRES',
                    style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 2),
                Text(
                  isRequestSent ? '**/**' : expiryDate,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // Back card design
  Widget _buildBackCard() => _cardContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CVV',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            onCvvInputTap == null
                ? Container(
              width: 70,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '•••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            )
                : GestureDetector(
              onTap: onCvvInputTap,
              child: Container(
                width: 70,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    showCvv ? cvv : '•••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Signature',
                style: TextStyle(fontSize: 12, color: Colors.white54)),
            Text(
              '**/**',  // Fallback for signature
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ],
    ),
  );
}
