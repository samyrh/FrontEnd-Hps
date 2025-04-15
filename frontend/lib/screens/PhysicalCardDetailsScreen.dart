import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/LimitSlider.dart';
import '../widgets/UltraSwitch.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class PhysicalCardDetailsScreen extends StatefulWidget {
  const PhysicalCardDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PhysicalCardDetailsScreen> createState() => _PhysicalCardDetailsScreenState();
}

class _PhysicalCardDetailsScreenState extends State<PhysicalCardDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  bool showPinPopup = false;
  int countdown = 5;
  bool isCvvRevealed = false;

  final TextEditingController _cvvController = TextEditingController(
      text: '•••');
  final TextEditingController _pinController = TextEditingController(
      text: '••••');

  DropdownItem? selectedLimitType;
  DropdownItem? blockReason;

  final ScrollController _scrollController = ScrollController(); // << ADDED

  final List<DropdownItem> limitTypes = [
    DropdownItem(label: 'Daily Spending Limit', icon: Icons.calendar_today),
    DropdownItem(label: 'Monthly Spending Cap', icon: Icons.date_range),
    DropdownItem(label: 'Online Purchase Restriction',
        icon: Icons.shopping_cart_outlined),
  ];

  final List<DropdownItem> blockReasons = [
    DropdownItem(
        label: 'Card Lost – Cannot Find It', icon: Icons.report_gmailerrorred),
    DropdownItem(
        label: 'Card Stolen – Unauthorized Use', icon: Icons.lock_person),
    DropdownItem(label: 'Card Damaged – Not Functional',
        icon: Icons.settings_backup_restore),
  ];

  double selectedLimit = 500;
  bool isBlocked = false;

  final Gradient cardGradient = const LinearGradient(
    colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

  void _revealPINPopup() {
    setState(() {
      showPinPopup = true;
      countdown = 5;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        countdown--;
        if (countdown == 0) {
          showPinPopup = false;
          timer.cancel();
        }
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
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
            child: Icon(
              suffixIcon ?? Icons.remove_red_eye_outlined,
              color: Colors.grey.shade700,
            ),
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
        _buildSectionTitle("Cardholder Info"),
        _buildInput("Name", TextEditingController(text: "Nada S. Rhandor"),
            Icons.person),
        _buildInput(
            "Card Number", TextEditingController(text: "1234 5678 9012 3456"),
            Icons.credit_card),
        _buildInput("Expiry Date", TextEditingController(text: "08/26"),
            Icons.calendar_today),
        _buildInput("CVV", _cvvController, Icons.lock_outline,
            isObscured: false,
            onTapSuffix: _revealCVV,
            suffixIcon: isCvvRevealed ? Icons.visibility_off_outlined : Icons
                .remove_red_eye_outlined),
        _buildInput("PIN", _pinController, Icons.key,
            isObscured: true, onTapSuffix: _revealPINPopup),
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
              _scrollToBottom(); // << ADDED
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

  Widget _buildBlockCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Block Card"),
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
                Icon(Icons.lock_rounded, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Block this card",
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
                UltraSwitch(
                  value: isBlocked,
                  onChanged: (val) {
                    setState(() => isBlocked = val);
                    if (val) _scrollToBottom(); // << ADDED
                  },
                  activeColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isBlocked
              ? buildLabeledField(
            "Reason for Blocking",
            CustomDropdown(
              key: ValueKey(blockReason?.label ?? 'none'),
              icon: Icons.warning_amber_rounded,
              selectedItem: blockReason,
              items: blockReasons,
              onChanged: (value) => setState(() => blockReason = value),
              label: '',
            ),
          )
              : const SizedBox.shrink(key: ValueKey("empty")),
        ),
      ],
    );
  }

  // Card UI widgets
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
              children: [
                const Text('My Physical Card',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Image.asset('assets/visa_logo.png', width: 50, height: 50),
              ],
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1234 5678 9012',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                )
              ],
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
                  child: const Text('527',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Signature',
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
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, 12))
        ],
      ),
      child: child,
    );
  }

  Widget _buildPinPopup() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: AnimatedScale(
              scale: showPinPopup ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 4)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Your PIN",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70)),
                    const SizedBox(height: 14),
                    const Text("9241",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(color: Colors.white24, blurRadius: 6),
                            Shadow(color: Colors.black45, offset: Offset(0, 1)),
                          ],
                        )),
                    const SizedBox(height: 16),
                    Text("This will close in $countdown sec",
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  @override
  void dispose() {
    _controller.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _scrollController.dispose(); // << Dispose controller
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
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 16),
            children: [
              _buildCard(),
              _buildInfoSection(),
              _buildLimitSection(),
              _buildBlockCardSection(),
              const SizedBox(height: 40),
            ],
          ),
          if (showPinPopup) _buildPinPopup(),
        ],
      ),
    );
  }


}