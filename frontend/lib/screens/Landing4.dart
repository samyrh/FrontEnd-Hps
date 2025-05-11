// home4.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // ✅ For routing
import 'package:intl/intl.dart';

// ✅ Assuming you put your toast in a separate file
import '../widgets/Toast.dart';
import 'Home.dart'; // ✅ Make sure HomeScreen is imported (if needed)

class Landing4 extends StatelessWidget {
  const Landing4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 99),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 3.3,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Image.asset(
                          'assets/cards.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == 2 ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == 2
                              ? const Color(0xFF0066FF)
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 58),
                  Text(
                    'Simplify the way you manage your cards',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Built-in Fingerprint, face recognition and more, keeping you completely safe',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7E848D),
                      height: 24 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 62),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to SignInScreen
                        context.go('/sign_in');

                        // Show a dynamic greeting toast
                        final now = DateTime.now();
                        final hour = now.hour;
                        final name = 'Nada'; // Replace with dynamic username if needed

                        String message;
                        if (hour < 12) {
                          message = 'Good morning, $name! Please sign in to continue.';
                        } else if (hour < 18) {
                          message = 'Good afternoon, $name! Please sign in to continue.';
                        } else {
                          message = 'Good evening, $name! Please sign in to continue.';
                        }

                        // Show your custom CupertinoGlassToast
                        showCupertinoGlassToast(
                          context,
                          message,
                          isSuccess: true,
                          position: ToastPosition.top,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
