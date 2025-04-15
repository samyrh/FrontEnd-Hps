import 'package:flutter/material.dart';

class AIScreen2 extends StatelessWidget {
  const AIScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF2F3F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'AI Chatbot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E2D),
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Full image with shadow
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 30,
                    spreadRadius: 1,
                    offset: const Offset(0, 12),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/ai2.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false),
                _buildDot(isActive: true), // Second dot active
                _buildDot(isActive: false),
              ],
            ),

            const SizedBox(height: 36),

            const Text(
              "AI for Real-time Assistance",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Text(
              "Boosting User Engagement",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                "AI helps you engage smarter.\nGet intelligent support anytime.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // Navigation buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 👈 Back button (clickable)
                  InkWell(
                    onTap: () {
                      Navigator.pop(context); // Go back
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.black87,
                    ),
                  ),

                  // 🔳 Vertical separator
                  Container(
                    width: 1.5,
                    height: 24,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // 👉 Forward button (clickable)
                  InkWell(
                    onTap: () {
                      print("Next button clicked");
                      // Example: Navigator.push to a next screen
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: isActive ? 24 : 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
