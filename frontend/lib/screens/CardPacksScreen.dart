import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardPacksScreen extends StatefulWidget {
  const CardPacksScreen({Key? key}) : super(key: key);

  @override
  State<CardPacksScreen> createState() => _CardPacksScreenState();
}
class _CardPacksScreenState extends State<CardPacksScreen> {
  String selectedFilter = 'Virtual';

  Widget _buildFrontCard(String packName) {
    final gradient = _getCardGradient(packName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40), // Ultra-rounded corner
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(40),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            packName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/visa_logo.png',
                          width: 50,
                          height: 50,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '1234 5678 9012 3456',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CARDHOLDER',
                                style: TextStyle(fontSize: 10, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('Nada S. Rhandor',
                                style: TextStyle(fontSize: 13.5, color: Colors.white)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('EXPIRES',
                                style: TextStyle(fontSize: 10, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('08/26',
                                style: TextStyle(fontSize: 13.5, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(String packName) {
    if (packName.contains('Gold')) {
      return const LinearGradient(
        colors: [
          Color(0xFFB6862C), // deep brushed gold
          Color(0xFFD4AF37), // classic gold
          Color(0xFF8D6E28), // antique bronze shadow
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('Premium')) {
      return const LinearGradient(
        colors: [
          Color(0xFF4A148C), // deep royal purple
          Color(0xFF7B1FA2), // elegant violet
          Color(0xFFCE93D8), // soft shimmer
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('Platinum')) {
      return const LinearGradient(
        colors: [
          Color(0xFFB0BEC5), // cool steel silver
          Color(0xFFCFD8DC), // light chrome
          Color(0xFFECEFF1), // platinum finish
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('Youth')) {
      return const LinearGradient(
        colors: [
          Color(0xFF1E88E5), // bold student blue
          Color(0xFF1565C0), // focus blue
          Color(0xFF0D47A1), // dark academic blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('Business')) {
      return const LinearGradient(
        colors: [
          Color(0xFF004D40), // deep teal executive
          Color(0xFF00796B), // focused teal
          Color(0xFF26A69A), // professional highlight
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('Classic')) {
      return const LinearGradient(
        colors: [
          Color(0xFF455A64), // strong slate
          Color(0xFF607D8B), // graphite grey
          Color(0xFF78909C), // neutral tone
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (packName.contains('International')) {
      return const LinearGradient(
        colors: [
          Color(0xFF01579B), // dark jet blue
          Color(0xFF0277BD), // primary travel blue
          Color(0xFF4FC3F7), // clean cyan light
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // Default (for fallback)
    return const LinearGradient(
      colors: [
        Color(0xFF1565C0),
        Color(0xFF42A5F5),
        Color(0xFF64B5F6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final virtualPacks = {
      'Virtual Standard': {
        'label': 'Virtual Standard',
        'onlineYearlyLimit': 60000,
        'validityYears': 2,
        'ecommerceEnabled': true,
        'yearlyFee': 0,
        'audience': 'All clients',
        'cardType': 'Visa Virtual',
        'limit': '60,000 Dhs/year',
        'validity': '2 years',
        'fee': '0 DH/year',
      },
      'Virtual Plus': {
        'label': 'Virtual Plus',
        'onlineYearlyLimit': 120000,
        'validityYears': 3,
        'ecommerceEnabled': true,
        'yearlyFee': 50,
        'audience': 'Active clients',
        'cardType': 'Visa Virtual',
        'limit': '120,000 Dhs/year',
        'validity': '3 years',
        'fee': '50 DH/year',
      },
      'Virtual Premium': {
        'label': 'Virtual Premium',
        'onlineYearlyLimit': 240000,
        'validityYears': 3,
        'ecommerceEnabled': true,
        'yearlyFee': 150,
        'audience': 'Premium clients',
        'cardType': 'Visa Virtual',
        'limit': '240,000 Dhs/year',
        'validity': '3 years',
        'fee': '150 DH/year',
      },
      'Virtual Business': {
        'label': 'Virtual Business',
        'onlineYearlyLimit': 600000,
        'validityYears': 4,
        'ecommerceEnabled': true,
        'yearlyFee': 300,
        'audience': 'Business users',
        'cardType': 'Visa Virtual',
        'limit': '600,000 Dhs/year',
        'validity': '4 years',
        'fee': '300 DH/year',
      },
    };

    final physicalPacks = {
      'Visa Youth': {
        'label': 'Visa Youth',
        'withdrawDaily': 500,
        'paymentMonthly': 2000,
        'onlineYearly': 1000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 2,
        'hasDeferred': true,
        'yearlyFee': 0,
        'audience': 'Étudiants de moins de 26 ans',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 3,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 3000,
        'limit': 'Online: 1,000 Dhs/year\nWithdraw: 500 Dhs/day\nPayment: 2,000 Dhs/month',
        'validity': '2 years',
        'fee': '0 DH/year',
      },
      'Visa Classic': {
        'label': 'Visa Classic',
        'withdrawDaily': 2000,
        'paymentMonthly': 8000,
        'onlineYearly': 3000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 3,
        'hasDeferred': true,
        'yearlyFee': 80,
        'audience': 'Tous clients majeurs',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 5,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 8000,
        'limit': 'Online: 3,000 Dhs/year\nWithdraw: 2,000 Dhs/day\nPayment: 8,000 Dhs/month',
        'validity': '3 years',
        'fee': '80 DH/year',
      },
      'Visa Gold': {
        'label': 'Visa Gold',
        'withdrawDaily': 5000,
        'paymentMonthly': 15000,
        'onlineYearly': 10000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 3,
        'hasDeferred': true,
        'yearlyFee': 300,
        'audience': 'Clients Premium',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 10,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 12000,
        'limit': 'Online: 10,000 Dhs/year\nWithdraw: 5,000 Dhs/day\nPayment: 15,000 Dhs/month',
        'validity': '3 years',
        'fee': '300 DH/year',
      },
      'Visa Business': {
        'label': 'Visa Business',
        'withdrawDaily': 8000,
        'paymentMonthly': 25000,
        'onlineYearly': 15000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 4,
        'hasDeferred': true,
        'yearlyFee': 400,
        'audience': 'Entrepreneurs et sociétés',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 15,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 18000,
        'limit': 'Online: 15,000 Dhs/year\nWithdraw: 8,000 Dhs/day\nPayment: 25,000 Dhs/month',
        'validity': '4 years',
        'fee': '400 DH/year',
      },
      'Visa Premium+': {
        'label': 'Visa Premium+',
        'withdrawDaily': 10000,
        'paymentMonthly': 40000,
        'onlineYearly': 30000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 5,
        'hasDeferred': true,
        'yearlyFee': 600,
        'audience': 'Clients haut de gamme',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 20,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 25000,
        'limit': 'Online: 30,000 Dhs/year\nWithdraw: 10,000 Dhs/day\nPayment: 40,000 Dhs/month',
        'validity': '5 years',
        'fee': '600 DH/year',
      },
      'Visa International': {
        'label': 'Visa International',
        'withdrawDaily': 6000,
        'paymentMonthly': 20000,
        'onlineYearly': 12000,
        'ecommerceEnabled': true,
        'contactless': true,
        'validityYears': 4,
        'hasDeferred': true,
        'yearlyFee': 250,
        'audience': 'Voyageurs et expatriés',
        'internationalWithdraw': true,
        'cardType': 'Visa',
        'travelCountriesIncluded': 15,
        'maxTravelDays': 90,
        'internationalWithdrawLimitPerTravel': 15000,
        'limit': 'Online: 12,000 Dhs/year\nWithdraw: 6,000 Dhs/day\nPayment: 20,000 Dhs/month',
        'validity': '4 years',
        'fee': '250 DH/year',
      },
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F2FA), Color(0xFFEDEBFA), Color(0xFFFFF0F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                // 🔙 Header with sleek back button
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.black12,
                      highlightColor: Colors.black12,
                      onTap: () => context.go('/menu'),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 26,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Card Packs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42), // To balance the back button width
                  ],
                ),
                const SizedBox(height: 24),

                // 🔥 Filter buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterButton('Virtual'),
                    const SizedBox(width: 12),
                    _buildFilterButton('Physical'),
                  ],
                ),
                const SizedBox(height: 24),

                // 👇 Dynamic list: Virtual or Physical cards
                if (selectedFilter == 'Virtual') ...[
                  ...virtualPacks.entries
                      .map((e) => buildDetailedPackCard(context, e.value))
                      .toList(),
                ] else ...[
                  ...physicalPacks.entries
                      .map((e) => buildDetailedPackCard(context, e.value))
                      .toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  IconData _getIconForLabel(String key) {
    return _labelIconMap[key] ?? Icons.info_outline;
  }
  Widget _buildFilterButton(String type) {
    final isSelected = selectedFilter == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(50), // Ultra-pill
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFD1D1D6),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF007AFF).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: isSelected ? Colors.white : const Color(0xFF1C1C1E), // iOS black
          ),
          child: Text(type),
        ),
      ),
    );
  }
  Color _getIconColor(String key) {
    if (key.contains('Limit') || key.contains('limit')) {
      return Colors.orange;
    } else if (key.contains('Fee') || key.contains('fee')) {
      return Colors.green;
    } else if (key.contains('Years') || key.contains('validity')) {
      return Colors.purple;
    } else if (key.contains('Withdraw') || key.contains('Payment')) {
      return Colors.teal;
    } else if (key.contains('ecommerce') || key.contains('contactless')) {
      return Colors.pinkAccent;
    } else {
      return Colors.blueAccent;
    }
  }
  Widget _buildBlurredInfoItemPro({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.5, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prettifyLabel(label),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                  ),
                ),

                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  final Map<String, IconData> _labelIconMap = {
    // 🟦 Common (Physical + Virtual)
    'label': Icons.credit_card_rounded,
    'validityYears': Icons.event_rounded,
    'ecommerceEnabled': Icons.shopping_cart_rounded,
    'yearlyFee': Icons.monetization_on_rounded,
    'audience': Icons.people_alt_rounded,
    'cardType': Icons.card_membership_rounded,

    // 🟧 Physical cards
    'withdrawDaily': Icons.local_atm_rounded,
    'paymentMonthly': Icons.credit_score_rounded,
    'onlineYearly': Icons.public_rounded,
    'hasDeferred': Icons.timelapse_rounded,
    'contactless': Icons.nfc_rounded,
    'internationalWithdraw': Icons.flight_takeoff_rounded,
    'internationalWithdrawLimitPerTravel': Icons.swap_vertical_circle_rounded,

    // 🟩 Virtual cards
    'onlineYearlyLimit': Icons.wifi_rounded,
  };
  Widget buildDetailedPackCard(BuildContext context, Map<String, dynamic> pack) {
    final details = pack.entries
        .where((e) => e.key != 'label' && e.key != 'audience' && e.key != 'fee')
        .toList();

    List<Widget> rows = [];
    for (int i = 0; i < details.length; i += 2) {
      final first = details[i];
      final second = (i + 1 < details.length) ? details[i + 1] : null;

      rows.add(Row(
        children: [
          Expanded(
            child: _buildBlurredInfoItemPro(
              icon: _getIconForLabel(first.key),
              iconColor: _getIconColor(first.key),
              label: _prettifyLabel(first.key),
              value: '${first.value}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: second != null
                ? _buildBlurredInfoItemPro(
              icon: Icons.info_outline,
              iconColor: Colors.blueAccent,
              label: _prettifyLabel(second.key),
              value: '${second.value}',
            )
                : const SizedBox(), // empty to fill the space
          ),
        ],
      ));
      rows.add(const SizedBox(height: 16)); // spacing between rows
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFrontCard(pack['label'] ?? 'Card'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    pack['label'] ?? '',
                    style: const TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: Color(0xFF1B1B1F),
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF2F2F7), Color(0xFFECECEE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${pack['fee'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C3C43),
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (pack['audience'] != null)
              Text(
                pack['audience'],
                style: const TextStyle(
                  fontSize: 13.4,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
                  color: Color(0xFF8E8E93),
                ),
              ),
            const SizedBox(height: 24),

            /// 🔽 2 columns grid-style details
            ...rows,
          ],
        ),
      ),
    );
  }
  String _prettifyLabel(String rawLabel) {
    return rawLabel
        .replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll('  ', ' ')
        .toUpperCase();
  }

}