// home2.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Landing3.dart';

class Landing2 extends StatelessWidget {
  const Landing2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 375),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/adcd7f10a61205b9fa5d04774a95001770993feb',
                    width: double.infinity,
                    height: 305,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: index == 0 ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFF0066FF)
                              : const Color(0xFF0066FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 272),
                    child: Column(
                      children: [
                        Text(
                          'Simple Moves. Smart Banking',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Simple by HPS enhances security with seamless integration.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7E848D),
                            height: 1.71,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 52),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => const Landing3(),
                            transitionsBuilder: (_, animation, __, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              final tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: Curves.easeInOut),
                              );
                              return SlideTransition(position: animation.drive(tween), child: child);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
