import 'dart:math';
import 'package:flutter/material.dart';

class FlippableCard extends StatelessWidget {
  final Animation<double> animation;
  final bool isRequestSent;
  final Gradient cardGradient;
  final VoidCallback onTap;
  final String cardholderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String packName;
  final bool showCvv;

  const FlippableCard({
    Key? key,
    required this.animation,
    required this.isRequestSent,
    required this.cardGradient,
    required this.onTap,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.packName,
    required this.showCvv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final showFront = animation.value <= pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value),
            child: showFront
                ? _buildFrontCard()
                : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: _buildBackCard(),
            ),
          );
        },
      ),
    );
  }

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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Image.asset('assets/visa_logo.png', width: 50, height: 50),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRequestSent ? '**** **** *** ${cardNumber.isNotEmpty ? cardNumber.substring(cardNumber.length - 3) : "***"}' : cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
          ],
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
                    style: const TextStyle(fontSize: 13, color: Colors.white)),
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
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

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
            const Text('CVV', style: TextStyle(color: Colors.white70)),
            Container(
              width: 60,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isRequestSent ? '•••' : (showCvv ? cvv : '•••'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Signature', style: TextStyle(fontSize: 10, color: Colors.white54)),
            Text(
              isRequestSent ? '**/**' : 'Valid Thru $expiryDate',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _cardContainer({required Widget child}) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, 12))
        ],
      ),
      child: child,
    );
  }
} 