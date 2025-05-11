import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sami/widgets/Transactions_Home.dart';
import '../widgets/Alerts_Home.dart';
import '../widgets/Home_Header.dart';
import '../widgets/Card_Scroller.dart';
import '../widgets/Account_Summary.dart';
import '../widgets/Navbar.dart';
import '../widgets/UltraSwitch.dart';
import '../widgets/Toast.dart';
import 'package:go_router/go_router.dart';


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
  String selectedCardLabel = "Visa Youth";

  Map<String, bool> contactlessMap = {};
  Map<String, bool> ecommerceMap = {};
  Map<String, bool> tpeMap = {};


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
                    child:CardScroller(
                      onCardChanged: (label) {
                        setState(() {
                          selectedCardLabel = label;
                          _initCardSettings(label);
                        });
                      },
                      onCardTap: (label) {
                        // 🔎 Check if it's a physical card (customize this check based on your labels)
                        final isPhysicalCard = label.toLowerCase().contains('visa') || label.toLowerCase().contains('physical');

                        if (isPhysicalCard) {
                          // 1️⃣ Navigate to the physical card details screen
                          context.push('/physical_card_details');

                          // 2️⃣ Show a toast
                          showCupertinoGlassToast(
                            context,
                            'You can now manage your Physical Card here.',
                            isSuccess: true,
                            position: ToastPosition.top,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📊 Account Summary
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AccountSummary(),
                  ),

                  const SizedBox(height: 24),

                  // 🔒 Payment Security Toggles (iOS-style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Security Options",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPaymentToggleRow(
                          icon: Icons.nfc,
                          label: "Contactless Payments",
                          value: contactlessMap[selectedCardLabel] ?? true,
                          onChanged: (val) {
                            setState(() {
                              contactlessMap[selectedCardLabel] = val;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentToggleRow(
                          icon: Icons.shopping_cart_outlined,
                          label: "E-Commerce Payments",
                          value: ecommerceMap[selectedCardLabel] ?? true,
                          onChanged: (val) {
                            setState(() {
                              ecommerceMap[selectedCardLabel] = val;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentToggleRow(
                          icon: Icons.point_of_sale_outlined,
                          label: "TPE Payments",
                          value: tpeMap[selectedCardLabel] ?? true,
                          onChanged: (val) {
                            setState(() {
                              tpeMap[selectedCardLabel] = val;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            // ✅ Navigate using GoRouter & pass a flag
                            context.push('/physical_card_details', extra: {'autoScroll': true});

                            // ✅ Show a toast after navigating
                            Future.delayed(const Duration(milliseconds: 300), () {
                              showCupertinoGlassToast(
                                context,
                                'Manage card & security options here.',
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            });
                          },
                          child: Container(
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
                              children: const [
                                Icon(Icons.lock_person_outlined, size: 22, color: Colors.redAccent),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Block this card",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🚨 Alerts Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AlertsWidget(
                      onViewAll: () {
                        context.push('/notifications'); // ✅ navigate to Notifications screen
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 📈 Transactions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TransactionsWidget(
                      onViewAll: () {
                        context.push('/transactions'); // 👈 Go to Transactions screen
                      },
                    ),
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
            child: HomeHeader(
              onNotificationsPressed: () {
                context.push('/notifications'); // ✅ Push to your NotificationsScreen
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const IOSBottomNavbar(),

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
  @override
  void initState() {
    super.initState();
    _initCardSettings("Visa Youth");
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (extra?['showWelcome'] == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning ☀️'
            : hour < 18
            ? 'Good afternoon 🌤️'
            : 'Good evening 🌙';

        showCupertinoGlassToast(
          context,
          "$greeting\nWelcome back!",
          isSuccess: true,
          position: ToastPosition.top,
        );
      });
    }
  }

  void _initCardSettings(String label) {
    contactlessMap.putIfAbsent(label, () => true);
    ecommerceMap.putIfAbsent(label, () => true);
    tpeMap.putIfAbsent(label, () => true);
  }


}
