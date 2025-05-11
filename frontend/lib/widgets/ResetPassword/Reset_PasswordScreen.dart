import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../Toast.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final newFocus = FocusNode();
  final confirmFocus = FocusNode();
  bool showNewPassword = false;
  bool passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_validate);
    confirmPasswordController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      passwordsMatch = newPasswordController.text == confirmPasswordController.text;
    });
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
    return newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordsMatch &&
        _getStrength(newPasswordController.text) >= 0.75;
  }

  void _onSave() {
    // Step 1: First toast
    showCupertinoGlassToast(
      context,
      'Password changed successfully.',
      isSuccess: true,
      position: ToastPosition.top,
    );

    // Step 2: Delay for toast visibility, then transition
    Future.delayed(const Duration(milliseconds: 1650), () {
      context.go('/sign_in_with_toast');
    });

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
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Reset Password',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Create Your New Password',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your new password must be strong and secure. Avoid using weak or reused credentials.',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
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
                const SizedBox(height: 28),
                _buildInputField(
                  label: 'New Password',
                  controller: newPasswordController,
                  focusNode: newFocus,
                  isPassword: true,
                  isPasswordVisible: showNewPassword,
                  onToggleVisibility: () => setState(() => showNewPassword = !showNewPassword),
                ),
                if (password.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildStrengthSpan(strength, hints),
                ],
                const SizedBox(height: 28),
                _buildConfirmPasswordField(),
                const SizedBox(height: 40),
                _buildSaveButton(isEnabled),
                const SizedBox(height: 16),
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
    Color? borderColor,
  }) {
    final isFocused = focusNode.hasFocus;
    final hasText = controller.text.isNotEmpty;
    final Color effectiveBorderColor = borderColor ??
        (isFocused ? const Color(0xFF007AFF).withOpacity(0.6) : Colors.black.withOpacity(0.1));

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: effectiveBorderColor, width: 1),
              boxShadow: [
                if (isFocused)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword && !isPasswordVisible,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: isPassword ? '••••••••' : 'Enter password',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Colors.black45),
                suffixIcon: (isPassword && hasText && onToggleVisibility != null)
                    ? GestureDetector(
                  onTap: onToggleVisibility,
                  child: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.grey,
                  ),
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderColor: confirmPasswordController.text.isEmpty
              ? Colors.black.withOpacity(0.15)
              : passwordsMatch
              ? Colors.green
              : Colors.red,
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
