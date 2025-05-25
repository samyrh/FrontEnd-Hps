import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/reset_oassword/ResetPasswordService.dart'; // ✅ Check spelling!
import '../Toast.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;
  const ResetPasswordScreen({super.key, required this.username});

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
  bool isSubmitting = false;

  final ResetPasswordService _resetPasswordService = ResetPasswordService();

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

  bool _canSubmit() {
    return newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordsMatch &&
        _getStrength(newPasswordController.text) >= 0.75;
  }

  void _onSave() async {
    final username = widget.username;
    final newPassword = newPasswordController.text;

    setState(() => isSubmitting = true);

    final success = await _resetPasswordService.resetPassword(username, newPassword);

    setState(() => isSubmitting = false);

    if (success) {
      showCupertinoGlassToast(
        context,
        'Password changed successfully.',
        isSuccess: true,
        position: ToastPosition.top,
      );
      Future.delayed(const Duration(milliseconds: 1650), () {
        context.go('/sign_in');
      });
    } else {
      showCupertinoGlassToast(
        context,
        'Failed to reset password. Try again later.',
        isSuccess: false,
        position: ToastPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _canSubmit();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              focusNode: newFocus,
              obscureText: !showNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(showNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => showNewPassword = !showNewPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              focusNode: confirmFocus,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: passwordsMatch
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isEnabled && !isSubmitting ? _onSave : null,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }
}
