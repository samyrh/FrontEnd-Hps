import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationDialog extends StatefulWidget {
  final void Function(String otp) onConfirmed;

  const OtpVerificationDialog({super.key, required this.onConfirmed});

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(4, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isInvalid = false;
  int _seconds = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
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
    setState(() => _isInvalid = false);
  }

  String get otp => _controllers.map((controller) => controller.text).join().trim();
  bool get isOtpComplete => otp.length == 4;

  void _validateOtp() {
    if (otp == "1111") {
      widget.onConfirmed(otp);
      Navigator.of(context).pop();
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _isInvalid = true);
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: CupertinoAlertDialog(
              title: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'OTP Verification',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                child: Column(
                  children: [
                    const Text(
                      'Enter the 4-digit code sent to your phone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.5, color: CupertinoColors.systemGrey),
                    ),
                    const SizedBox(height: 20),
                    Row(
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
                                  border: _isInvalid ? Border.all(color: Colors.redAccent, width: 1.4) : null,
                                ),
                                child: CupertinoTextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center, // Ensures value is centered
                                  maxLength: 1,
                                  autofocus: index == 0,
                                  showCursor: true,
                                  cursorColor: CupertinoColors.activeBlue,
                                  padding: const EdgeInsets.only(bottom: 8),
                                  placeholder: '•',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const BoxDecoration(color: Colors.transparent),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                    setState(() {});
                                  },
                                  onTap: () => _keyboardFocusNodes[index].requestFocus(),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    if (_isInvalid)
                      const Text(
                        "Incorrect code. Please try again.",
                        style: TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _canResend ? _resendOtp : null,
                      child: AnimatedOpacity(
                        opacity: _canResend ? 1 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _canResend ? 'Resend OTP' : 'Resend in $_seconds s', // Countdown here
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _canResend ? CupertinoColors.activeBlue : CupertinoColors.systemGrey2,
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
                  child: const Text('Cancel', style: TextStyle(color: CupertinoColors.destructiveRed)),
                ),
                CupertinoDialogAction(
                  onPressed: isOtpComplete ? _validateOtp : null,
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isOtpComplete ? CupertinoColors.activeBlue : CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
