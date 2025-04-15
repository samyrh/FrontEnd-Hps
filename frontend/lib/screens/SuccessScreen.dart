import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const SuccessScreen({
    Key? key,
    this.onBackToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 120),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Created Successfully !',
                    style: TextStyle(
                      color: const Color(0xFF144EA6),
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      height: 18 / 27, // lineHeight: 18px
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 307,
                    child: Text(
                      'Your virtual card has been created successfully.',
                      style: TextStyle(
                        color: const Color(0xFF5D5A5A),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Inter',
                        height: 18 / 15, // lineHeight: 18px
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/de7f127f13bb8e9ed3cd52bce2655ee5a3582dc1',
                    width: 368,
                    height: 302,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
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