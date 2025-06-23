import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth/biometric_service.dart';
import '../widgets/BiometricSwitch.dart';
import '../widgets/Modal/UpdateCvvPinModal.dart';
import 'PolicyScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool fingerprintEnabled = false;
  bool isLoadingFingerprint = true;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadFingerprintStatus();
  }

  Future<void> _loadFingerprintStatus() async {
    try {
      final result = await _biometricService.getBiometricStatusFromServer();
      setState(() {
        fingerprintEnabled = result;
        isLoadingFingerprint = false;
      });
    } catch (_) {
      setState(() => isLoadingFingerprint = false);
    }
  }

  Future<void> _updateFingerprintStatus(bool value) async {
    setState(() => fingerprintEnabled = value);
    try {
      await _biometricService.updateBiometricStatusOnServer(value);
    } catch (_) {
      setState(() => fingerprintEnabled = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update biometric status")),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.only(top: 24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          title: const Center(
            child: Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              "Are you sure you want to log out?\nYou'll need to log in again to access your account.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      print('User logged out');
                    },
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F9FC),
              Color(0xFFFDF5FF),
              Color(0xFFF5FAFF),
              Color(0xFFFFF8FD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 22),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // HPS eWallet Card
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF1F5), Color(0xFFFFF5FA), Color(0xFFFFFAFD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 👈 ensures icon is vertically centered
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 36,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HPS eWallet Settings',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Configure all your wallet features here. Control biometric access, '
                                  'notification alerts, and privacy settings with ease and style.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.black54,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'GENERAL SETTINGS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Settings List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SettingsItem(
                        title: 'Notifications',
                        icon: Icons.notifications_none_rounded,
                        subtitle: 'Manage push alerts & preferences',
                        onTap: () => GoRouter.of(context).pushNamed('notification_settings'),
                      ),
                      SettingsItem(
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip_rounded,
                        subtitle: 'Read our data protection terms',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PolicyScreen()),
                        ),
                      ),
                      SettingsItem(
                        title: 'Change Language',
                        icon: Icons.language_rounded,
                        subtitle: 'Choose your preferred language',
                      ),
                      SettingsItem(
                        title: 'Change Password',
                        icon: Icons.lock_outline_rounded,
                        subtitle: 'Update your account password',
                        onTap: () => GoRouter.of(context).pushNamed('change password'),
                      ),
                      SettingsItem(
                        title: 'Update CVV / PIN',
                        icon: Icons.password_rounded,
                        subtitle: 'Secure your card access credentials',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const UpdateCvvPinModal(),
                        ),
                      ),
                      SettingsItem(
                        title: 'Enable Fingerprint',
                        icon: Icons.fingerprint_rounded,
                        subtitle: 'Allow biometric login',
                        hasSwitch: true,
                        switchWidget: isLoadingFingerprint
                            ? const CupertinoActivityIndicator()
                            : BiometricSwitch(
                          value: fingerprintEnabled,
                          onChanged: (val) async {
                            setState(() => fingerprintEnabled = val);
                            try {
                              await _updateFingerprintStatus(val);
                            } catch (_) {
                              setState(() => fingerprintEnabled = !val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error updating fingerprint status')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SETTINGS ITEM WIDGET

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? imagePath;
  final bool hasSwitch;
  final Widget? switchWidget;
  final VoidCallback? onTap;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imagePath,
    this.hasSwitch = false,
    this.switchWidget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget leadingIcon = imagePath != null
        ? Image.asset(imagePath!, width: 26, height: 26)
        : Icon(icon, size: 22, color: Colors.black87);

    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFF2F6FF), Color(0xFFEDF2FB), Color(0xFFFBF9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Center(child: leadingIcon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            hasSwitch
                ? switchWidget!
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
