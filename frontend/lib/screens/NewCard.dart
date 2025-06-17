import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hps_direct/services/auth/auth_service.dart';
import '../widgets/CustomDropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

//test
import '../widgets/Toast.dart';

class PhysicalCardSpecsPack {
  final String label;
  final int withdrawDaily;
  final int paymentMonthly;
  final int onlineYearly;
  final bool ecommerceEnabled;
  final bool contactless;
  final int validityYears;
  final bool hasDeferred;
  final int yearlyFee;
  final String audience;
  final bool internationalWithdraw;
  final String cardType;
  final int internationalWithdrawLimitPerTravel;

  /// 🔥 Only for Physical Cards
  final int travelCountriesIncluded;

  /// 🔥 Only for Physical Cards
  final int maxTravelDays;

  const PhysicalCardSpecsPack({
    required this.label,
    required this.withdrawDaily,
    required this.paymentMonthly,
    required this.onlineYearly,
    required this.ecommerceEnabled,
    required this.contactless,
    required this.validityYears,
    required this.hasDeferred,
    required this.yearlyFee,
    required this.audience,
    required this.internationalWithdraw,
    required this.cardType,
    required this.travelCountriesIncluded,
    required this.maxTravelDays,
    required this.internationalWithdrawLimitPerTravel,
  });
}

class VirtualCardSpecsPack {
  final String label;
  final int onlineYearlyLimit; // ✅ Corrected
  final int validityYears;
  final bool ecommerceEnabled;
  final int yearlyFee;
  final String audience;
  final String cardType;

  const VirtualCardSpecsPack({
    required this.label,
    required this.onlineYearlyLimit,
    required this.validityYears,
    required this.ecommerceEnabled,
    required this.yearlyFee,
    required this.audience,
    required this.cardType,
  });
}




class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> {
  DropdownItem? selectedLimitType;
  DropdownItem? selectedCardType;
  DropdownItem? selectedCardColor;

  final ScrollController _scrollController = ScrollController();
  double selectedLimit = 500;
  String? fullName;
  String? email;
  bool isEditing = false;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: "+212790123456");

  final List<DropdownItem> cardTypes = [
    DropdownItem(label: 'Physical Card', icon: Icons.credit_card),
    DropdownItem(label: 'Virtual Card', icon: Icons.credit_card_outlined),
  ];

  final List<DropdownItem> physicalCardPacks = [
    DropdownItem(label: 'Visa Youth', icon: Icons.school_rounded),
    DropdownItem(label: 'Visa Classic', icon: Icons.credit_card_rounded),
    DropdownItem(label: 'Visa Gold', icon: Icons.workspace_premium_rounded),
    DropdownItem(label: 'Visa Business', icon: Icons.business_center_rounded),
    DropdownItem(label: 'Visa Premium+', icon: Icons.stars_rounded),
    DropdownItem(label: 'Visa International', icon: Icons.public_rounded),
  ];

  final List<DropdownItem> virtualCardPacks = [
    DropdownItem(label: 'Virtual Standard', icon: Icons.credit_card_outlined),
    DropdownItem(label: 'Virtual Plus', icon: Icons.credit_card_outlined),
    DropdownItem(label: 'Virtual Premium', icon: Icons.workspace_premium_outlined),
    DropdownItem(label: 'Virtual Business', icon: Icons.business_center_outlined),
  ];

  final Map<String, VirtualCardSpecsPack> virtualCardSpecsPacks = {
    'Virtual Standard': VirtualCardSpecsPack(
      label: 'Virtual Standard',
      onlineYearlyLimit: 60000, // ✅ 5,000 Dhs * 12 months
      validityYears: 2,
      ecommerceEnabled: true,
      yearlyFee: 0,
      audience: 'All clients',
      cardType: 'Visa Virtual',
    ),
    'Virtual Plus': VirtualCardSpecsPack(
      label: 'Virtual Plus',
      onlineYearlyLimit: 120000, // ✅ 10,000 Dhs * 12 months
      validityYears: 3,
      ecommerceEnabled: true,
      yearlyFee: 50,
      audience: 'Active clients',
      cardType: 'Visa Virtual',
    ),
    'Virtual Premium': VirtualCardSpecsPack(
      label: 'Virtual Premium',
      onlineYearlyLimit: 240000, // ✅ 20,000 Dhs * 12 months
      validityYears: 3,
      ecommerceEnabled: true,
      yearlyFee: 150,
      audience: 'Premium clients',
      cardType: 'Visa Virtual',
    ),
    'Virtual Business': VirtualCardSpecsPack(
      label: 'Virtual Business',
      onlineYearlyLimit: 600000, // ✅ 50,000 Dhs * 12 months
      validityYears: 4,
      ecommerceEnabled: true,
      yearlyFee: 300,
      audience: 'Business users',
      cardType: 'Visa Virtual',
    ),
  };


  final Map<String, PhysicalCardSpecsPack> physicalCardSpecsPacks = {
    'Visa Youth': PhysicalCardSpecsPack(
      label: 'Visa Youth',
      withdrawDaily: 500,
      paymentMonthly: 2000,
      onlineYearly: 1000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 2,
      hasDeferred: true,
      yearlyFee: 0,
      audience: 'Étudiants de moins de 26 ans',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 3,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 6000,  // ✅ updated
    ),
    'Visa Classic': PhysicalCardSpecsPack(
      label: 'Visa Classic',
      withdrawDaily: 2000,
      paymentMonthly: 8000,
      onlineYearly: 3000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 3,
      hasDeferred: true,
      yearlyFee: 80,
      audience: 'Tous clients majeurs',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 5,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 15000,  // ✅ updated
    ),
    'Visa Gold': PhysicalCardSpecsPack(
      label: 'Visa Gold',
      withdrawDaily: 5000,
      paymentMonthly: 15000,
      onlineYearly: 10000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 3,
      hasDeferred: true,
      yearlyFee: 300,
      audience: 'Clients Premium',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 10,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 30000,  // ✅ updated
    ),
    'Visa Business': PhysicalCardSpecsPack(
      label: 'Visa Business',
      withdrawDaily: 8000,
      paymentMonthly: 25000,
      onlineYearly: 15000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 4,
      hasDeferred: true,
      yearlyFee: 400,
      audience: 'Entrepreneurs et sociétés',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 15,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 60000,  // ✅ updated
    ),
    'Visa Premium+': PhysicalCardSpecsPack(
      label: 'Visa Premium+',
      withdrawDaily: 10000,
      paymentMonthly: 40000,
      onlineYearly: 30000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 5,
      hasDeferred: true,
      yearlyFee: 600,
      audience: 'Clients haut de gamme',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 20,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 80000,  // ✅ updated
    ),
    'Visa International': PhysicalCardSpecsPack(
      label: 'Visa International',
      withdrawDaily: 6000,
      paymentMonthly: 20000,
      onlineYearly: 12000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 4,
      hasDeferred: true,
      yearlyFee: 250,
      audience: 'Voyageurs et expatriés',
      internationalWithdraw: true,
      cardType: 'Visa',
      travelCountriesIncluded: 15,
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 150000,  // ✅ updated
    ),
  };

  final Map<String, List<Gradient>> physicalCardColors = {
    'Visa Youth': [
      LinearGradient(colors: [Color(0xFFB7F8DB), Color(0xFF50A7C2)]),
      LinearGradient(colors: [Color(0xFFFCE38A), Color(0xFFF38181)]),
      LinearGradient(colors: [Color(0xFFFC5C7D), Color(0xFF6A82FB)]),
      LinearGradient(colors: [Color(0xFF12FFF7), Color(0xFFB6EADA)]),
      LinearGradient(colors: [Color(0xFFE6DADA), Color(0xFF274046)]),
    ],
    'Visa Classic': [
      LinearGradient(colors: [Color(0xFFFFAFBD), Color(0xFFFFC3A0)]),
      LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
      LinearGradient(colors: [Color(0xFFFBAB7E), Color(0xFFF7CE68)]),
      LinearGradient(colors: [Color(0xFF5D4157), Color(0xFFA8CABA)]),
      LinearGradient(colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)]),
    ],
    'Visa Gold': [
      LinearGradient(colors: [Color(0xFFFFD200), Color(0xFFFFA700)]),
      LinearGradient(colors: [Color(0xFFF7971E), Color(0xFFFFD200)]),
      LinearGradient(colors: [Color(0xFFFFE259), Color(0xFFFFA751)]),
      LinearGradient(colors: [Color(0xFFFCEABB), Color(0xFFF8B500)]),
      LinearGradient(colors: [Color(0xFFFFD89B), Color(0xFF19547B)]),
    ],
    'Visa Business': [
      LinearGradient(colors: [Color(0xFF283E51), Color(0xFF485563)]),
      LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
      LinearGradient(colors: [Color(0xFF4B79A1), Color(0xFF283E51)]),
      LinearGradient(colors: [Color(0xFF536976), Color(0xFF292E49)]),
      LinearGradient(colors: [Color(0xFF606C88), Color(0xFF3F4C6B)]),
    ],
    'Visa Premium+': [
      LinearGradient(colors: [Color(0xFF000000), Color(0xFF434343)]),
      LinearGradient(colors: [Color(0xFF3C3B3F), Color(0xFF605C3C)]),
      LinearGradient(colors: [Color(0xFF141E30), Color(0xFF243B55)]),
      LinearGradient(colors: [Color(0xFF232526), Color(0xFF414345)]),
      LinearGradient(colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)]),
    ],
    'Visa International': [
      LinearGradient(colors: [Color(0xFF43C6AC), Color(0xFF191654)]),
      LinearGradient(colors: [Color(0xFF1A2980), Color(0xFF26D0CE)]),
      LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
      LinearGradient(colors: [Color(0xFF2BC0E4), Color(0xFFEAECC6)]),
      LinearGradient(colors: [Color(0xFF4776E6), Color(0xFF8E54E9)]),
    ],
  };

  final Map<String, List<Gradient>> virtualCardColors = {
    'Virtual Standard': [
      LinearGradient(colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)]),
      LinearGradient(colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)]),
      LinearGradient(colors: [Color(0xFF00b09b), Color(0xFF96c93d)]),
      LinearGradient(colors: [Color(0xFFf857a6), Color(0xFFFF5858)]),
      LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
    ],
    'Virtual Plus': [
      LinearGradient(colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)]),
      LinearGradient(colors: [Color(0xFFe96443), Color(0xFF904e95)]),
      LinearGradient(colors: [Color(0xFF16A085), Color(0xFF2980B9)]),
      LinearGradient(colors: [Color(0xFF614385), Color(0xFF516395)]),
      LinearGradient(colors: [Color(0xFFff6e7f), Color(0xFFbfe9ff)]),
    ],
    'Virtual Premium': [
      LinearGradient(colors: [Color(0xFF43C6AC), Color(0xFFF8FFAE)]),
      LinearGradient(colors: [Color(0xFF614385), Color(0xFF516395)]),
      LinearGradient(colors: [Color(0xFF5A3F37), Color(0xFF2C7744)]),
      LinearGradient(colors: [Color(0xFF1D4350), Color(0xFFA43931)]),
      LinearGradient(colors: [Color(0xFF000428), Color(0xFF004e92)]),
    ],
    'Virtual Business': [
      LinearGradient(colors: [Color(0xFF283E51), Color(0xFF485563)]),
      LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
      LinearGradient(colors: [Color(0xFF373B44), Color(0xFF4286f4)]),
      LinearGradient(colors: [Color(0xFF536976), Color(0xFF292E49)]),
      LinearGradient(colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)]),
    ],
  };


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  void _showPhysicalCardPackDetails(PhysicalCardSpecsPack pack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: const EdgeInsets.only(top: 60),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF7F7F9),
                Color(0xFFF0F0F3),
                Color(0xFFEDEDEF),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 Title
              Text(
                pack.label,
                style: TextStyle(
                  fontSize: constraints.maxWidth > 400 ? 20 : 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 18),

              // 🧊 Info Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  children: [
                    _tinyInfoRow("💸", "Daily Withdraw", "${pack.withdrawDaily} Dhs"),
                    _tinyInfoRow("🛍️", "Monthly Payments", "${pack.paymentMonthly} Dhs"),
                    _tinyInfoRow("🌐", "Online Limit / Year", "${pack.onlineYearly} Dhs"),
                    _tinyInfoRow("🛒", "E-commerce", pack.ecommerceEnabled ? "Yes" : "No"),
                    _tinyInfoRow("📶", "Contactless", pack.contactless ? "Yes" : "No"),
                    _tinyInfoRow("📅", "Validity", "${pack.validityYears} years"),
                    _tinyInfoRow("⏳", "Deferred", pack.hasDeferred ? "Yes" : "No"),
                    _tinyInfoRow("💳", "Fee", "${pack.yearlyFee} Dhs"),
                    _tinyInfoRow("👥", "Audience", pack.audience),
                    _tinyInfoRow("🌍", "Intl Withdrawals", pack.internationalWithdraw ? "Yes" : "No"),
                    _tinyInfoRow("💳", "Type", pack.cardType),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE0E0E0),
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            'Travel Plan',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8E8E93),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE0E0E0),
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _tinyInfoRow("🛫", "Travel Countries", "${pack.travelCountriesIncluded} countries"),
                    _tinyInfoRow("🕒", "Max Days", "${pack.maxTravelDays} days"),
                    _tinyInfoRow("💰", "Limit per Travel Plan", "${pack.internationalWithdrawLimitPerTravel} Dhs"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🖤 Choose Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Select this Pack',
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 400 ? 15 : 13.5,
                      fontWeight: FontWeight.w600,
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


  void _showVirtualCardPackDetails(VirtualCardSpecsPack pack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: const EdgeInsets.only(top: 60),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF7F7F9),
                Color(0xFFF0F0F3),
                Color(0xFFEDEDEF),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 Title
              Text(
                pack.label,
                style: TextStyle(
                  fontSize: constraints.maxWidth > 400 ? 20 : 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 18),

              // 🧊 Info Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  children: [
                    _tinyInfoRow("🌐", "Online Limit / Year", "${pack.onlineYearlyLimit} Dhs"),
                    _tinyInfoRow("🛒", "E-commerce", pack.ecommerceEnabled ? "Yes" : "No"),
                    _tinyInfoRow("📅", "Validity", "${pack.validityYears} years"),
                    _tinyInfoRow("💳", "Fee", "${pack.yearlyFee} Dhs"),
                    _tinyInfoRow("👥", "Audience", pack.audience),
                    _tinyInfoRow("💳", "Type", pack.cardType),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🖤 Choose Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Select this Pack',
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 400 ? 15 : 13.5,
                      fontWeight: FontWeight.w600,
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

  Widget _tinyInfoRow(String emoji, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3A3A3C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabeledField(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity, // ✅ force full width
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon) {
    return buildLabeledField(
      label,
      Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E9), // Matches dropdown background
          borderRadius: BorderRadius.circular(14), // Matches slight rounding
          border: Border.all(
            color: const Color(0xFFCCCCCC), // Soft light border (like dropdown)
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, size: 20, color: const Color(0xFF555555)), // Subtle icon
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: false,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput("Full Name", fullNameController, Icons.person),
        _buildInput("Phone Number", phoneController, Icons.phone),
        _buildInput("Email Address", emailController, Icons.email),
      ],
    );
  }




  Widget _buildDropdown({
    required String label,
    required DropdownItem? selected,
    required List<DropdownItem> items,
    required ValueChanged<DropdownItem?> onChanged,
    required IconData icon,
    bool enabled = true,  // ✅ New param added (default true)
  }) {
    return buildLabeledField(
      label,
      Opacity(
        opacity: enabled ? 1.0 : 0.5, // ✅ Grayed out when disabled
        child: IgnorePointer(
          ignoring: !enabled, // ✅ Disable interaction if not enabled
          child: CustomDropdown(
            icon: icon,
            selectedItem: selected,
            items: items,
            onChanged: onChanged,
            label: '',
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = size.width;

    // Inside build() > return Scaffold(
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🎨 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFD6F2F0),
                  Color(0xFFE3E4F7),
                  Color(0xFFF5F6FA),
                ],
              ),
            ),
          ),

          // 🧊 Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: Container(color: Colors.white.withOpacity(0.08)),
          ),

          // 🧭 Content with Padding
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 🧭 AppBar Row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(), // or context.go('/menu') if needed
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Add New Card',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44), // Spacer to balance the row
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 📸 Image
                      SizedBox(
                        height: screenHeight * 0.2,
                        child: Image.asset(
                          'assets/add_card.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 📄 Form (fills remaining space)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              _buildInfoSection(),

                              _buildDropdown(
                                label: "Card Type",
                                selected: selectedCardType,
                                items: cardTypes,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCardType = value;
                                    selectedCardColor = null;
                                  });
                                },
                                icon: Icons.credit_card,
                              ),

                              _buildDropdown(
                                label: "Pack of Card",
                                selected: selectedCardColor,
                                items: selectedCardType == null
                                    ? []
                                    : (selectedCardType!.label == 'Physical Card'
                                    ? physicalCardPacks
                                    : virtualCardPacks),
                                onChanged: (value) {
                                  if (selectedCardType == null) return;

                                  setState(() => selectedCardColor = value);

                                  if (selectedCardType!.label == 'Physical Card') {
                                    final spec = physicalCardSpecsPacks[value!.label]!;
                                    _showPhysicalCardPackDetails(spec);
                                  } else {
                                    final spec = virtualCardSpecsPacks[value!.label]!;
                                    _showVirtualCardPackDetails(spec);
                                  }
                                },
                                icon: Icons.card_membership,
                                enabled: selectedCardType != null,
                              ),

                              const SizedBox(height: 16),

                              // ✅ Continue Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (selectedCardColor == null || selectedCardType == null)
                                      ? null
                                      : () {
                                    final gradients = selectedCardType!.label == 'Physical Card'
                                        ? physicalCardColors[selectedCardColor!.label]!
                                        : virtualCardColors[selectedCardColor!.label]!;

                                    context.push(
                                      '/choose_color',
                                      extra: {
                                        'gradients': gradients,
                                        'cardType': selectedCardType!.label,
                                        'packName': selectedCardColor!.label,
                                      },
                                    );

                                    showCupertinoGlassToast(
                                      context,
                                      'Awesome! Now choose your card color 🎨.',
                                      isSuccess: true,
                                      position: ToastPosition.top,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: screenWidth > 400 ? 16 : 14.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  }
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }


  Future<void> _loadUserInfo() async {
    final authService = AuthService();
    final userInfo = await authService.loadUserInfo();

    if (userInfo != null) {
      fullNameController.text = userInfo.username;
      emailController.text = userInfo.email;
    }
  }
}
