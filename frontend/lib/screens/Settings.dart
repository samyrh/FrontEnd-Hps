import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool faceIdEnabled = false;

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
            child: Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              "Are you sure you want to log out? You’ll need to login again to use the app.",
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Profile
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Nada Rhandour',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Hps Client', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Settings List
              Expanded(
                child: ListView(
                  children: [
                    const SettingsItem(title: 'Personal Informations', icon: Icons.person_outline_rounded),
                    const SettingsItem(title: 'Cards', icon: Icons.credit_card_rounded),
                    const SettingsItem(title: 'Notifications', icon: Icons.notifications_none_rounded),
                    const SettingsItem(title: 'Travel Plan', icon: Icons.place_outlined),

                    SettingsItem(
                      title: 'Face ID',
                      imagePath: 'assets/FaceID.png',
                      hasSwitch: true,
                      switchWidget: CupertinoSwitch(
                        value: faceIdEnabled,
                        onChanged: (val) => setState(() => faceIdEnabled = val),
                      ),
                    ),
                    const SettingsItem(title: 'Complain', icon: Icons.report_gmailerrorred_outlined),
                    const SettingsItem(title: 'Contact', icon: Icons.support_agent_rounded),
                    const SettingsItem(title: 'Change Language', icon: Icons.language_rounded),

                    // ✅ New item here
                    const SettingsItem(title: 'Change Password', icon: Icons.lock_outline_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? imagePath;
  final bool hasSwitch;
  final Widget? switchWidget;
  final VoidCallback? onTap;

  const SettingsItem({
    Key? key,
    required this.title,
    this.icon,
    this.imagePath,
    this.hasSwitch = false,
    this.switchWidget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget leadingIcon = imagePath != null
        ? Image.asset(imagePath!, width: 28, height: 28)
        : Icon(icon, size: 26, color: Colors.black);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: leadingIcon,
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: hasSwitch ? switchWidget : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: hasSwitch ? null : onTap,
    );
  }
}