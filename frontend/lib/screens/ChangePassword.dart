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
  bool showConfirmPassword = false;
  bool passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_checkPasswordsMatch);
    confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  void _checkPasswordsMatch() {
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildHeader(),
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
            ),
            _customTextField(
              label: 'Confirm Password',
              controller: confirmPasswordController,
              focusNode: confirmFocus,
              isPassword: true,
              isPasswordVisible: false, // No toggle
              showSuffixIcon: false,
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
                      passwordsMatch
                          ? 'Passwords match'
                          : 'Passwords do not match',
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, size: 24),
        ),
        const Spacer(),
        const Text(
          'Change Password',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        const SizedBox(width: 36),
      ],
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
          Text(
            'Set a new password',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Make sure it’s different from your old password.',
            style: TextStyle(fontSize: 13.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Save logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Save'),
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
  }) {
    final bool hasInput = controller.text.isNotEmpty;
    final bool isFocused = focusNode.hasFocus;

    final Color finalBorderColor = borderColor ??
        (isFocused
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.15));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: finalBorderColor,
                width: 1.2,
              ),
            ),
            child: TextField(
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: const Color(0xFFA2A2A7),
                  ),
                ),
                suffixIcon: (showSuffixIcon && hasInput && onSuffixTap != null)
                    ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
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
}
