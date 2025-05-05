import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Notificationparametre extends StatefulWidget {
  const Notificationparametre({Key? key}) : super(key: key);

  @override
  State<Notificationparametre> createState() => _NotificationparametreState();
}

class _NotificationparametreState extends State<Notificationparametre> {
  bool switch1 = true;
  bool switch2 = true;
  bool switch3 = true;
  bool switch4 = true;
  bool switch5 = true;
  bool switch6 = true;
  bool switch7 = true;
  bool switch8 = true;
  bool switch9 = true;
  bool switch10 = true;

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
              'Notifications',
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
              Color(0xFFEAF2FF),
              Color(0xFFFFFFFF),
              Color(0xFFFFE5EC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () => _showLogoutDialog(context),
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

                Expanded(
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: 12),
                        child: Text('Transaction',
                            style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      SettingsItem(
                        title: 'Incoming transaction',
                        subtitle: 'Receive a notification for incoming transactions',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch4,
                          onChanged: (val) => setState(() => switch4 = val),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: 12),
                        child: Text(
                          'Travel Plan',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SettingsItem(
                        title: 'Travel plan approved',
                        subtitle: 'Get notified when your travel plan is validated',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch5,
                          onChanged: (val) => setState(() => switch5 = val),
                        ),
                      ),
                      SettingsItem(
                        title: 'Travel plan reminder',
                        subtitle: 'Reminder when your travel plan is about to expire',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch6,
                          onChanged: (val) => setState(() => switch6 = val),
                        ),
                      ),

                      // 🔔 Alerts Section
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: 12),
                        child: Text(
                          'Alerts',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SettingsItem(
                        title: 'Transaction alert received',
                        subtitle: 'Get notified when a transaction alert is triggered',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch7,
                          onChanged: (val) => setState(() => switch7 = val),
                        ),
                      ),
                      SettingsItem(
                        title: 'Suspicious activity detected',
                        subtitle: 'Be alerted when we detect unusual activity',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch8,
                          onChanged: (val) => setState(() => switch8 = val),
                        ),
                      ),

// 💳 Cards Section
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: 12),
                        child: Text(
                          'Cards',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SettingsItem(
                        title: 'Card blocked',
                        subtitle: 'Notification when a card is blocked',
                        hasSwitch: true,
                        switchWidget: CupertinoSwitch(
                          activeColor: CupertinoColors.activeBlue,
                          value: switch9,
                          onChanged: (val) => setState(() => switch9 = val),
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

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasSwitch;
  final Widget? switchWidget;
  final VoidCallback? onTap;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.hasSwitch = false,
    this.switchWidget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            if (hasSwitch && switchWidget != null) switchWidget!,
          ],
        ),
      ),
    );
  }
}
