import 'package:flutter/material.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/LimitSlider.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/Toast.dart';
class CardPackSpec {
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

  const CardPackSpec({
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

  final List<DropdownItem> cardColors = [
    DropdownItem(label: 'Visa Youth', icon: Icons.school_rounded),
    DropdownItem(label: 'Visa Classic', icon: Icons.credit_card_rounded),
    DropdownItem(label: 'Visa Gold', icon: Icons.workspace_premium_rounded),
    DropdownItem(label: 'Visa Business', icon: Icons.business_center_rounded),
    DropdownItem(label: 'Visa Premium+', icon: Icons.stars_rounded),
    DropdownItem(label: 'Visa International', icon: Icons.public_rounded),
  ];
  final Map<String, CardPackSpec> cardPackSpecs = {
    'Visa Youth': CardPackSpec(
      label: 'Visa Youth',
      withdrawDaily: 500,
      paymentMonthly: 2000,
      onlineYearly: 1000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 2,
      hasDeferred: false,
      yearlyFee: 0,
      audience: 'Étudiants de moins de 26 ans',
      internationalWithdraw: false,
      cardType: 'Visa',
    ),
    'Visa Classic': CardPackSpec(
      label: 'Visa Classic',
      withdrawDaily: 2000,
      paymentMonthly: 8000,
      onlineYearly: 3000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 3,
      hasDeferred: false,
      yearlyFee: 80,
      audience: 'Tous clients majeurs',
      internationalWithdraw: true,
      cardType: 'Visa',
    ),
    'Visa Gold': CardPackSpec(
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
    ),
    'Visa Business': CardPackSpec(
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
    ),
    'Visa Premium+': CardPackSpec(
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
    ),
    'Visa International': CardPackSpec(
      label: 'Visa International',
      withdrawDaily: 6000,
      paymentMonthly: 20000,
      onlineYearly: 12000,
      ecommerceEnabled: true,
      contactless: true,
      validityYears: 4,
      hasDeferred: false,
      yearlyFee: 250,
      audience: 'Voyageurs et expatriés',
      internationalWithdraw: true,
      cardType: 'Visa',
    ),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showCardPackDetails(CardPackSpec pack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 60), // keep it centered nicely
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
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
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pack.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C1C1E),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                children: [
                  _iosInfoRow("💸", "Retrait", "${pack.withdrawDaily} Dhs / Jour"),
                  _iosInfoRow("🛍️", "Paiement", "${pack.paymentMonthly} Dhs / Mois"),
                  _iosInfoRow("🌐", "Paiement en ligne", "${pack.onlineYearly} Dhs / An"),
                  _iosInfoRow("🛒", "E-commerce", pack.ecommerceEnabled ? "Activé" : "Non"),
                  _iosInfoRow("📶", "Sans contact", pack.contactless ? "Oui" : "Non"),
                  _iosInfoRow("📅", "Durée", "${pack.validityYears} ans"),
                  _iosInfoRow("⏳", "Différé", pack.hasDeferred ? "Oui" : "Non"),
                  _iosInfoRow("💳", "Tarif", "${pack.yearlyFee} Dhs / An"),
                  _iosInfoRow("👥", "Public cible", pack.audience),
                  _iosInfoRow("🌍", "Retrait international", pack.internationalWithdraw ? "Oui" : "Non"),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 6,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Choisir ce pack',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iosInfoRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 24, // slightly larger emoji
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8E8E93),
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
  }) {
    return buildLabeledField(
      label,
      CustomDropdown(
        icon: icon,
        selectedItem: selected,
        items: items,
        onChanged: onChanged,
        label: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Add New Card ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1E1E2D), fontFamily: 'Inter'),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            height: 220, // ⬅️ Bigger, balanced size
                            width: double.infinity,
                            child: Image.asset(
                              'assets/add_card.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // ✅ Inputs
                      _buildInfoSection(),

                      _buildDropdown(
                        label: "Pack of Card",
                        selected: selectedCardColor,
                        items: cardColors,
                        onChanged: (value) {
                          setState(() => selectedCardColor = value);
                          final selectedSpec = cardPackSpecs[value!.label]!;
                          _showCardPackDetails(selectedSpec);
                        },
                        icon: Icons.card_membership,
                      ),

                      _buildDropdown(
                        label: "Card Type",
                        selected: selectedCardType,
                        items: cardTypes,
                        onChanged: (value) {
                          if (selectedCardColor == null) {
                            showCupertinoGlassToast(
                              context,
                              "Please select a card pack before choosing a card type.",
                              isSuccess: false,
                              position: ToastPosition.top,
                            );

                          } else {
                            setState(() => selectedCardType = value);
                          }
                        },
                        icon: Icons.credit_card,
                      ),

                      const Spacer(), // pushes button to bottom if space allows

                      // ✅ Continue Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              'Continue',
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
          },
        ),
      ),

    );
  }
}

// Bullet detail component
class _DetailBullet extends StatelessWidget {
  final String text;
  const _DetailBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF007AFF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}