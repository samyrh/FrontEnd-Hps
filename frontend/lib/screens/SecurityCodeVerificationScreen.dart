import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SecurityCodeVerificationScreen extends StatefulWidget {
  final bool isFirstLogin;
  final bool fromLogin; // ✅ New param

  const SecurityCodeVerificationScreen({
    super.key,
    required this.isFirstLogin,
    this.fromLogin = false, // default to false
  });

  @override
  State<SecurityCodeVerificationScreen> createState() => _SecurityCodeVerificationScreenState();
}



class _SecurityCodeVerificationScreenState extends State<SecurityCodeVerificationScreen> {
  final int length = 6;
  final staticCode = "111111";
  bool isCodeCorrect = false;
  bool showError = false;

  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _codeFocus;

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(length, (_) => TextEditingController());
    _codeFocus = List.generate(length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index) {
    final value = _codeControllers[index].text;
    if (value.length > 1) {
      _codeControllers[index].text = value.substring(0, 1);
    }
    if (value.isNotEmpty && index < length - 1) {
      FocusScope.of(context).requestFocus(_codeFocus[index + 1]);
    }
    setState(() {});
  }

  void _verifyCode() {
    final entered = _codeControllers.map((e) => e.text).join();
    if (entered == staticCode) {
      setState(() {
        isCodeCorrect = true;
        showError = false;
      });
      _showSuccessModal();
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  void _showSuccessModal() {
    showGeneralDialog(
      context: context,
      barrierLabel: "Verified",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: AnimatedScale(
                    scale: anim1.value,
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
                            "Security Code Verified",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "🔐",
                            style: TextStyle(
                              fontSize: 100,
                              decoration: TextDecoration.none,
                              shadows: [
                                Shadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
                                Shadow(color: Colors.white24, blurRadius: 40),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();

                              // ✅ Redirect to different route depending on source
                              Future.microtask(() {
                                if (widget.fromLogin) {
                                  context.go('/home'); // 🏠 Go home if from login
                                } else {
                                  context.go('/identify_user'); // 🔁 Stay in forgot/reset password flow
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Got it",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  decoration: TextDecoration.none,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        return SizedBox(
          width: 52,
          height: 62,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _codeControllers[i].text.isEmpty &&
                  i > 0) {
                FocusScope.of(context).requestFocus(_codeFocus[i - 1]);
                _codeControllers[i - 1].clear();
              }
            },
            child: Center(
              child: TextField(
                controller: _codeControllers[i],
                focusNode: _codeFocus[i],
                maxLength: 1,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 1,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade500),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                cursorColor: Colors.grey.shade800,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onChanged(i),
              ),
            ),
          ),
        );
      }),
    );
  }

  bool get _isAllFilled => _codeControllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2F3F5),
            Color(0xFFEDEEF0),
            Color(0xFFE8E9EB),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "🔐",
                  style: TextStyle(
                    fontSize: 120,
                    shadows: [
                      Shadow(color: Colors.black12, blurRadius: 60, offset: Offset(0, 10)),
                      Shadow(color: Colors.white30, blurRadius: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Verify Security Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter the 6-digit security code sent to your device",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _buildInputs(),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isAllFilled ? _verifyCode : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black12,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBEBEBE), Color(0xFFA8A8A8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 52),
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showError)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE6E6), Color(0xFFFFCCCC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Incorrect code. Please try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
