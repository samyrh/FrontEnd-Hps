import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({Key? key}) : super(key: key);

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final currentFocus = FocusNode();
  final newFocus = FocusNode();
  final confirmFocus = FocusNode();

  bool showPassword = false;
  bool showNewPassword = false;
  bool passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    currentPasswordController.addListener(_checkPasswordsMatch);
    newPasswordController.addListener(_checkPasswordsMatch);
    confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  void _checkPasswordsMatch() {
    setState(() {
      final currentEmpty = currentPasswordController.text.isEmpty;

      if (currentEmpty) {
        newPasswordController.clear();
        confirmPasswordController.clear();
      }

      passwordsMatch = newPasswordController.text == confirmPasswordController.text;
    });
  }


  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentFocus.dispose();
    newFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~_]').hasMatch(password)) strength += 0.25;
    return strength;
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

  String _getStrengthIcon(double strength) {
    if (strength <= 0.25) return '❌';
    if (strength <= 0.5) return '⚠️';
    if (strength <= 0.75) return '🔵';
    return '✅';
  }

  List<String> _getUnmetPasswordHints(String password) {
    List<String> hints = [];
    if (password.length < 6) hints.add('Min 6 characters');
    if (!RegExp(r'[A-Z]').hasMatch(password)) hints.add('Add uppercase letter');
    if (!RegExp(r'[0-9]').hasMatch(password)) hints.add('Add a number');
    if (!RegExp(r'[!@#\$&*~_]').hasMatch(password)) hints.add('Add a symbol');
    return hints;
  }

  bool _isFormValid() {
    return currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordsMatch &&
        _getPasswordStrength(newPasswordController.text) >= 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final passwordStrength = _getPasswordStrength(newPasswordController.text);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Card Details',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLockImage(screenWidth, context),
              _buildTitle(),
              const SizedBox(height: 20),
              _customTextField(
                label: 'Current Password',
                controller: currentPasswordController,
                focusNode: currentFocus,
                isPassword: true,
                isPasswordVisible: showPassword,
                onSuffixTap: () => setState(() => showPassword = !showPassword),
              ),
              _customTextField(
                label: 'New Password',
                controller: newPasswordController,
                focusNode: newFocus,
                isPassword: true,
                isPasswordVisible: showNewPassword,
                onSuffixTap: () => setState(() => showNewPassword = !showNewPassword),
                enabled: currentPasswordController.text.isNotEmpty,
              ),
              if (newPasswordController.text.isNotEmpty)
                _buildPasswordStrengthBar(newPasswordController.text, screenWidth),
              _customTextField(
                label: 'Confirm Password',
                controller: confirmPasswordController,
                focusNode: confirmFocus,
                isPassword: true,
                isPasswordVisible: false,
                showSuffixIcon: false,
                enabled: currentPasswordController.text.isNotEmpty &&
                    passwordStrength >= 0.75,
                borderColor: confirmPasswordController.text.isEmpty
                    ? Colors.black.withOpacity(0.2)
                    : (passwordsMatch ? Colors.green : Colors.red),
              ),
              if (confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 18,
                        color: passwordsMatch ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        passwordsMatch ? 'Passwords match' : 'Passwords do not match',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: passwordsMatch ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildLockImage(double screenWidth, BuildContext context) {
    return ClipRRect(
      child: Image.asset(
        'assets/lock.png',
        width: screenWidth,
        height: MediaQuery.of(context).size.height * 0.28,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set a new password',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
          SizedBox(height: 6),
          Text('Make sure it’s different from your old password.',
              style: TextStyle(fontSize: 13.5, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool isEnabled = _isFormValid();

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 260,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.black : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.white24,
            onTap: isEnabled ? () {
              // TODO: Save action
            } : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isEnabled ? 1.0 : 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
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
    required FocusNode focusNode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onSuffixTap,
    bool showSuffixIcon = true,
    Color? borderColor,
    bool enabled = true,
  }) {
    final bool hasInput = controller.text.isNotEmpty;
    final bool isFocused = focusNode.hasFocus;
    final Color finalBorderColor = borderColor ??
        (isFocused ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.15));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.65),
              )),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: finalBorderColor, width: 1.2),
            ),
            child: TextField(
              enabled: enabled,
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword && !isPasswordVisible,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1E2D),
              ),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  child: Icon(Icons.lock_outline_rounded, size: 20, color: const Color(0xFFA2A2A7)),
                ),
                suffixIcon: (showSuffixIcon && hasInput && onSuffixTap != null)
                    ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: const Color(0xFFA2A2A7),
                    ),
                  ),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthBar(String password, double screenWidth) {
    final strength = _getPasswordStrength(password);
    final label = _getStrengthLabel(strength);
    final color = _getStrengthColor(strength);
    final icon = _getStrengthIcon(strength);
    final hints = _getUnmetPasswordHints(password);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F8FA), Color(0xFFEDEEF1)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fluid strength bar
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 10,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth * strength;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      width: barWidth,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              color.withOpacity(0.2),
                              color,
                              color.withOpacity(0.6),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          color: color,
                          width: barWidth,
                          height: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
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
            const SizedBox(height: 10),
            if (hints.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hints.map((hint) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withOpacity(0.2), width: 1.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          hint,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
