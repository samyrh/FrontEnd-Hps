import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/otp_verfication/OtpService.dart';

class OtpVerificationDialog extends StatefulWidget {
  final void Function(String otp) onConfirmed;
  final String username;

  const OtpVerificationDialog({
    super.key,
    required this.onConfirmed,
    required this.username,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _isInvalid = false;
  bool _isLoading = false;
  int _seconds = 30;
  bool _canResend = false;
  Timer? _timer;

  String get otp => _controllers.map((c) => c.text.trim()).join(); // ✅ Per-digit trim
  bool get isOtpComplete => otp.length == 6;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
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

  Future<void> _validateOtp() async {
    setState(() {
      _isInvalid = false;
      _isLoading = true;
    });

    final code = otp;
    print('📨 Verifying OTP: "$code" for user: ${widget.username}'); // ✅ Debug log

    final isValid = await OtpService.verifyOtp(
      username: widget.username,
      otp: code,
    );

    setState(() => _isLoading = false);

    if (isValid) {
      widget.onConfirmed(code);
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _isInvalid = true);
      _shakeController.forward(from: 0);
    }
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
              title: const Text('OTP Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the 6-digit code sent to your email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.5, color: CupertinoColors.systemGrey),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 42,
                        height: 50,
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
                          child: CupertinoTextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // ✅ digits only
                            textAlign: TextAlign.center,
                            showCursor: true,
                            placeholder: '•',
                            autofocus: index == 0,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isInvalid ? CupertinoColors.destructiveRed : CupertinoColors.systemGrey4,
                                width: 1.3,
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (val.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
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
                        _canResend ? 'Resend OTP' : 'Resend in $_seconds s',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _canResend ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel', style: TextStyle(color: CupertinoColors.destructiveRed)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  onPressed: isOtpComplete && !_isLoading ? _validateOtp : null,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
