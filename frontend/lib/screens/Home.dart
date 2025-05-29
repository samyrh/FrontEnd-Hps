import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../dto/CardSecurityOptionsModel.dart';
import '../dto/card_model.dart';
import '../services/card_service/CardSecurityService.dart';
import '../widgets/Alerts_Home.dart';
import '../widgets/Home_Header.dart';
import '../widgets/Card_Scroller.dart';
import '../widgets/Account_Summary.dart';
import '../widgets/Navbar.dart';
import '../widgets/Transactions_Home.dart';
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
  bool _hasShownWelcomeToast = false;
  Map<String, bool> contactlessMap = {};
  Map<String, bool> ecommerceMap = {};
  Map<String, bool> tpeMap = {};
  CardModel? _selectedCard;
  List<CardSecurityOptionsModel> _securityOptions = [];


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
                        onCardChanged: (card) async {
                          setState(() {
                            selectedCardLabel = card.cardPack.label;
                            _selectedCard = card;
                          });

                          await _loadSecurityOptions(); // 👈 Fetch fresh data when card changes

                          final option = _securityOptions.firstWhere(
                                (opt) => opt.label == card.cardPack.label,
                            orElse: () => CardSecurityOptionsModel(
                              label: card.cardPack.label,
                              contactlessEnabled: true,
                              ecommerceEnabled: true,
                              tpeEnabled: true,
                              username: '',
                              cardholderName: '',
                            ),
                          );

                          setState(() {
                            contactlessMap[card.cardPack.label] = option.contactlessEnabled;
                            ecommerceMap[card.cardPack.label] = option.ecommerceEnabled;
                            tpeMap[card.cardPack.label] = option.tpeEnabled;
                          });
                        },
                        onCardTap: (card) {
                        final isPhysicalCard = card.type.toLowerCase().contains('physical') ||
                            card.cardPack.label.toLowerCase().contains('visa');

                        if (isPhysicalCard) {
                          context.push('/physical_card_details');

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

                  if (_selectedCard != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AccountSummary(card: _selectedCard!),
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
                          onChanged: (val) async {
                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOption(
                              label: selectedCardLabel,
                              contactlessEnabled: val,
                            );
                            await _refreshCurrentCardSecurityOptions();
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentToggleRow(
                          icon: Icons.shopping_cart_outlined,
                          label: "E-Commerce Payments",
                          value: ecommerceMap[selectedCardLabel] ?? true,
                          onChanged: (val) async {
                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOption(
                              label: selectedCardLabel,
                              ecommerceEnabled: val,
                            );
                            await _refreshCurrentCardSecurityOptions();
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentToggleRow(
                          icon: Icons.point_of_sale_outlined,
                          label: "TPE Payments",
                          value: tpeMap[selectedCardLabel] ?? true,
                          onChanged: (val) async {
                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOption(
                              label: selectedCardLabel,
                              tpeEnabled: val,
                            );
                            await _refreshCurrentCardSecurityOptions();
                          },
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            context.push('/physical_card_details', extra: {'autoScroll': true});
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
  Future<void> _loadSecurityOptions() async {
    final service = SecurityOptionsService();
    try {
      final options = await service.fetchCardSecurityOptions();
      setState(() {
        _securityOptions = options;
        for (var opt in options) {
          contactlessMap[opt.label] = opt.contactlessEnabled;
          ecommerceMap[opt.label] = opt.ecommerceEnabled;
          tpeMap[opt.label] = opt.tpeEnabled;
        }
      });
    } catch (e) {
      print("❌ Failed to load security options: $e");
    }
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning ☀️';
    if (hour < 18) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    // ✅ Welcome Greeting Based on Time
    if (!_hasShownWelcomeToast && extra?['showWelcome'] == true) {
      _hasShownWelcomeToast = true;

      Future.delayed(const Duration(milliseconds: 500), () {
        final greeting = _getTimeBasedGreeting();

        showCupertinoGlassToast(
          context,
          "$greeting\nWelcome back!",
          isSuccess: true,
          position: ToastPosition.top,
        );
      });
    }

    // ✅ Post-Password-Change Toast (with delay)
    if (extra?['showToast'] == true && extra?['toastMessage'] != null) {
      Future.delayed(const Duration(milliseconds: 1100), () {
        showCupertinoGlassToast(
          context,
          extra!['toastMessage'],
          isSuccess: true,
          position: ToastPosition.top,
        );
      });
    }
  }



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentCardSecurityOptions();
    });
  }


  Future<void> _refreshCurrentCardSecurityOptions() async {
    final service = SecurityOptionsService();
    try {
      final options = await service.fetchCardSecurityOptions();
      final label = selectedCardLabel;

      final current = options.firstWhere(
            (e) => e.label == label,
        orElse: () => CardSecurityOptionsModel(
          label: label,
          contactlessEnabled: true,
          ecommerceEnabled: true,
          tpeEnabled: true,
          username: '',
          cardholderName: '',
        ),
      );

      setState(() {
        contactlessMap[label] = current.contactlessEnabled;
        ecommerceMap[label] = current.ecommerceEnabled;
        tpeMap[label] = current.tpeEnabled;
      });
    } catch (e) {
      print("❌ Failed to refresh toggles: $e");
    }
  }

}
