import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color background = Colors.white;
  static const Color text = Color(0xFF1E1E2D);
  static const Color secondaryText = Color(0xFFA2A2A7);
  static const Color inputBorder = Color(0xFFE5E5EA);
  static const Color errorBorder = Color(0xFFFF4D4F);
  static const Color focusBorder = Colors.black;
  static const Color matchBorder = Color(0xFF4CAF50);
  static const Color strengthWeak = Color(0xFFFF6B6B);
  static const Color strengthMedium = Color(0xFFFFC107);
  static const Color strengthStrong = Color(0xFF4CAF50);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _emailValid = true;
  bool _strongPassword = false;
  bool _passwordsMatch = true;

  int _passwordStrength = 0;
  Color _passwordStrengthColor = Colors.transparent;
  List<String> _passwordTips = [];

  final Map<String, FocusNode> _focusNodes = {
    'email': FocusNode(),
    'username': FocusNode(),
    'phone': FocusNode(),
    'password': FocusNode(),
    'confirmPassword': FocusNode(),
  };

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _emailValid = true); // Neutral state when empty
      return;
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    setState(() => _emailValid = regex.hasMatch(value));
  }

  bool _isFormValid() {
    return _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _emailValid &&
        _strongPassword &&
        _passwordsMatch;
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    int score = 0;
    final tips = <String>[];

    if (password.length >= 8) score++; else tips.add("Use at least 8 characters");
    if (RegExp(r'[A-Z]').hasMatch(password)) score++; else tips.add("Add uppercase letter");
    if (RegExp(r'[0-9]').hasMatch(password)) score++; else tips.add("Add a number");
    if (RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(password)) score++; else tips.add("Add a symbol");

    Color color = Colors.transparent;
    if (score <= 1) color = AppColors.strengthWeak;
    else if (score == 2 || score == 3) color = AppColors.strengthMedium;
    else color = AppColors.strengthStrong;

    setState(() {
      _strongPassword = score >= 3 || password.isEmpty;
      _passwordsMatch = password == confirm || confirm.isEmpty;
      _passwordStrength = score;
      _passwordStrengthColor = color;
      _passwordTips = tips;
    });
  }

  OutlineInputBorder _getBorder(String field,
      {bool isError = false, bool isMatch = false}) {
    final focus = _focusNodes[field]?.hasFocus ?? false;
    final color = isError
        ? AppColors.errorBorder
        : isMatch
        ? AppColors.matchBorder
        : focus
        ? AppColors.focusBorder
        : AppColors.inputBorder;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildTextField({
    required String label,
    required String fieldKey,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    bool isError = false,
    bool isMatch = false,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return FocusScope(
      child: Focus(
        onFocusChange: (_) => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              focusNode: _focusNodes[fieldKey],
              keyboardType: keyboard,
              obscureText: obscure,
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.text),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: Icon(icon, color: AppColors.secondaryText),
                suffixIcon: suffixIcon,
                border: _getBorder(fieldKey),
                enabledBorder: _getBorder(fieldKey, isError: isError, isMatch: isMatch),
                focusedBorder: _getBorder(fieldKey, isError: isError, isMatch: isMatch),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: _phoneController,
          focusNode: _focusNodes['phone'],
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: _getBorder('phone'),
            enabledBorder: _getBorder('phone'),
            focusedBorder: _getBorder('phone'),
          ),
          initialCountryCode: 'US',
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.text),
          onChanged: (phone) {
            final cleaned = phone.number.replaceAll(RegExp(r'[^0-9]'), '');
            _phoneController.text = cleaned;
            _phoneController.selection = TextSelection.fromPosition(
              TextPosition(offset: _phoneController.text.length),
            );
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text("Create Account", style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Register to SmartBank", style: GoogleFonts.inter(fontSize: 15, color: AppColors.secondaryText)),
              const SizedBox(height: 30),

              _buildTextField(
                label: 'Username',
                fieldKey: 'username',
                controller: _usernameController,
                icon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Email Address',
                fieldKey: 'email',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                isError: !_emailValid,
                onChanged: (value) => _validateEmail(value),
              ),
              const SizedBox(height: 20),

              _buildPhoneField(),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Password',
                fieldKey: 'password',
                controller: _passwordController,
                icon: Icons.lock_outline,
                obscure: !_isPasswordVisible,
                isError: !_strongPassword && _passwordController.text.isNotEmpty,
                onChanged: (_) => _validatePasswords(),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Password strength bar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        width: MediaQuery.of(context).size.width * (_passwordStrength / 4.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _passwordStrengthColor == AppColors.strengthWeak
                                ? [AppColors.strengthWeak, AppColors.strengthWeak.withOpacity(0.7)]
                                : _passwordStrengthColor == AppColors.strengthMedium
                                ? [AppColors.strengthMedium, AppColors.strengthMedium.withOpacity(0.7)]
                                : [AppColors.strengthStrong, AppColors.strengthStrong.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              if (_passwordTips.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _passwordTips.asMap().entries.where((e) => e.key.isEven).map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text("• ${entry.value}", style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _passwordTips.asMap().entries.where((e) => e.key.isOdd).map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text("• ${entry.value}", style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Confirm Password',
                fieldKey: 'confirmPassword',
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                obscure: true,
                isError: !_passwordsMatch && _confirmPasswordController.text.isNotEmpty,
                isMatch: _passwordsMatch && _confirmPasswordController.text.isNotEmpty,
                onChanged: (_) => _validatePasswords(),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? () {
                    // Submit logic here
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Create Account',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
