import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> contacts = const [
    {
      'location': 'HPS Casablanca (HQ)',
      'address': 'Rue Soumaya, Casablanca, Morocco',
      'phone': '+212 522 97 96 00',
      'email': 'contact@hps-worldwide.com',
    },
    {
      'location': 'HPS Paris',
      'address': 'Tour CIT Montparnasse, 3 Rue de l’Arrivée, 75015 Paris, France',
      'phone': '+33 1 53 95 19 00',
      'email': 'paris@hps-worldwide.com',
    },
    {
      'location': 'HPS Dubai',
      'address': 'Dubai Internet City, UAE',
      'phone': '+971 4 390 29 40',
      'email': 'dubai@hps-worldwide.com',
    },
    {
      'location': 'HPS Singapore',
      'address': '6 Battery Rd, Singapore 049909',
      'phone': '+65 6221 0800',
      'email': 'singapore@hps-worldwide.com',
    },
    {
      'location': 'HPS Johannesburg',
      'address': 'Sandton, Johannesburg, South Africa',
      'phone': '+27 11 884 80 40',
      'email': 'johannesburg@hps-worldwide.com',
    },
  ];

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    const Spacer(),
                    const Text(
                      'Contact Us',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 24),
                // Contact Cards
                Expanded(
                  child: ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88), // slightly more visible
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08), // stronger shadow
                              blurRadius: 24,
                              spreadRadius: 1,
                              offset: const Offset(0, 12), // lifted effect
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6), // subtle top-light
                              blurRadius: 6,
                              spreadRadius: -3,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE6F0FF),
                                  ),
                                  child: const Icon(Icons.location_on_rounded, color: Color(0xFF007AFF), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  contact['location']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              contact['address']!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  contact['phone']!,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  contact['email']!,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
