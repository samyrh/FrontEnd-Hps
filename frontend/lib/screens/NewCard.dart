import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/LimitSlider.dart';
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
      travelCountriesIncluded: 3, // ✅ Only 3 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 3000,
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
      travelCountriesIncluded: 5, // ✅ 5 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 8000,
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
      travelCountriesIncluded: 10, // ✅ 10 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 12000,
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
      travelCountriesIncluded: 15, // ✅ 15 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 18000,
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
      travelCountriesIncluded: 20, // ✅ 20 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 25000,
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
      travelCountriesIncluded: 15, // ✅ 15 countries
      maxTravelDays: 90,
      internationalWithdrawLimitPerTravel: 15000,
    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(String label, String value, IconData icon) {
    return buildLabeledField(
      label,
      TextFormField(
        initialValue: value,
        enabled: false,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade700, size: 20),
          filled: true,
          fillColor: const Color(0xFFE5E5EA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput("Full Name", "Nada S. Rhandor", Icons.person),
        _buildInput("Phone Number", "+212790123456", Icons.phone),
        _buildInput("Email Address", "samiNada@gmail.com", Icons.email),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🎨 Background
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

          // 🧊 Frosted Glass Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // 📜 Content
          Padding(
            padding: EdgeInsets.only(top: topPadding + kToolbarHeight + 16, bottom: 20),
            child: Column(
              children: [
                // ✅ Big Image (Fixed Size)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: SizedBox(
                    height: screenWidth > 400 ? 200 : 180,  // ✨ Stays big
                    width: double.infinity,
                    child: Image.asset(
                      'assets/add_card.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Middle Part Flexible (shrinks first if needed)
                Flexible(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
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
                              selectedCardColor = null; // ✅ reset selected pack
                            });
                          },
                          icon: Icons.credit_card,
                        ),
                        _buildDropdown(
                          label: "Pack of Card",
                          selected: selectedCardColor,
                          items: selectedCardType == null
                              ? []  // Empty list if no type selected
                              : (selectedCardType!.label == 'Physical Card' ? physicalCardPacks : virtualCardPacks),
                          onChanged: (value) {
                            if (selectedCardType == null) {
                              // Should never happen, but extra security
                              showCupertinoGlassToast(
                                context,
                                "Please select a card type first before choosing the card pack.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            } else {
                              setState(() => selectedCardColor = value);

                              if (selectedCardType!.label == 'Physical Card') {
                                final selectedSpec = physicalCardSpecsPacks[value!.label]!;
                                _showPhysicalCardPackDetails(selectedSpec);
                              } else if (selectedCardType!.label == 'Virtual Card') {
                                final selectedSpec = virtualCardSpecsPacks[value!.label]!;
                                _showVirtualCardPackDetails(selectedSpec);
                              }
                            }
                          },
                          icon: Icons.card_membership,
                          enabled: selectedCardType != null, // ✅ DISABLE if CardType is null
                        ),





                      ],
                    ),
                  ),
                ),

                // ✅ Continue Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedCardColor == null || selectedCardType == null)
                          ? null
                          : () {
                        // TODO: next step
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
                ),
              ],
            ),
          ),

          // 🧭 Header
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BackButton(color: Colors.black),
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
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
