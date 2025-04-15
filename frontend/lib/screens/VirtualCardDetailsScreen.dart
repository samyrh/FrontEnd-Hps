import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/LimitSlider.dart';
import '../widgets/OtpVerificationDialog.dart';
import '../widgets/Toast.dart';
import '../widgets/UltraSwitch.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class VirtualCardDetailsScreen extends StatefulWidget {
  const VirtualCardDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VirtualCardDetailsScreen> createState() => _VirtualCardDetailsScreenState();
}

class _VirtualCardDetailsScreenState extends State<VirtualCardDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  bool isCvvRevealed = false;

  final TextEditingController _cvvController = TextEditingController(
      text: '•••');
  final TextEditingController _pinController = TextEditingController(
      text: '••••');

  DropdownItem? selectedLimitType;

  final ScrollController _scrollController = ScrollController();

  final List<DropdownItem> limitTypes = [
    DropdownItem(label: 'Daily Spending Limit', icon: Icons.calendar_today),
    DropdownItem(label: 'Monthly Spending Cap', icon: Icons.date_range),
    DropdownItem(label: 'Online Purchase Restriction',
        icon: Icons.shopping_cart_outlined),
  ];

  double selectedLimit = 500;
  bool isBlocked = false;

  final Gradient virtualCardGradient = const LinearGradient(
    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Color _limitColor(double value) {
    if (value <= 1000) return const Color(0xFF34C759);
    if (value <= 3000) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  void _revealCVV() {
    if (isCvvRevealed) {
      _cvvController.text = '•••';
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!isFront) _flipCard();
      });
      setState(() => isCvvRevealed = false);
    } else {
      _cvvController.text = '527';
      Future.delayed(const Duration(milliseconds: 300), () {
        if (isFront) _flipCard();
      });
      setState(() => isCvvRevealed = true);

      Timer(const Duration(seconds: 5), () {
        if (mounted && isCvvRevealed) {
          _cvvController.text = '•••';
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!isFront) _flipCard();
          });
          setState(() => isCvvRevealed = false);
        }
      });
    }
  }

  void _showOtpDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => OtpVerificationDialog(
        onConfirmed: (otp) {
          if (otp == '1234') {
            showCupertinoGlassToast(
              context,
              'Your virtual card has been successfully cancelled.',
              isSuccess: true,
              position: ToastPosition.top,
            );
          } else {
            showCupertinoGlassToast(
              context,
              'The OTP you entered is incorrect.',
              isSuccess: false,
              position: ToastPosition.top,
            );
          }
        },
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      IconData icon,
      {bool isObscured = false, VoidCallback? onTapSuffix, IconData? suffixIcon}) {
    return buildLabeledField(
      label,
      TextField(
        controller: controller,
        readOnly: true,
        obscureText: isObscured,
        focusNode: AlwaysDisabledFocusNode(),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade700, size: 20),
          filled: true,
          fillColor: const Color(0xFFE5E5EA),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
          ),
          suffixIcon: onTapSuffix != null
              ? GestureDetector(
            onTap: onTapSuffix,
            child: Icon(suffixIcon ?? Icons.remove_red_eye_outlined,
                color: Colors.grey.shade700),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E)),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Cardholder Info"),
        _buildInput("Name", TextEditingController(text: "Nada S. Rhandor"),
            Icons.person),
        _buildInput(
            "Card Number", TextEditingController(text: "5678 9012 3456 7890"),
            Icons.credit_card),
        _buildInput("Expiry Date", TextEditingController(text: "08/26"),
            Icons.calendar_today),
        _buildInput("CVV", _cvvController, Icons.lock_outline,
            isObscured: false,
            onTapSuffix: _revealCVV,
            suffixIcon: isCvvRevealed ? Icons.visibility_off_outlined : Icons
                .remove_red_eye_outlined),
      ],
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
                      const Text("Spending Limit",
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1C1C1E))),
                      Text(
                        "\$${selectedLimit.toInt()}",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _limitColor(selectedLimit)),
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

  Widget _buildBlockCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Card Status"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1D1D6)),
            ),
            child: Row(
              children: [
                Icon(isBlocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Activate / Deactivate Card",
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ),
                UltraSwitch(
                  value: isBlocked,
                  onChanged: (val) => setState(() => isBlocked = val),
                  activeColor: isBlocked ? Colors.redAccent : Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelCardButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: GestureDetector(
        onTap: _showOtpDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6C6C), // soft coral red
                Color(0xFFDC3545), // Apple-style red with depth
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC3545).withOpacity(0.3),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Cancel This Card',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() =>
      GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final showFront = _animation.value <= pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value),
              child: showFront
                  ? _buildFrontCard()
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateY(pi),
                child: _buildBackCard(),
              ),
            );
          },
        ),
      );

  Widget _buildFrontCard() =>
      _cardContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('My Virtual Card',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Icon(Icons.wifi, color: Colors.white, size: 28),
              ],
            ),
            const Text(
              '5678 9012 3456 7890',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARDHOLDER',
                        style: TextStyle(fontSize: 10, color: Colors.white54)),
                    SizedBox(height: 2),
                    Text('Nada S. Rhandor',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EXPIRES',
                        style: TextStyle(fontSize: 10, color: Colors.white54)),
                    SizedBox(height: 2),
                    Text('08/26',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildBackCard() =>
      _cardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CVV', style: TextStyle(color: Colors.white70)),
                Container(
                  width: 60,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('527', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Virtual Card',
                    style: TextStyle(fontSize: 10, color: Colors.white54)),
                Text('Valid Thru 08/26',
                    style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ],
        ),
      );

  Widget _cardContainer({required Widget child}) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: virtualCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: child,
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


  @override
  void dispose() {
    _controller.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Card Details',
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
          _buildCard(),
          _buildInfoSection(),
          _buildLimitSection(),
          _buildBlockCardSection(),
          _buildCancelCardButton(),
          const SizedBox(height: 40),
        ],
      ),

    );
  }
}
