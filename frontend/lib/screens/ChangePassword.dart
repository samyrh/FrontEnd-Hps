import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/sign_in.dart';
import '../services/change_password/ChangePasswordService.dart';
import '../services/change_password/VerifyPasswordService.dart';
import '../widgets/Toast.dart';
import 'dart:async';

import 'Home.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  Timer? _debounceTimer;
  bool hasShownIncorrectToast = false;
  final currentFocus = FocusNode();
  final newFocus = FocusNode();
  final confirmFocus = FocusNode();
  int remainingTries = 3;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool passwordsMatch = true;
  bool isCurrentPasswordValid = false;
  bool showNewPasswordForm = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    currentPasswordController.addListener(() {
      if (mounted) setState(() {}); // only update if widget is still in tree
    });

    newPasswordController.addListener(_validate);
    confirmPasswordController.addListener(_validate);
  }


  @override
  void dispose() {
    _debounceTimer?.cancel();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      passwordsMatch = newPasswordController.text == confirmPasswordController.text;
    });

    if (newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
      // Wait for the current frame to finish before scrolling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  double _getStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~_]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  List<String> _getHints(String password) {
    final List<String> hints = [];
    if (password.length < 6) hints.add("Min 6 characters");
    if (!RegExp(r'[A-Z]').hasMatch(password)) hints.add("Add uppercase letter");
    if (!RegExp(r'[0-9]').hasMatch(password)) hints.add("Add a number");
    if (!RegExp(r'[!@#\$&*~_]').hasMatch(password)) hints.add("Add a symbol");
    return hints;
  }

  String _getStrengthLabel(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.blue;
    return Colors.green;
  }

  bool _canSubmit() {
    return currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordsMatch &&
        _getStrength(newPasswordController.text) >= 0.75;
  }

  void _onSave() async {
    final oldPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;

    final success = await ChangePasswordService().changePassword(oldPassword, newPassword);

    if (success) {
      showCupertinoGlassToast(
        context,
        'Password changed successfully. Redirecting to home...',
        isSuccess: true,
        position: ToastPosition.top,
      );

      Future.delayed(const Duration(milliseconds: 2200), () {
        context.go('/home', extra: {
          'showToast': true,
          'toastMessage': "You're now signed in with your new password!"
        });
      });
    } else {
      showCupertinoGlassToast(
        context,
        'Current password is incorrect.',
        isSuccess: false,
        position: ToastPosition.top,
      );
    }
  }


  Widget _buildNextButton() {
    final isButtonEnabled = currentPasswordController.text.isNotEmpty && remainingTries > 0;

    return Center(
      child: GestureDetector(
        onTap: isButtonEnabled
            ? () async {
          final input = currentPasswordController.text;
          final isValid = await VerifyPasswordService().verifyCurrentPassword(input);

          if (isValid) {
            showCupertinoGlassToast(
              context,
              'Password verified. Now choose a strong new password.',
              isSuccess: true,
              position: ToastPosition.top,
            );
            setState(() {
              isCurrentPasswordValid = true;
              showNewPasswordForm = true;
            });
          } else {
            setState(() {
              currentPasswordController.clear();
              remainingTries -= 1;
            });

            if (remainingTries <= 0) {
              showCupertinoGlassToast(
                context,
                'Too many incorrect attempts. Redirecting...',
                isSuccess: false,
                position: ToastPosition.top,
              );

              Future.delayed(const Duration(milliseconds: 1800), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                      (route) => false,
                );

              });
            } else {
              showCupertinoGlassToast(
                context,
                'Incorrect password. $remainingTries attempt${remainingTries > 1 ? 's' : ''} left.',
                isSuccess: false,
                position: ToastPosition.top,
              );
            }
          }
        }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: 260,
          height: 56,
          decoration: BoxDecoration(
            gradient: isButtonEnabled
                ? const LinearGradient(colors: [Color(0xFF111111), Color(0xFF1E1E1E)])
                : null,
            color: isButtonEnabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isButtonEnabled
                ? [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Center(
            child: Text(
              'Next',
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: isButtonEnabled ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = newPasswordController.text;
    final strength = _getStrength(password);
    final hints = _getHints(password);
    final isEnabled = _canSubmit();

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // ✅ Hides back arrow
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E2D),
              fontFamily: 'Inter',
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔒 Top image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/lock.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                // ℹ️ Info span
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_person_rounded,
                          size: 28,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Use a strong, unique password you haven’t used before to protect your account.',
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600, // semi-bold iOS feel
                            height: 1.5,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: !showNewPasswordForm
                      ? Column(
                    key: const ValueKey("step1"),
                    children: [
                      _buildInputField(
                        label: 'Current Password',
                        controller: currentPasswordController,
                        focusNode: currentFocus,
                        isPassword: true,
                        isPasswordVisible: showCurrentPassword,
                        onToggleVisibility: () =>
                            setState(() => showCurrentPassword = !showCurrentPassword),
                        enabled: true,
                      ),
                      const SizedBox(height: 10),
                      _buildNextButton(),
                      const SizedBox(height: 12),
                      if (remainingTries <= 3)
                        Center(
                          child: AnimatedOpacity(
                            opacity: 1,
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: remainingTries == 0
                                    ? const LinearGradient(
                                  colors: [Color(0xFFFFE9E9), Color(0xFFFFF5F5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                    : const LinearGradient(
                                  colors: [Color(0xFFF7F7F7), Color(0xFFF2F2F2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: remainingTries == 0 ? Colors.red.withOpacity(0.35) : Colors.black12,
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      remainingTries == 0 ? Icons.warning_amber_rounded : Icons.lock_clock,
                                      key: ValueKey(remainingTries),
                                      size: 20,
                                      color: remainingTries == 0 ? Colors.redAccent : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      remainingTries == 0
                                          ? 'You’ve reached the limit.\nRedirecting securely...'
                                          : 'Remaining attempts: $remainingTries',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: remainingTries == 0 ? Colors.redAccent : Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),

                // Step 2: New password form (with fade-in animation)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: showNewPasswordForm
                      ? Column(
                    key: const ValueKey("form"),
                    children: [
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'New Password',
                        controller: newPasswordController,
                        focusNode: newFocus,
                        isPassword: true,
                        isPasswordVisible: showNewPassword,
                        onToggleVisibility: () => setState(() => showNewPassword = !showNewPassword),
                        enabled: true,
                      ),
                      if (newPasswordController.text.isNotEmpty)
                        _buildStrengthSpan(strength, hints),

                      const SizedBox(height: 28),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 40),
                      _buildSaveButton(isEnabled),
                      const SizedBox(height: 16),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    required bool enabled,
  }) {
    final hasText = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.6), // Increased from 0.28 to 0.6
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: TextField(
                  enabled: enabled,
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && !isPasswordVisible,
                  style: GoogleFonts.inter(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: isPassword ? '••••••••' : 'Enter value',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.35),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.black.withOpacity(0.35),
                      size: 20,
                    ),
                    suffixIcon: (isPassword && hasText && onToggleVisibility != null)
                        ? GestureDetector(
                      onTap: onToggleVisibility,
                      child: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    )
                        : null,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildConfirmPasswordField() {
    return Column(
      children: [
        _buildInputField(
          label: 'Confirm Password',
          controller: confirmPasswordController,
          focusNode: confirmFocus,
          isPassword: true,
          isPasswordVisible: false,
          enabled: isCurrentPasswordValid,
        ),

        if (confirmPasswordController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: passwordsMatch ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: passwordsMatch ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                  color: passwordsMatch ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  passwordsMatch ? 'Passwords match' : 'Passwords do not match',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: passwordsMatch ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStrengthSpan(double strength, List<String> hints) {
    final color = _getStrengthColor(strength);
    final label = _getStrengthLabel(strength);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: strength),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: value,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  'Password strength: $label',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (hints.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hints.map((hint) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.12), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(hint, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool enabled) {
    return Center(
      child: GestureDetector(
        onTap: enabled ? _onSave : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: 260,
          height: 56,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(colors: [Color(0xFF111111), Color(0xFF1E1E1E)])
                : null,
            color: enabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(26),
            boxShadow: enabled
                ? [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Center(
            child: Text(
              'Save Password',
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
