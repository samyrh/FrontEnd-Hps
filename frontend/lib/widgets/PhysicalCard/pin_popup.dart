import 'dart:ui';
import 'package:flutter/material.dart';

class PinPopup extends StatelessWidget {
  final bool showPinPopup;
  final int countdown;
  final bool isRequestSent;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;

  const PinPopup({
    Key? key,
    required this.showPinPopup,
    required this.countdown,
    required this.isRequestSent,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: AnimatedScale(
              scale: showPinPopup ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                width: 280,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 4)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Your PIN",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70)),
                    const SizedBox(height: 14),
                    Text(
                      isRequestSent ? '**** **** *** ${cardNumber.substring(cardNumber.length - 3)}' : cardNumber,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(color: Colors.white24, blurRadius: 6),
                          Shadow(
                              color: Colors.black45, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(cardholderName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60)),
                    const SizedBox(height: 16),
                    Text(isRequestSent ? '**/**' : expiryDate,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60)),
                    const SizedBox(height: 16),
                    Text(isRequestSent ? '•••' : cvv,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60)),
                    Text("This will close in $countdown sec",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 