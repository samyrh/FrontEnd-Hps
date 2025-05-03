import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ToastPosition { top, center, bottom }

void showCupertinoGlassToast(
    BuildContext context,
    String message, {
      bool isSuccess = true,
      ToastPosition position = ToastPosition.bottom,
    }) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  double topPadding;
  switch (position) {
    case ToastPosition.top:
      topPadding = 60;
      break;
    case ToastPosition.center:
      topPadding = MediaQuery.of(context).size.height / 2 - 70;
      break;
    case ToastPosition.bottom:
    default:
      topPadding = MediaQuery.of(context).size.height - 170;
  }

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - value) * -25),
              child: child,
            ),
          );
        },
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.up,
          onDismissed: (_) => entry.remove(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isSuccess
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.xmark_circle_fill,
                      color: isSuccess
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemRed,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                          height: 1.35,
                          decoration: TextDecoration.none,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlay.mounted) {
      entry.remove();
    }
  });
}
