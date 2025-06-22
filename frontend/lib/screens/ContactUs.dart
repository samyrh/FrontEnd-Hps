import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> contacts = const [
    {
      'location': 'HPS Casablanca (HQ)',
      'address': '4 Rue Soumaya, Quartier Palmiers, Casablanca 20340, Morocco',
      'lat': 33.537948,
      'lng': -7.649650,
      'phone': '+212 522 97 96 00',
      'email': 'contact@hps-worldwide.com',
    },
    {
      'location': 'HPS Paris',
      'address': 'Tour CIT, 3 Rue de l’Arrivée, 75015 Paris, France',
      'lat': 48.842930,
      'lng': 2.321000,
      'phone': '+33 1 53 95 19 00',
      'email': 'paris@hps-worldwide.com',
    },
    {
      'location': 'HPS Dubai',
      'address': 'Building 4, Dubai Internet City, Dubai, UAE',
      'lat': 25.095369,
      'lng': 55.158013,
      'phone': '+971 4 390 29 40',
      'email': 'dubai@hps-worldwide.com',
    },
    {
      'location': 'HPS Singapore',
      'address': '6 Battery Rd, Level 30, Singapore 049909',
      'lat': 1.283611,
      'lng': 103.851111,
      'phone': '+65 6221 0800',
      'email': 'singapore@hps-worldwide.com',
    },
    {
      'location': 'HPS Johannesburg',
      'address': '173 Oxford Rd, Rosebank, Johannesburg, 2196, South Africa',
      'lat': -26.107060,
      'lng': 28.056671,
      'phone': '+27 11 884 80 40',
      'email': 'johannesburg@hps-worldwide.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF6F0FF), Color(0xFFEAF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(CupertinoIcons.back, size: 20),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
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
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFCEE7FF), Color(0xFFFCE0FF)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Icon(CupertinoIcons.location, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        contact['location'],
                                        style: const TextStyle(
                                          fontSize: 16.2,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contact['address'],
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.grey.shade800,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final lat = contact['lat'];
                                        final lng = contact['lng'];
                                        final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                                        openMapUrl(url);
                                      },
                                      child: Row(
                                        children: const [
                                          SizedBox(width: 10),
                                          Icon(CupertinoIcons.map_pin_ellipse,
                                              size: 16, color: CupertinoColors.systemBlue),
                                          SizedBox(width: 4),
                                          Text(
                                            "Open in Maps",
                                            style: TextStyle(
                                              fontSize: 13.2,
                                              fontWeight: FontWeight.w500,
                                              color: CupertinoColors.systemBlue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.phone_fill,
                                        size: 16, color: CupertinoColors.systemBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      contact['phone'],
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.mail_solid,
                                        size: 16, color: CupertinoColors.systemPink),
                                    const SizedBox(width: 8),
                                    Text(
                                      contact['email'],
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
  Future<void> openMapUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Cannot launch: $url');
      throw 'Could not launch $url';
    }
  }

}
