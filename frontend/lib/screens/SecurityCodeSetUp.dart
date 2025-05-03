import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SecurityCodeSetupScreen extends StatefulWidget {
  const SecurityCodeSetupScreen({super.key});

  @override
  State<SecurityCodeSetupScreen> createState() => _SecurityCodeSetupScreenState();
}

class _SecurityCodeSetupScreenState extends State<SecurityCodeSetupScreen> {
  final int length = 6;
  bool isConfirmStep = false;
  bool codesMatch = false;

  late final List<TextEditingController> _codeControllers;
  late final List<TextEditingController> _confirmControllers;
  late final List<FocusNode> _codeFocus;
  late final List<FocusNode> _confirmFocus;

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(length, (_) => TextEditingController());
    _confirmControllers = List.generate(length, (_) => TextEditingController());
    _codeFocus = List.generate(length, (_) => FocusNode());
    _confirmFocus = List.generate(length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in [..._codeControllers, ..._confirmControllers]) {
      c.dispose();
    }
    for (final f in [..._codeFocus, ..._confirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, List<TextEditingController> controllers, List<FocusNode> focusList) {
    final value = controllers[index].text;
    if (value.length > 1) {
      controllers[index].text = value.substring(0, 1);
    }
    if (value.isNotEmpty && index < length - 1) {
      FocusScope.of(context).requestFocus(focusList[index + 1]);
    }

    if (isConfirmStep) {
      final orig = _codeControllers.map((e) => e.text).join();
      final confirm = _confirmControllers.map((e) => e.text).join();
      setState(() {
        codesMatch = orig == confirm && !_confirmControllers.any((c) => c.text.isEmpty);
      });
    }
  }

  void _generateCode() {
    final rand = Random();
    final code = List.generate(length, (_) => rand.nextInt(10).toString());

    for (int i = 0; i < length; i++) {
      _codeControllers[i].text = code[i];
      _confirmControllers[i].clear();
    }

    setState(() {
      isConfirmStep = true;
      codesMatch = false;
    });

    FocusScope.of(context).requestFocus(_confirmFocus[0]);
  }

  void _goToConfirm() {
    final filled = _codeControllers.every((c) => c.text.isNotEmpty);
    if (filled) {
      for (final controller in _confirmControllers) {
        controller.clear();
      }
      setState(() {
        isConfirmStep = true;
        codesMatch = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Now re-enter your security code to confirm."),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );

      FocusScope.of(context).requestFocus(_confirmFocus[0]);
    }
  }

  void _submitCode() {
    final code = _codeControllers.map((e) => e.text).join();

    showGeneralDialog(
      context: context,
      barrierLabel: "Security Code",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Colors.black.withOpacity(0.4),
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
                        "Security Code Set",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 6,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(color: Colors.white24, blurRadius: 6),
                            Shadow(color: Colors.black45, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              decoration: TextDecoration.none,
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
        );
      },
    );
  }

  Widget _buildInputs(List<TextEditingController> controllers, List<FocusNode> focusList) {
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
                  controllers[i].text.isEmpty &&
                  i > 0) {
                FocusScope.of(context).requestFocus(focusList[i - 1]);
                controllers[i - 1].clear();
              }
            },
            child: Center(
              child: TextField(
                controller: controllers[i],
                focusNode: focusList[i],
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
                onChanged: (value) => _onChanged(i, controllers, focusList),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2F3F5), // soft muted light gray
            Color(0xFFEDEEF0), // light faded iOS grey
            Color(0xFFE8E9EB), // very subtle bottom
          ],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final emojiHeight = constraints.maxHeight * 0.22;

              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),

                      // 💳 Emoji
                      Container(
                        height: emojiHeight,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "💳",
                          style: TextStyle(
                            fontSize: emojiHeight * 0.9,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 60,
                                offset: const Offset(0, 10),
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Text(
                        isConfirmStep ? "Confirm Security Code" : "Set Up Security Code",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32, // iOS-style large title
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E), // iOS default dark text
                          fontFamily: 'SF Pro Display', // Native iOS system font (optional if installed)
                          letterSpacing: -0.8,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Info Card
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDFDFD), Color(0xFFF6F6F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Why do I need this code?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2024),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your 6-digit security code will be required to:\n"
                                  "• Access your e-wallet\n"
                                  "• Authorize payments and withdrawals\n"
                                  "• Manage or block your cards\n"
                                  "• Approve sensitive operations securely",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Instruction
                      Text(
                        isConfirmStep
                            ? "Please re-enter your 6-digit code"
                            : "Enter a 6-digit code to secure your wallet",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),

                      const SizedBox(height: 24),

                      // Code Inputs
                      _buildInputs(
                        isConfirmStep ? _confirmControllers : _codeControllers,
                        isConfirmStep ? _confirmFocus : _codeFocus,
                      ),

                      const SizedBox(height: 28),

                      // Confirm / Next Button
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isConfirmStep ? (codesMatch ? 1 : 0.5) : 1,
                        child: ElevatedButton(
                          onPressed: isConfirmStep
                              ? (codesMatch ? _submitCode : null)
                              : _goToConfirm,
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
                                colors: [
                                  Color(0xFFBEBEBE),
                                  Color(0xFFA8A8A8),
                                ],
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
                              child: Text(
                                isConfirmStep ? "Confirm" : "Next",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (isConfirmStep &&
                          !_confirmControllers.any((c) => c.text.isEmpty) &&
                          !codesMatch)
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
                            "Codes do not match. Please retype.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}
