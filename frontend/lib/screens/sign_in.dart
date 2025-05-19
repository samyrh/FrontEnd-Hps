import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dto/LoginUserDto.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/biometric_service.dart';
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


class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
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
  final AuthService _authService = AuthService();
  List<String> _pastUsernames = [];
  bool _isFirstLogin = true;
  Timer? _loginCheckTimer;
  final TextEditingController _newUsernameController = TextEditingController();
  bool _showNewUsernameInput = false;


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
    _loginCheckTimer?.cancel();
    _newUsernameController.dispose();

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

                // ⬆ Headings
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

                _pastUsernames.length <= 1
                    ? _customTextField(
                  label: 'Username',
                  controller: _usernameController,
                  hintText: 'Enter your username',
                  prefixIcon: Icons.person_outline,
                  isEnabled: !_isLocked,
                )

                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: !_isLocked ? Colors.black.withOpacity(0.85) : Colors.grey.shade400,
                      ),
                      child: const Text("Username"),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isLocked ? null : _showAccountModal,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(!_isLocked ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: !_isLocked
                                    ? AppColors.inputBorder.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.person_outline, size: 20, color: Colors.black54),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      _usernameController.text.isNotEmpty
                                          ? _usernameController.text
                                          : 'Choose Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: !_isLocked ? AppColors.text : Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔒 Password Field
                _customTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: 'Enter your password',
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

                // ⏱ Countdown when locked
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
  void _showAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 320),
        vsync: this,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag bar
                    Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Subtitle
                    Text(
                      "Your saved usernames are securely stored\nfor faster login.\nManaged by HPS SmartBank.",
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Username list
                    ..._pastUsernames.map((username) {
                      final isSelected = _usernameController.text.trim() == username;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected ? Border.all(color: Colors.white24, width: 1.4) : null,
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ]
                              : [],
                        ),
                        transform: isSelected
                            ? (Matrix4.identity()..scale(1.02))
                            : Matrix4.identity(),
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle_outlined, color: Colors.white60, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await _checkIfFirstLogin(username);
                                  setState(() {
                                    _usernameController.text = username;
                                    _validateInputs();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  username,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            (_pastUsernames.length == 1 && isSelected)
                                ? GestureDetector(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                setState(() {
                                  _pastUsernames.remove(username);
                                  _usernameController.clear();
                                  _validateInputs();
                                });
                                modalSetState(() {});
                                await prefs.setStringList('past_usernames', _pastUsernames);

                                Navigator.pop(context);
                                showCupertinoGlassToast(
                                  context,
                                  'All usernames cleared',
                                  isSuccess: true,
                                  position: ToastPosition.top,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                              ),
                            )
                                : isSelected
                                ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white70,
                              ),
                            )
                                : GestureDetector(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                setState(() {
                                  _pastUsernames.remove(username);
                                  if (_usernameController.text == username) {
                                    _usernameController.clear();
                                    _validateInputs();
                                  }
                                });
                                modalSetState(() {});
                                await prefs.setStringList('past_usernames', _pastUsernames);

                                if (_pastUsernames.isEmpty) {
                                  modalSetState(() {
                                    _showNewUsernameInput = false;
                                  });

                                  await prefs.remove('remembered_username'); // ✅ clear it here
                                  Navigator.pop(context);

                                  showCupertinoGlassToast(
                                    context,
                                    'All usernames cleared',
                                    isSuccess: true,
                                    position: ToastPosition.top,
                                  );
                                  return;
                                }


                                showCupertinoGlassToast(
                                  context,
                                  'Username "$username" removed',
                                  isSuccess: true,
                                  position: ToastPosition.top,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                              ),
                            )

                          ],
                        ),
                      );
                    }),


                    const SizedBox(height: 18),

                    // Add / Cancel Toggle
                    GestureDetector(
                      onTap: () {
                        modalSetState(() {
                          _showNewUsernameInput = !_showNewUsernameInput;
                          _newUsernameController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showNewUsernameInput ? Icons.close : Icons.add_circle_outline,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showNewUsernameInput ? 'Cancel' : 'Add a New Account',
                              style: GoogleFonts.inter(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Animated input + button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      child: _showNewUsernameInput
                          ? Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Column(
                          children: [
                            // Unified input field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 20, color: Colors.white60),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _newUsernameController,
                                      style: const TextStyle(color: Colors.white),
                                      cursorColor: Colors.white,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter new username',
                                        hintStyle: TextStyle(color: Colors.white54),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Unified save button
                            GestureDetector(
                              onTap: () async {
                                final newUsername = _newUsernameController.text.trim();
                                if (newUsername.isNotEmpty) {
                                  final prefs = await SharedPreferences.getInstance();
                                  if (!_pastUsernames.contains(newUsername)) {
                                    _pastUsernames.add(newUsername);
                                    await prefs.setStringList('past_usernames', _pastUsernames);
                                  }

                                  modalSetState(() {
                                    _showNewUsernameInput = false;
                                    _newUsernameController.clear();
                                  });

                                  Navigator.pop(context);

                                  setState(() {
                                    _usernameController.text = newUsername;
                                    _validateInputs();
                                  });

                                  showCupertinoGlassToast(
                                    context,
                                    'Username "$newUsername" added',
                                    isSuccess: true,
                                    position: ToastPosition.top,
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF007AFF), Color(0xFF0051D6)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Save Username',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
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
    String? hintText, // ✅ New optional parameter
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
    bool isEnabled = true,
  }) {
    final focusNode = FocusNode();
    bool wasFocused = false;

    return StatefulBuilder(
      builder: (context, localSetState) {
        focusNode.addListener(() {
          // Select all text on first focus
          if (focusNode.hasFocus && !wasFocused) {
            wasFocused = true;
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          }
          if (!focusNode.hasFocus) {
            wasFocused = false;
          }
          localSetState(() {});
        });

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
                    ? Colors.black.withOpacity(0.85)
                    : Colors.grey.shade400,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isEnabled ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: !isEnabled
                          ? Colors.grey.withOpacity(0.3)
                          : AppColors.inputBorder.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: isEnabled,
                    obscureText: isPassword && !_isPasswordVisible,
                    onChanged: (_) => _validateInputs(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isEnabled ? AppColors.text : Colors.grey.shade500,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: hintText ?? '',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: InputBorder.none,
                      prefixIcon: prefixIcon != null
                          ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          prefixIcon,
                          size: 20,
                          color: Colors.black.withOpacity(0.75),
                        ),
                      )
                          : null,
                      suffixIcon: (suffixIcon != null && controller.text.isNotEmpty)
                          ? GestureDetector(
                        onTap: isEnabled ? onSuffixTap : null,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            suffixIcon,
                            size: 20,
                            color: Colors.black.withOpacity(0.75),
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
                      ? () async {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text;
                    final dto = LoginUserDto(username: username, password: password);

                    final response = await _authService.login(dto);

                    if (response != null && response.statusCode == 200) {
                      final prefs = await SharedPreferences.getInstance();
                      final secureStorage = FlutterSecureStorage();

                      // ✅ Save credentials
                      await prefs.setString('remembered_username', username);
                      await secureStorage.write(key: 'password_$username', value: password);

                      List<String> previousUsers =
                          prefs.getStringList('past_usernames') ?? [];
                      if (!previousUsers.contains(username)) {
                        previousUsers.add(username);
                        await prefs.setStringList('past_usernames', previousUsers);
                      }

                      final isFirst = _isFirstLogin;
                      if (isFirst) {
                        final biometricService = BiometricService();
                        final success = await biometricService.promptFingerprintSetup();

                        if (!success) {
                          showCupertinoGlassToast(
                            context,
                            'Please activate fingerprint to continue.',
                            isSuccess: false,
                            position: ToastPosition.top,
                          );
                          return;
                        }
                        await prefs.setBool('first_login_$username', false);
                      }

                      setState(() {
                        _remainingAttempts = 3;
                        _isLocked = false;
                        _remainingTime = Duration.zero;
                        _unlockTime = null;
                        _isFirstLogin = false;
                      });

                      // ✅ Use post-frame callback to avoid Impeller crash
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go('/security_code_setup');
                      });
                    } else if (response != null) {
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
                          final nextLockDuration = Duration(minutes: 1 + 4 * _lockAttemptLevel);
                          _unlockTime = DateTime.now().add(nextLockDuration);
                          _lockDuration = nextLockDuration;
                          _remainingTime = _lockDuration;
                        });
                        _ticker.start();
                      }
                    } else {
                      showCupertinoGlassToast(
                        context,
                        'Server error. Please try again.',
                        isSuccess: false,
                        position: ToastPosition.top,
                      );
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
    final bool isDisabled = _isLocked || _isFirstLogin;

    return Center(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () async {
          final biometricService = BiometricService();
          final authenticated = await biometricService.authenticateWithBiometrics(
            reason: 'Sign in to your SmartBank account',
          );
          print('✅ Biometric authenticated: $authenticated');

          if (!authenticated) {
            showCupertinoGlassToast(
              context,
              'Authentication failed or cancelled.',
              isSuccess: false,
              position: ToastPosition.top,
            );
            return;
          }

          final username = _usernameController.text.trim();
          print('🔍 Username used for biometric login: "$username"');

          if (username.isEmpty) {
            showCupertinoGlassToast(
              context,
              'No user selected. Please choose or enter a username.',
              isSuccess: false,
              position: ToastPosition.top,
            );
            return;
          }

          final secureStorage = FlutterSecureStorage();
          final storedPassword = await secureStorage.read(key: 'password_$username');
          print('🔐 Stored password: ${storedPassword != null ? "✅ Found" : "❌ Not found"}');

          if (storedPassword == null) {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text('No Credentials Found'),
                content: const Text('Please log in manually at least once to enable biometric login.'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          final response = await _authService.login(
            LoginUserDto(username: username, password: storedPassword),
          );

          if (response != null && response.statusCode == 200) {
            print('✅ Biometric login successful. Redirecting...');

            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('first_login_${username}', false); // ✅ mark as not first anymore
            setState(() {
              _isFirstLogin = false;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/verify_code'); // ✅ redirected here
            });
          }

          else {
            showCupertinoGlassToast(
              context,
              'Biometric login failed. Try entering your password.',
              isSuccess: false,
              position: ToastPosition.top,
            );
          }
        },
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.4 : 1.0,
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
    final bool isDisabled = _isLocked || _isFirstLogin;

    return Center(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
          context.go('/home');
        },
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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
                    child: Icon(
                      Icons.lock_reset,
                      size: 18,
                      color: isDisabled ? Colors.grey.shade400 : Colors.black,
                    ),
                  ),
                ),
                TextSpan(
                  text: 'Reset here',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? Colors.grey.shade400 : Colors.black,
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


  @override
  void initState() {
    super.initState();

    // ⏳ Setup countdown ticker
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
          _lockAttemptLevel++;
        });

        // ✅ Show unlock success dialog
        Future.delayed(const Duration(milliseconds: 400), () {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              insetAnimationDuration: const Duration(milliseconds: 300),
              insetAnimationCurve: Curves.easeInOut,
              title: Column(
                children: [
                  const Icon(CupertinoIcons.checkmark_seal_fill,
                      size: 44, color: CupertinoColors.activeGreen),
                  const SizedBox(height: 12),
                  Text("You're Unblocked",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.black,
                      )),
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
            ),
          );
        });
      }
    });

    // 🧠 Load user info from SharedPreferences
    SharedPreferences.getInstance().then((prefs) async {
      final savedUsername = prefs.getString('remembered_username');
      final past = prefs.getStringList('past_usernames') ?? [];

      final secureStorage = FlutterSecureStorage();
      final storedPassword = savedUsername != null
          ? await secureStorage.read(key: 'password_$savedUsername')
          : null;

      // ✅ Debug prints
      print('🔐 Remembered username: $savedUsername');
      print('📦 Past usernames: $past');
      print('🔐 Stored password for $savedUsername: ${storedPassword != null ? storedPassword : '❌ null'}');

      // 🧼 Clean orphaned remembered_username
      if (savedUsername != null && !past.contains(savedUsername)) {
        await prefs.remove('remembered_username');
      }

      final currentUser = savedUsername != null && past.contains(savedUsername)
          ? savedUsername
          : (past.isNotEmpty ? past.last : null);

      final isFirst = currentUser != null
          ? (prefs.getBool('first_login_$currentUser') ?? true)
          : true;

      setState(() {
        _pastUsernames = past;
        _isFirstLogin = isFirst;
      });

      if (currentUser != null) {
        _usernameController.text = currentUser;
        await _checkIfFirstLogin(currentUser); // make sure it's awaited
      }

    });

    // 👂 Input field listeners
    _usernameController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);

    // 🔔 Redirect toast (e.g., after password reset)
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
  }

  Future<void> _checkIfFirstLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = username.isEmpty
        ? true
        : (prefs.getBool('first_login_$username') ?? true);

    if (_isFirstLogin != isFirst) {
      setState(() {
        _isFirstLogin = isFirst;
      });
    }
  }



  void _validateInputs() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final isEnabled = username.isNotEmpty && password.isNotEmpty;

    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }

    // ✅ Always trigger first login check, even if username is empty (to reset UI)
    _loginCheckTimer?.cancel();
    _loginCheckTimer = Timer(const Duration(milliseconds: 300), () {
      _checkIfFirstLogin(username); // triggers true if empty or false based on prefs
    });
  }

}