import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color background = Colors.white;
  static const Color text = Color(0xFF1E1E2D);
  static const Color secondaryText = Color(0xFFA2A2A7);
  static const Color inputBorder = Color(0xFFE5E5EA);
  static const Color blurContainer = Color(0xFFF1F3F6);
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController(text: "saminada");
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;

  String selectedLanguage = 'English';
  final List<String> languages = ['English(Eng)', 'Français(Fr)', '(Ar)العربية'];

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
            Color(0xFFF2F2F7), // light iOS grey
            Color(0xFFE5E5EA), // middle grey
            Color(0xFFD1D1D6), // darker grey
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // important to let gradient show
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerRow(),
                const SizedBox(height: 50),
                Text(
                  'Secure Sign In ',
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
                const SizedBox(height: 40),
                _customTextField(
                  label: 'Username',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
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
                ),
                const SizedBox(height: 30),
                _hoverableButton(),
                const SizedBox(height: 20),
                _buildForgotPasswordText(),
                const SizedBox(height: 30),
                _buildFaceIDOption(),
                const SizedBox(height: 20),
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
        _backButton(),
        _languageSelector(),
      ],
    );
  }

  Widget _backButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.text),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  Widget _languageSelector() {
    return GestureDetector(
      onTap: _showLanguageDialog,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
    );
  }

  Widget _customTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
  }) {
    final focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        focusNode.addListener(() => setState(() {}));

        final bool isFocused = focusNode.hasFocus;
        final bool hasInput = controller.text.isNotEmpty;

        final Color borderColor = isFocused
            ? Colors.black.withOpacity(0.35)
            : AppColors.inputBorder.withOpacity(0.3);
        final double borderWidth = 1.1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isFocused
                    ? Colors.black.withOpacity(0.85)
                    : Colors.black.withOpacity(0.65),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: borderWidth),
                color: Colors.white.withOpacity(0.12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: isPassword && !_isPasswordVisible,
                onChanged: (_) => setState(() {}), // re-render to check input
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  filled: false,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: InputBorder.none,
                  prefixIcon: prefixIcon != null
                      ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      prefixIcon,
                      size: 20,
                      color: isFocused
                          ? Colors.black.withOpacity(0.75)
                          : AppColors.secondaryText,
                    ),
                  )
                      : null,
                  suffixIcon: (suffixIcon != null && hasInput)
                      ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        suffixIcon,
                        size: 20,
                        color: isFocused
                            ? Colors.black.withOpacity(0.75)
                            : AppColors.secondaryText,
                      ),
                    ),
                  )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _hoverableButton() {
    return Center(
      child: AnimatedOpacity(
        opacity: _isButtonEnabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: StatefulBuilder(
          builder: (context, setState) {
            double _scale = 1.0;

            return Listener(
              onPointerDown: (_) {
                if (_isButtonEnabled) setState(() => _scale = 0.96);
              },
              onPointerUp: (_) {
                if (_isButtonEnabled) setState(() => _scale = 1.0);
              },
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 130),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: _isButtonEnabled
                      ? () {
                    // TODO: Add sign in logic
                  }
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
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
                          color: Colors.white,
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
        onTap: () {
          // TODO: Add Face ID logic
        },
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFCFCFCF), // flat grey
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(0.1), // subtle black border
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
    );
  }

  Widget _buildOfflineText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to offline simulator screen or load static demo
        },
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
    );
  }

  Widget _buildForgotPasswordText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to forgot password screen
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
                  color: Colors.black,
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