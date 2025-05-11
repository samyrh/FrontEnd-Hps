import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Toast.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color background = Colors.white;
  static const Color text = Color(0xFF1E1E2D);
  static const Color secondaryText = Color(0xFFA2A2A7);
  static const Color inputBorder = Color(0xFFE5E5EA);
  static const Color blurContainer = Color(0xFFF1F3F6);
}

class SignInScreen extends StatefulWidget {
  final bool showRedirectToast;

  const SignInScreen({super.key, this.showRedirectToast = false});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}


class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController(text: "sami");
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;
  String selectedLanguage = 'English';
  final List<String> languages = ['English(Eng)', 'Français(Fr)', '(Ar)العربية'];
  int _remainingAttempts = 3;
  bool _isLocked = false;
  DateTime? _unlockTime;
  Duration _lockDuration = const Duration(minutes: 1);
  Duration _remainingTime = Duration.zero;
  late final Ticker _ticker;
  int _lockAttemptLevel = 0;

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.only(top: 24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Center(
            child: Text(
              "Select Language",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF1E1E2D),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = language;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedLanguage == language
                            ? const Color(0xFFC6C6C6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          language,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF1E1E2D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6F2F0),
            Color(0xFFE3E4F7),
            Color(0xFFF5F6FA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerRow(),
                const SizedBox(height: 40),

                // ⬆️ Headings
                Text(
                  'Secure Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Access your SmartBank account safely.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 36),

                // 🔐 Username Field
                _customTextField(
                  label: 'Username',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline,
                  isEnabled: !_isLocked,
                ),
                const SizedBox(height: 16),

                // 🔒 Password Field
                _customTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                  isEnabled: !_isLocked,
                ),

                const SizedBox(height: 10),

                // 🧠 Remaining Attempts
                if (!_isLocked && _remainingAttempts < 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '$_remainingAttempts attempt${_remainingAttempts == 1 ? '' : 's'} remaining',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ),

                // ⏱️ Countdown when locked
                if (_isLocked)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.lock_fill,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _remainingTime.inMinutes >= 1
                                  ? 'Try again in ${_remainingTime.inMinutes}m ${_remainingTime.inSeconds % 60}s'
                                  : 'Try again in ${_remainingTime.inSeconds}s',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // 🔘 Sign In Button
                _hoverableButton(),

                const SizedBox(height: 24),

                // 🔁 Forgot Password
                _buildForgotPasswordText(),

                const SizedBox(height: 36),

                // 🧠 Face ID
                _buildFaceIDOption(),

                const SizedBox(height: 36),

                // 📴 Offline
                _buildOfflineText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _languageSelector(),
      ],
    );
  }


  Widget _languageSelector() {
    final bool isEnabled = !_isLocked;

    return GestureDetector(
      onTap: isEnabled ? _showLanguageDialog : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 20, color: Color(0xFF0F172A)),
                  const SizedBox(width: 6),
                  Text(
                    selectedLanguage,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0F172A)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
    bool isEnabled = true, // ✅ allows disabling the field
  }) {
    final focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        focusNode.addListener(() => setState(() {}));

        final bool isFocused = focusNode.hasFocus;
        final bool hasInput = controller.text.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? (isFocused ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.65))
                    : Colors.grey.shade400,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isEnabled ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: !isEnabled
                          ? Colors.grey.withOpacity(0.3)
                          : (isFocused
                          ? Colors.black.withOpacity(0.25)
                          : AppColors.inputBorder.withOpacity(0.3)),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    enabled: isEnabled,
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: isPassword && !_isPasswordVisible,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isEnabled ? AppColors.text : Colors.grey.shade500,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: InputBorder.none,
                      prefixIcon: prefixIcon != null
                          ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          prefixIcon,
                          size: 20,
                          color: isEnabled
                              ? (isFocused
                              ? Colors.black.withOpacity(0.75)
                              : AppColors.secondaryText)
                              : Colors.grey.shade400,
                        ),
                      )
                          : null,
                      suffixIcon: (suffixIcon != null && hasInput)
                          ? GestureDetector(
                        onTap: isEnabled ? onSuffixTap : null,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            suffixIcon,
                            size: 20,
                            color: isEnabled
                                ? (isFocused
                                ? Colors.black.withOpacity(0.75)
                                : AppColors.secondaryText)
                                : Colors.grey.shade400,
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _hoverableButton() {
    final bool isEnabled = _isButtonEnabled && !_isLocked;

    return Center(
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: StatefulBuilder(
          builder: (context, setState) {
            double _scale = 1.0;

            return Listener(
              onPointerDown: (_) {
                if (isEnabled) setState(() => _scale = 0.96);
              },
              onPointerUp: (_) {
                if (isEnabled) setState(() => _scale = 1.0);
              },
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 130),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: isEnabled
                      ? () {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text;

                    if (username == 'sami' && password == '123') {
                      setState(() {
                        _remainingAttempts = 3;
                        _isLocked = false;
                        _remainingTime = Duration.zero;
                        _unlockTime = null;
                      });
                      context.go('/security_code_setup');
                    } else {
                      setState(() {
                        _remainingAttempts--;
                      });

                      showCupertinoGlassToast(
                        context,
                        _remainingAttempts > 0
                            ? 'Invalid credentials. $_remainingAttempts attempt${_remainingAttempts == 1 ? '' : 's'} left.'
                            : 'Too many attempts. Locked for 1 minute.',
                        isSuccess: false,
                        position: ToastPosition.top,
                      );

                      if (_remainingAttempts == 0) {
                        setState(() {
                          _isLocked = true;
                          final nextLockDuration = Duration(minutes: 1 + 4 * _lockAttemptLevel); // e.g., 1, 5, 9...
                          _unlockTime = DateTime.now().add(nextLockDuration);
                          _lockDuration = nextLockDuration;
                          _remainingTime = _lockDuration;
                        });
                        _ticker.start();
                      }
                    }
                  }
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isEnabled ? Colors.black : Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (isEnabled)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(isEnabled ? 1 : 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFaceIDOption() {
    return Center(
      child: GestureDetector(
        onTap: _isLocked ? null : () {
          // TODO: Add Face ID logic
        },
        child: AnimatedOpacity(
          opacity: _isLocked ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFCFCF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/FaceID.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in with Face ID',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineText() {
    return Center(
      child: GestureDetector(
        onTap: _isLocked
            ? null
            : () {
          // TODO: Navigate to offline simulator screen or load static demo
        },
        child: AnimatedOpacity(
          opacity: _isLocked ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
              children: [
                const TextSpan(text: "Try our app in "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextSpan(
                  text: 'Offline Simulator',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordText() {
    return Center(
      child: GestureDetector(
        onTap: _isLocked
            ? null
            : () {
          context.go('/verify_code');
        },
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
            children: [
              const TextSpan(text: "Forgot your password? "),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.lock_reset, size: 18, color: Colors.black),
                ),
              ),
              TextSpan(
                text: 'Reset here',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isLocked ? Colors.grey.shade400 : Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);

    if (widget.showRedirectToast) {
      Future.delayed(const Duration(milliseconds: 700), () {
        showCupertinoGlassToast(
          context,
          'Password updated. You can now sign in with your new credentials.',
          isSuccess: true,
          position: ToastPosition.top,
        );
      });
    }

    _remainingTime = Duration.zero;
    _ticker = Ticker((elapsed) {
      final now = DateTime.now();
      if (_unlockTime != null && now.isBefore(_unlockTime!)) {
        setState(() {
          _remainingTime = _unlockTime!.difference(now);
        });
      } else {
        _ticker.stop();
        setState(() {
          _isLocked = false;
          _remainingAttempts = 3;
          _remainingTime = Duration.zero;
          _lockAttemptLevel++; // ⬆️ Increase lock level
        });

        // ✅ Show modal when unlocked
        Future.delayed(const Duration(milliseconds: 400), () {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              insetAnimationDuration: const Duration(milliseconds: 300),
              insetAnimationCurve: Curves.easeInOut,
              title: Column(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    size: 44,
                    color: CupertinoColors.activeGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You're Unblocked",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "You can try signing in again.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.darkBackgroundGray.withOpacity(0.8),
                  ),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  isDefaultAction: true,
                  child: Text(
                    "Got it",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                )
              ],
            )
          );
        });
      }
    });

  }


  void _validateInputs() {
    final isEnabled = _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }


}