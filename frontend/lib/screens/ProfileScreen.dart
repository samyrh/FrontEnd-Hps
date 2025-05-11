import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
          ),
          const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget buildDisabledInput({
    required String label,
    required String value,
    required IconData icon,
    double paddingLeft = 0,
    double paddingRight = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFE0E0E0),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6F2FA),
            Color(0xFFEDEBFA),
            Color(0xFFFFF0F5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back and logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    GestureDetector(
                      onTap: () {
                        // TODO: Add logout logic
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: Offset(0, 4)),
                            BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 1, spreadRadius: -1, offset: Offset(-1, -1)),
                          ],
                        ),
                        child: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF1C1C1E)),
                      ),
                    ),
                  ],

                ),

                const SizedBox(height: 5),

                // Profile Image
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset(
                      'assets/profile.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Personal Info Section
                buildSectionTitle('Personal Information'),
                Row(
                  children: [
                    Expanded(
                      child: buildDisabledInput(
                        label: 'First Name',
                        value: 'Sami',
                        icon: Icons.person_outline_rounded,
                        paddingRight: 8,
                      ),
                    ),
                    Expanded(
                      child: buildDisabledInput(
                        label: 'Last Name',
                        value: 'Rhalim',
                        icon: Icons.person_outline_rounded,
                        paddingLeft: 8,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildDisabledInput(
                        label: 'Gender',
                        value: 'Male',
                        icon: Icons.wc,
                        paddingRight: 8,
                      ),
                    ),
                    Expanded(
                      child: buildDisabledInput(
                        label: 'Birth Date',
                        value: '28/09/1999',
                        icon: Icons.calendar_today_outlined,
                        paddingLeft: 8,
                      ),
                    ),
                  ],
                ),

                // Account Info Section
                buildSectionTitle('Account Information'),
                buildDisabledInput(
                  label: 'Email Address',
                  value: 'sami@gmail.com',
                  icon: Icons.email_outlined,
                ),
                buildDisabledInput(
                  label: 'Address',
                  value: '123 Rue Zerktouni, Casablanca',
                  icon: Icons.location_on_outlined,
                ),
                buildDisabledInput(
                  label: 'Phone Number',
                  value: '+212 612345678',
                  icon: Icons.phone_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
