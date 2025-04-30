import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sami/widgets/Transactions_Home.dart';
import '../widgets/Alerts_Home.dart';
import '../widgets/BlockCard_Home.dart';
import '../widgets/Home_Header.dart';
import '../widgets/Card_Scroller.dart';
import '../widgets/Account_Summary.dart';
import '../widgets/Navbar.dart';
import '../widgets/ActivateDisactivate.dart';
import '../widgets/UltraSwitch.dart'; // Only imported here
import '../widgets/Toast.dart';
import '../widgets/CustomDropdown.dart'; // if needed for reason


// hello
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isContactlessEnabled = true;
  bool isEcommerceEnabled = true;
  bool isTpeEnabled = true;


  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final fadeOpacity = _scrollController.hasClients
        ? max(0.85, 1 - (_scrollController.offset.clamp(0.0, 100.0) / 100))
        : 1.0;

    final bounceScale = _scrollController.hasClients && _scrollController.offset < 0
        ? 1.0 - (_scrollController.offset / -150)
        : 1.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌈 Soft Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFCCD9EA), // Slightly darker soft blue
                  Color(0xFFE6ECF3), // Soft grey-blue
                  Color(0xFFF9FBFD), // Very light near-white
                ],

              ),
            ),
          ),

          // 🧊 Frosted Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          // 📜 Scrollable Content
          Padding(
            padding: EdgeInsets.only(top: topPadding + 110), // Tighten space under header
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  // 💳 Card Carousel
                  AnimatedScale(
                    scale: bounceScale.clamp(0.96, 1.02),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    child: const CardScroller(),
                  ),

                  const SizedBox(height: 12),

                  // 📊 Account Summary
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AccountSummary(),
                  ),

                  const SizedBox(height: 20),

                  // 🔒 Payment Security Toggles (iOS-style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaymentToggleRow(
                          icon: Icons.nfc,
                          label: "Contactless Payments",
                          value: isContactlessEnabled,
                          onChanged: (val) {
                            setState(() => isContactlessEnabled = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentToggleRow(
                          icon: Icons.shopping_cart_outlined,
                          label: "E-Commerce Payments",
                          value: isEcommerceEnabled,
                          onChanged: (val) {
                            setState(() => isEcommerceEnabled = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentToggleRow(
                          icon: Icons.point_of_sale_outlined,
                          label: "TPE Payments",
                          value: isTpeEnabled,
                          onChanged: (val) {
                            setState(() => isTpeEnabled = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🚨 Alerts Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AlertsWidget(),
                  ),

                  const SizedBox(height: 28),

                  // 📈 Transactions Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TransactionsWidget(),
                  ),
                ],
              ),
            ),
          ),

          // 👤 Floating Header (without title or back button)
          Positioned(
            top: topPadding + 30,
            left: 20,
            right: 20,
            child: const HomeHeader(),
          ),
        ],
      ),

      // 📌 Bottom Navbar
      bottomNavigationBar: Navbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildPaymentToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          UltraSwitch(
            value: value,
            onChanged: (val) {
              onChanged(val);
              showCupertinoGlassToast(
                context,
                "$label ${val ? 'enabled' : 'disabled'}",
                isSuccess: val,
                position: ToastPosition.top,
              );
            },
            activeColor: Colors.blueAccent,
          ),

        ],
      ),
    );
  }



}
