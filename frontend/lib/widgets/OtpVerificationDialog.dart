import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Toast.dart';

class OtpVerificationDialog extends StatefulWidget {
  final void Function(String otp) onConfirmed;

  const OtpVerificationDialog({super.key, required this.onConfirmed});

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes =
  List.generate(4, (_) => FocusNode()); // For RawKeyboardListener

  int _seconds = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _canResend = false;
      _seconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _resendOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _startCountdown();

    showCupertinoGlassToast(
      context,
      'OTP resent',
      isSuccess: true,
      position: ToastPosition.top,
    );
  }

  String get otp => _controllers.map((controller) => controller.text).join().trim();
  bool get isOtpComplete => otp.length == 4;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label,
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: Column(
          children: [
            const Text(
              'Enter the 4-digit code sent to your phone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Smooth OTP Boxes
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 48,
                      height: 52,
                      child: RawKeyboardListener(
                        focusNode: _keyboardFocusNodes[index],
                        onKey: (event) {
                          if (event is RawKeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.backspace &&
                              _controllers[index].text.isEmpty &&
                              index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _focusNodes[index].hasFocus
                                ? [
                              BoxShadow(
                                color: CupertinoColors.systemGrey2.withOpacity(0.6),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                                : [],
                          ),
                          child: CupertinoTextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            autofocus: index == 0,
                            showCursor: true,
                            cursorColor: CupertinoColors.activeBlue,
                            padding: const EdgeInsets.only(bottom: 8),
                            placeholder: '•',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              setState(() {});
                            },
                            onTap: () {
                              _keyboardFocusNodes[index].requestFocus();
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 14),
            GestureDetector(
              onTap: _canResend ? _resendOtp : null,
              child: AnimatedOpacity(
                opacity: _canResend ? 1 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _canResend ? 'Resend OTP' : 'Resend in $_seconds s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _canResend
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ),
        CupertinoDialogAction(
          isDestructiveAction: false,
          onPressed: isOtpComplete
              ? () {
            widget.onConfirmed(otp);
            Navigator.of(context).pop();
          }
              : null,
          child: Text(
            'Confirm',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isOtpComplete
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
            ),
          ),
        ),
      ],
    );
  }
}
