import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                // Add camera logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Add gallery logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDisabledInput({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
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
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFE0E0E0),
            contentPadding: const EdgeInsets.symmetric(vertical: 10), // smaller height
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildBirthDateRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Birth Date', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          enabled: false,
          initialValue: 'September 28 1999',
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFE0E0E0),
            contentPadding: const EdgeInsets.symmetric(vertical: 10), // smaller height
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.arrow_back, size: 24),
                  const Spacer(),
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 40),

              // Profile picture with edit overlay
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 55, // bigger picture
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    ),
                    GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Nada Senhaji',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 28),

              // Inputs
              buildDisabledInput(
                label: 'First Name',
                value: 'Sami',
                icon: Icons.person_outline_rounded,
              ),
              buildDisabledInput(
                label: 'Last Name',
                value: 'Rhalim',
                icon: Icons.person_outline_rounded,
              ),
              buildDisabledInput(
                label: 'Full Name',
                value: 'Sami Rhalim',
                icon: Icons.person,
              ),
              buildDisabledInput(
                label: 'Email Address',
                value: 'sami@gmail.com',
                icon: Icons.email_outlined,
              ),
              buildDisabledInput(
                label: 'Phone Number',
                value: '+8801728633389',
                icon: Icons.phone_outlined,
              ),
              buildBirthDateRow(),
            ],
          ),
        ),
      ),
    );
  }
}
