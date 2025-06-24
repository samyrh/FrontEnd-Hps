import 'dart:ui';
import 'package:flutter/material.dart';

class PinPopup extends StatelessWidget {
  final bool show;
  final String pin;
  final int countdown;

  const PinPopup({
    Key? key,
    required this.show,
    required this.pin,
    required this.countdown,
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
              scale: show ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Your PIN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      pin,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(color: Colors.white24, blurRadius: 6),
                          Shadow(color: Colors.black45, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "This will close in $countdown sec",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
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
