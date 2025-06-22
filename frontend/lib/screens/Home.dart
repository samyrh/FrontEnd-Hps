import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../dto/card_dto/CardSecurityOptionsModel.dart';
import '../dto/card_dto/UpdateSecurityOptionRequest.dart';
import '../dto/card_dto/card_model.dart';
import '../services/card_service/CardSecurityService.dart';
import '../services/event/EventService.dart';
import '../widgets/Alerts_Home.dart';
import '../widgets/Home_Header.dart';
import '../widgets/Card_Scroller.dart';
import '../widgets/Account_Summary.dart';
import '../widgets/Navbar.dart';
import '../widgets/Transactions_Home.dart';
import '../widgets/UltraSwitch.dart';
import '../widgets/Toast.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver   {
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
  Timer? _securityRefreshTimer;
  int _unreadCount = 0;
  Timer? _unreadCountRefreshTimer;


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
                            if (_selectedCard == null) return;

                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOptions(
                              UpdateSecurityOptionRequest(
                                cardId: _selectedCard!.id,
                                contactlessEnabled: val,
                              ),
                            );
                            await _refreshCurrentCardSecurityOptions(selectedCardLabel);
                          },
                        ),


                        const SizedBox(height: 12),
                        _buildPaymentToggleRow(
                          icon: Icons.shopping_cart_outlined,
                          label: "E-Commerce Payments",
                          value: ecommerceMap[selectedCardLabel] ?? true,
                          onChanged: (val) async {
                            if (_selectedCard == null) return;

                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOptions(
                              UpdateSecurityOptionRequest(
                                cardId: _selectedCard!.id,
                                ecommerceEnabled: val,
                              ),
                            );
                            await _refreshCurrentCardSecurityOptions(selectedCardLabel);
                          },
                        ),

                        const SizedBox(height: 12),
                        _buildPaymentToggleRow(
                          icon: Icons.point_of_sale_outlined,
                          label: "TPE Payments",
                          value: tpeMap[selectedCardLabel] ?? true,
                          onChanged: (val) async {
                            if (_selectedCard == null) return;

                            final service = SecurityOptionsService();
                            await service.updateCardSecurityOptions(
                              UpdateSecurityOptionRequest(
                                cardId: _selectedCard!.id,
                                tpeEnabled: val,
                              ),
                            );
                            await _refreshCurrentCardSecurityOptions(selectedCardLabel);
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
              unreadCount: _unreadCount,
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

    final currentPath = GoRouterState.of(context).uri.toString();

    // 🔄 Refresh toggle state only when on the '/home' route
    if (currentPath == '/home') {
      Future.delayed(const Duration(milliseconds: 200), () {
        _refreshCurrentCardSecurityOptions(selectedCardLabel);
      });
    }

    // 🎉 Show welcome toast once
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

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

    // 📢 Optional toast (e.g., password change confirmation)
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
    _fetchUnreadCount();
    // 🔁 Start unread count auto-refresh every 3 seconds
    _unreadCountRefreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchUnreadCount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentCardSecurityOptions();
    });

    // ✅ Start auto-refresh every 5 seconds
    _securityRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshCurrentCardSecurityOptions();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final service = EventService();
      final count = await service.fetchUnreadEventCount();
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      print("❌ Failed to fetch unread count: $e");
    }
  }

  @override
  void dispose() {
    _securityRefreshTimer?.cancel();
    _unreadCountRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentCardSecurityOptions(); // refresh values from backend
      _fetchUnreadCount();
    }
  }


  Future<void> _refreshCurrentCardSecurityOptions([String? label]) async {
    final service = SecurityOptionsService();
    try {
      final cardLabel = label ?? selectedCardLabel;

      print("🔄 Refreshing security options for: $cardLabel");

      final options = await service.fetchCardSecurityOptions();

      for (var opt in options) {
        print("🔍 Found: ${opt.label} => contactless: ${opt.contactlessEnabled}, ecommerce: ${opt.ecommerceEnabled}, tpe: ${opt.tpeEnabled}");
      }

      final current = options.firstWhere(
            (e) => e.label == cardLabel,
        orElse: () => CardSecurityOptionsModel(
          label: cardLabel,
          contactlessEnabled: true,
          ecommerceEnabled: true,
          tpeEnabled: true,
          username: '',
          cardholderName: '',
        ),
      );

      setState(() {
        contactlessMap[cardLabel] = current.contactlessEnabled;
        ecommerceMap[cardLabel] = current.ecommerceEnabled;
        tpeMap[cardLabel] = current.tpeEnabled;
      });

      print("✅ Updated local maps: contactless=${contactlessMap[cardLabel]}, ecommerce=${ecommerceMap[cardLabel]}, tpe=${tpeMap[cardLabel]}");

    } catch (e) {
      print("❌ Failed to refresh toggles: $e");
    }
  }

}
