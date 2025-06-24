import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusPillBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final IconData icon;

  const StatusPillBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.5, sigmaY: 10.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor.withOpacity(0.25),
                backgroundColor.withOpacity(0.16),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: backgroundColor.withOpacity(0.3),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white.withOpacity(0.95),
              ),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.97),
                  letterSpacing: 0.8,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
