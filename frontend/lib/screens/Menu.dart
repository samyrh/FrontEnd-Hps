import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EBankingMenuScreen extends StatelessWidget {
  const EBankingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(label: 'Personal Infos', subtitle: 'Manage your profile', icon: Icons.person_rounded, color: const Color(0xFF007AFF)),
      _MenuItem(label: 'Cards', subtitle: 'View & manage cards', icon: Icons.credit_card_rounded, color: const Color(0xFF5856D6)),
      _MenuItem(label: 'Travel Plan', subtitle: 'Plan card access abroad', icon: Icons.airplanemode_active_rounded, color: const Color(0xFF34C759)),
      _MenuItem(label: 'Contact Us', subtitle: 'Get help and support', icon: Icons.chat_bubble_outline_rounded, color: const Color(0xFFFF9500)),
      _MenuItem(label: 'Complain', subtitle: 'Report an issue', icon: Icons.report_problem_rounded, color: const Color(0xFFFF3B30)),
      _MenuItem(label: 'Settings', subtitle: 'App preferences', icon: Icons.settings_rounded, color: const Color(0xFF8E8E93)),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F2FA), Color(0xFFEDEBFA), Color(0xFFFFF0F5)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E2D),
                        fontFamily: 'Inter',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.go('/home'),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          // 🧠 Get saved usernames before clearing
                          final savedUsername = prefs.getString('remembered_username');
                          final savedUserList = prefs.getStringList('past_usernames');

                          // ❌ DO NOT use prefs.clear()
                          await prefs.remove('jwt_token'); // Remove session only

                          // ✅ Restore usernames if needed
                          if (savedUsername != null && savedUsername.isNotEmpty) {
                            await prefs.setString('remembered_username', savedUsername);
                          }

                          if (savedUserList != null && savedUserList.isNotEmpty) {
                            await prefs.setStringList('past_usernames', savedUserList);
                          }

                          if (context.mounted) {
                            context.go('/sign_in'); // 🔄 Redirect to login
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.18),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 18, offset: const Offset(0, 6)),
                              BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 2, spreadRadius: -1, offset: const Offset(-1, -1)),
                            ],
                          ),
                          child: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF1C1C1E)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double screenWidth = constraints.maxWidth;
                      final double cardWidth = (screenWidth - 20) / 2;

                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 24,
                          children: [
                            ...items.map((item) => SizedBox(
                              width: cardWidth,
                              child: _buildSquareIOSCard(context, item, screenWidth),
                            )),
                            SizedBox(
                              width: screenWidth,
                              child: _buildWideCard(context, screenWidth),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareIOSCard(BuildContext context, _MenuItem item, double screenWidth) {
    return GestureDetector(
      onTap: () {
        switch (item.label) {
          case 'Personal Infos':
            context.push('/profile');
            break;
          case 'Cards':
            context.push('/cards');
            break;
          case 'Travel Plan':
            context.push('/travel_plan');
            break;
          case 'Contact Us':
            context.push('/contact_us');
            break;
          case 'Complain':
            context.push('/complain');
            break;
          case 'Settings':
            context.push('/settings');
            break;
        }
      },
      child: AspectRatio(
        aspectRatio: 1.15,
        child: Container(
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 48, offset: const Offset(0, 18)),
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.white.withOpacity(0.35), blurRadius: 3, spreadRadius: -1, offset: const Offset(-1, -1)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xAAF8F6FB), Color(0xAAEDEBFA), Color(0xAAFFF0F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: screenWidth * 0.12, color: item.color),
                          const SizedBox(height: 12),
                          Text(item.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              )),
                          const SizedBox(height: 4),
                          Text(item.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.55),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () {
        context.push('/card_packs');
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 48, offset: const Offset(0, 18)),
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xAAF8F6FB), Color(0xAAEDEBFA), Color(0xAAFFF0F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, size: 96, color: Color(0xFFAC53F2)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Our Packages',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Explore bundles for Physical Cards and Virtual Cards',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  _MenuItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
