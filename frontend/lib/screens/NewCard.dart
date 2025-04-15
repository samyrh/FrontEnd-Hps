import 'package:flutter/material.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/LimitSlider.dart';

import 'dart:async';

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

  final List<DropdownItem> limitTypes = [
    DropdownItem(label: 'Daily Spending Limit', icon: Icons.calendar_today),
    DropdownItem(label: 'Monthly Spending Cap', icon: Icons.date_range),
    DropdownItem(label: 'Online Purchase Restriction', icon: Icons.shopping_cart_outlined),
  ];

  final List<DropdownItem> cardTypes = [
    DropdownItem(label: 'Physical Card', icon: Icons.credit_card),
    DropdownItem(label: 'Virtual Card', icon: Icons.credit_card_outlined),
  ];

  final List<DropdownItem> cardColors = [
    DropdownItem(label: 'Basic Pack', icon: Icons.layers_outlined),
    DropdownItem(label: 'Junior Campus', icon: Icons.school_outlined),
    DropdownItem(label: 'Business Pack', icon: Icons.business_center),
    DropdownItem(label: 'Gold Pack', icon: Icons.workspace_premium),
  ];

  double selectedLimit = 500;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1E),
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

  Widget _buildLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Manage Limits"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: CustomDropdown(
            icon: Icons.tune,
            selectedItem: selectedLimitType,
            items: limitTypes,
            onChanged: (value) {
              setState(() => selectedLimitType = value);
              _scrollToBottom();
            },
            label: '',
          ),
        ),
        if (selectedLimitType != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD1D1D6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Spending Limit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        "\$${selectedLimit.toInt()}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _limitColor(selectedLimit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LimitSliderWidget(
                    currentValue: selectedLimit,
                    maxValue: 5000,
                    onChanged: (val) => setState(() => selectedLimit = val),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _limitColor(double value) {
    if (value <= 1000) return const Color(0xFF34C759);
    if (value <= 3000) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E2D),
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 16),
        children: [
          _buildInfoSection(),

          _buildDropdown(
            label: "Card Type",
            selected: selectedCardType,
            items: cardTypes,
            onChanged: (value) => setState(() => selectedCardType = value),
            icon: Icons.credit_card,
          ),

          _buildLimitSection(),

          _buildDropdown(
            label: "Pack of Card",
            selected: selectedCardColor,
            items: cardColors,
            onChanged: (value) => setState(() => selectedCardColor = value),
            icon: Icons.card_membership,
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: SizedBox(
              width: double.infinity,
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
                onPressed: () {},
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
    );
  }
}
