import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart'; // ✅ Make sure this is imported!

class Landing1 extends StatefulWidget {
  const Landing1({Key? key}) : super(key: key);

  @override
  State<Landing1> createState() => _Landing1State();
}

class _Landing1State extends State<Landing1> {
  @override
  void initState() {
    super.initState();
    // ✅ Use GoRouter to navigate after 5s
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      context.go('/welcome'); // ✅ Navigate to Landing2 route via GoRouter
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 640;
    final isMediumScreen = screenSize.width <= 991;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : isMediumScreen ? 24 : 40,
                vertical: isSmallScreen ? 16 : isMediumScreen ? 24 : 36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 250 : 200),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/e620c25d68c191a7395d3238b7b8e3b3d2eb8123',
                          width: isSmallScreen ? 230 : 285,
                          height: isSmallScreen ? (230 * 150 / 285) : 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Feel Good About Payments',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w600,
                            height: isSmallScreen ? 28 / 18 : 32 / 20,
                            letterSpacing: -0.2,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isSmallScreen ? 20 : 36,
              right: isSmallScreen ? 20 : 40,
              child: const LanguageSelector(),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ LanguageSelector stays unchanged
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = 'English';

  final List<String> languages = [
    'English (ENG)',
    'Français (FR)',
    '(AR) العربية',
  ];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Select Language",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return ListTile(
                title: Text(language, textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    selectedLanguage = language;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLanguageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(118, 118, 128, 0.12),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <path d="M2 12C2 17.5228 6.47715 22 12 22C17.5228 22 22 17.5228
                22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715
                2 12Z" stroke="#0F172A" stroke-width="1.5"
                stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M13 2.04932C13 2.04932 16 5.99994 16
                11.9999C16 17.9999 13 21.9506 13
                21.9506" stroke="#0F172A" stroke-width="1.5"
                stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M11 21.9506C11 21.9506 8 17.9999 8
                11.9999C8 5.99994 11 2.04932 11
                2.04932" stroke="#0F172A" stroke-width="1.5"
                stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M2.62964 15.5H21.3704" stroke="#0F172A"
                stroke-width="1.5" stroke-linecap="round"
                stroke-linejoin="round"/>
                <path d="M2.62964 8.5H21.3704" stroke="#0F172A"
                stroke-width="1.5" stroke-linecap="round"
                stroke-linejoin="round"/>
              </svg>''',
              width: 24,
              height: 24,
            ),
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF0F172A),
            ),
            Text(
              selectedLanguage,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0F172A)),
          ],
        ),
      ),
    );
  }
}
