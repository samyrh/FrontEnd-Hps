import 'package:flutter/material.dart';
import 'package:sami/screens/PhysicalCardDetailsScreen.dart';
import 'package:sami/screens/VirtualCardDetailsScreen.dart';



class SuccessScreen extends StatelessWidget {
  final String cardType;
  final String packName;
  final VoidCallback? onBackToHome;

  const SuccessScreen({
    Key? key,
    required this.cardType,
    required this.packName,
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
                    'Created Successfully!',
                    style: TextStyle(
                      color: const Color(0xFF144EA6),
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      height: 18 / 27,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 307,
                    child: Text(
                      'Your $packName ($cardType) card has been created successfully. A notification will be sent once it’s ready for use.',
                      style: TextStyle(
                        color: const Color(0xFF5D5A5A),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Inter',
                        height: 18 / 15,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
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
                        onPressed: onBackToHome ??
                                () {
                              Navigator.popUntil(
                                context,
                                    (route) => route.isFirst,
                              );
                            },
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF144EA6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () {
                          if (cardType.toLowerCase().contains('virtual')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VirtualCardDetailsScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhysicalCardDetailsScreen(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Card Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
