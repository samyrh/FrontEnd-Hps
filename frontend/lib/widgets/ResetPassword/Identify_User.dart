import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/reset_oassword/IdentifyUserService.dart';
import '../OtpVerificationDialog.dart';
import '../Toast.dart';

import 'Reset_PasswordScreen.dart';

class IdentifyUserScreen extends StatefulWidget {
  const IdentifyUserScreen({super.key});

  @override
  State<IdentifyUserScreen> createState() => _IdentifyUserScreenState();
}

class _IdentifyUserScreenState extends State<IdentifyUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final IdentifyUserService _identifyUserService = IdentifyUserService();

  int _remainingAttempts = 3;
  bool _isLoading = false;

  void _onNextPressed() async {
    final input = _usernameController.text.trim();

    if (input.isEmpty) return;

    setState(() => _isLoading = true);
    final isValid = await _identifyUserService.verifyUsername(input);
    setState(() => _isLoading = false);

    if (isValid) {
      showDialog(
        context: context,
        builder: (_) => OtpVerificationDialog(
          onConfirmed: (_) {
            Navigator.of(context).pop();

            showCupertinoGlassToast(
              context,
              'Verified. Proceed to reset your password.',
              isSuccess: true,
              position: ToastPosition.top,
            );

            Future.delayed(const Duration(milliseconds: 1650), () {
              context.push('/reset_password', extra: {'username': input});
            });
          },
        ),
      );
    } else {
      setState(() {
        _remainingAttempts--;
        _usernameController.clear();
        _focusNode.requestFocus();
      });

      if (_remainingAttempts <= 0) {
        showCupertinoGlassToast(
          context,
          'Too many failed attempts. Redirecting...',
          isSuccess: false,
          position: ToastPosition.top,
        );
        Future.delayed(const Duration(milliseconds: 1600), () {
          context.go('/sign_in');
        });
      } else {
        showCupertinoGlassToast(
          context,
          'Invalid username. Please try again.',
          isSuccess: false,
          position: ToastPosition.top,
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInputEmpty = _usernameController.text.trim().isEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // UI content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reset Password", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(),
                  const SizedBox(height: 16),
                  if (_remainingAttempts < 3) _buildAttemptsSpan(),
                  const SizedBox(height: 20),
                  _buildNextButton(isInputEmpty),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _usernameController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildNextButton(bool isInputEmpty) {
    return ElevatedButton(
      onPressed: isInputEmpty ? null : _onNextPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text('Next'),
    );
  }

  Widget _buildAttemptsSpan() {
    return Text(
      '$_remainingAttempts attempt${_remainingAttempts == 1 ? '' : 's'} left',
      style: GoogleFonts.inter(fontSize: 14, color: Colors.redAccent),
    );
  }
}
