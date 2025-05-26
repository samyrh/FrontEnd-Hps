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

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
  }

  void _onNextPressed() async {
    final input = _usernameController.text.trim().toLowerCase();
    if (input.isEmpty) return;

    setState(() => _isLoading = true);
    final isValid = await _identifyUserService.verifyUsername(input);
    setState(() => _isLoading = false);

    if (isValid) {
      showDialog(
        context: context,
        builder: (_) => OtpVerificationDialog(
          username: input, // ✅ Fixes the error
          onConfirmed: (_) {
            Navigator.of(context).pop();

            showCupertinoGlassToast(
              context,
              'Verified. Proceed to reset your password.',
              position: ToastPosition.top,
              isSuccess: true,
            );

            Future.delayed(const Duration(milliseconds: 1650), () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 450),
                  pageBuilder: (_, animation, __) => ResetPasswordScreen(username: input),
                  transitionsBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(curved),
                      child: FadeTransition(opacity: curved, child: child),
                    );
                  },
                ),
              );

              Future.delayed(const Duration(milliseconds: 300), () {
                showCupertinoGlassToast(
                  context,
                  "You're now on the secure password reset page. Create a strong new password to continue.",
                  position: ToastPosition.top,
                  isSuccess: true,
                );
              });
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

      if (_remainingAttempts > 0) {
        showCupertinoGlassToast(
          context,
          "Invalid username. This account may not exist or was entered incorrectly.",
          position: ToastPosition.top,
          isSuccess: false,
        );
      } else {
        showCupertinoGlassToast(
          context,
          "Too many failed attempts. For your security, you’ll be redirected to try again later.",
          position: ToastPosition.top,
          isSuccess: false,
        );
        Future.delayed(const Duration(milliseconds: 1800), () {
          context.go('/sign_in');
        });
      }
    }
  }

  // 🧠 The rest of your UI code remains untouched below...

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isInputEmpty = _usernameController.text.trim().isEmpty;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD6F2F0), Color(0xFFE3E4F7), Color(0xFFF5F6FA)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/sign_in'),
          ),
          title: const Text(
            'Reset Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1E1E2D), fontFamily: 'Inter'),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenWidth, screenHeight),
                const SizedBox(height: 28),
                _buildTextField(),
                if (_remainingAttempts < 3) ...[const SizedBox(height: 10), _buildAttemptsSpan()],
                const SizedBox(height: 32),
                _buildNextButton(isInputEmpty),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/lock.png',
            width: screenWidth,
            height: screenHeight * 0.25,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 26),
        Text('Identify yourself', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Enter your username to receive a verification code.',
          style: GoogleFonts.inter(fontSize: 14.5, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Username', style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.65))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.12), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: TextField(
            controller: _usernameController,
            focusNode: _focusNode,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1E1E2D)),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'e.g. sami',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFFA2A2A7)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptsSpan() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white.withOpacity(0.75)),
            const SizedBox(width: 8),
            Text(
              '$_remainingAttempts attempt${_remainingAttempts == 1 ? '' : 's'} left',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isInputEmpty) {
    return Center(
      child: GestureDetector(
        onTap: isInputEmpty || _isLoading ? null : _onNextPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: 260,
          height: 56,
          decoration: BoxDecoration(
            gradient: isInputEmpty
                ? null
                : const LinearGradient(colors: [Color(0xFF111111), Color(0xFF1E1E1E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            color: isInputEmpty ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isInputEmpty ? [] : [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Next',
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: isInputEmpty ? Colors.grey[600] : Colors.white,
                  letterSpacing: 0.3,
                )),
          ),
        ),
      ),
    );
  }
}
