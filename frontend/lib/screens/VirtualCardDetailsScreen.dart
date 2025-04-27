import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/OtpVerificationDialog.dart';
import '../widgets/Toast.dart';
import '../widgets/UltraSwitch.dart';
import 'package:table_calendar/table_calendar.dart';

//test
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
  bool showPinPopup = false;
  int countdown = 5;
  bool isCvvRevealed = false;
  bool isContactlessEnabled = true;
  bool isEcommerceEnabled = true;
  bool isTpePaymentEnabled = true;
  DateTime? blockStartDate;
  DateTime? blockEndDate;
  bool showRequestCard = false;
  bool isPermanent = false;
  bool showRequestNewCvv = false;
  bool isJustBlockNowConfirmed = false;
  int cvvCountdown = 60;
  Timer? _cvvTimer;
  bool someoneTriedConfirmed = false;
  bool requestSent = false;
  bool isAccountClosureConfirmed = false;
  bool isCardDeleted = false;
  bool isRequestSent = false;
  bool get isCardLocked => isRequestSent;

  final TextEditingController _cvvController = TextEditingController(
      text: '•••');
  final TextEditingController _pinController = TextEditingController(
      text: '••••');

  DropdownItem? selectedLimitType;
  DropdownItem? blockReason;

  final ScrollController _scrollController = ScrollController(); // << ADDED

  Timer? _reasonResetTimer;


  final List<DropdownItem> blockReasons = [
    DropdownItem(label: 'Just Block for Now (Temporary)', icon: Icons.timelapse),
    DropdownItem(label: 'My Card Details Got Leaked (CVV)', icon: Icons.security),
    DropdownItem(label: 'Someone Tried to Use My Card', icon: Icons.warning_amber_rounded),
    DropdownItem(label: 'I’m Closing My Account or Switching', icon: Icons.logout),
  ];


  double selectedLimit = 500;
  bool isBlocked = false;


  final Map<String, double> maxLimitByType = {
    'Online Purchase Limit (Per Year)': 5000, // or whatever you want as max
  };


  final Gradient cardGradient = const LinearGradient(
    colors: [Color(0xFFB6FBFF), Color(0xFF83A4D4)],
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
    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is blocked. Cannot flip to reveal details.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }

    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  void _revealCVV() {
    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is blocked. CVV cannot be revealed.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }

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
    final cardNumber = '1234 5678 9012 3456';
    final maskedCardNumber = isRequestSent
        ? '**** **** *** ${cardNumber.substring(cardNumber.length - 3)}'
        : cardNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Cardholder Info"),
        _buildInput(
          "Name",
          TextEditingController(text: "Nada S. Rhandor"),
          Icons.person,
        ),
        _buildInput(
          "Card Number",
          TextEditingController(text: maskedCardNumber),
          Icons.credit_card,
        ),

        if (!isRequestSent) // ✅ Only show Expiry and CVV if request NOT sent
          _buildInput(
            "Expiry Date",
            TextEditingController(text: '08/26'),
            Icons.calendar_today,
          ),

        if (!isRequestSent)
          _buildInput(
            "CVV",
            _cvvController,
            Icons.lock_outline,
            isObscured: false,
            onTapSuffix: _revealCVV,
            suffixIcon: isCvvRevealed
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
          ),
      ],
    );
  }

  Widget _buildLimitSection() {
    final double maxLimit = 5000; // Max online limit per year

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Online Purchase Limit (Per Year)"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Opacity(opacity: (isBlocked || isCardLocked) ? 0.4 : 1,
            child: IgnorePointer(
              ignoring: (isBlocked || isCardLocked),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD1D1D6)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Set Your Limit",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                              child: Text(
                                "\$${(isBlocked ? 0 : selectedLimit).toInt()}",
                                key: ValueKey<int>((isBlocked ? 0 : selectedLimit).toInt()),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _limitColor(selectedLimit),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.info_outline, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Annual Cap: \$${maxLimit.toInt()}",
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFF007AFF), // iOS blue
                        inactiveTrackColor: const Color(0xFFCED0D4), // iOS-style dark grey
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbColor: const Color(0xFF007AFF), // same as active track
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: selectedLimit.clamp(0, maxLimit),
                        min: 0,
                        max: maxLimit,
                        onChanged: (val) {
                          setState(() => selectedLimit = val.clamp(0, maxLimit));
                        },
                      ),
                    ),
                    _buildAvailableLimitMessage(
                      isBlocked ? 0 : selectedLimit,
                      maxLimit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog({String? reason}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🗑️ Icon
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE8E8), Color(0xFFFFCCCC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.delete_forever_rounded, size: 48, color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 📝 Title
                    const Text(
                      "Delete Card?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "This action is irreversible. Once deleted, the card will be removed from your account and disabled permanently.",
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: Color(0xFF3C3C43),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 💳 Card Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD1D1D6)),
                      ),
                      child: Column(
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Cardholder", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73))),
                              Text("Nada S. Rhandor", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Card Number", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73))),
                              Text("•••• •••• •••• 345", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Card Type", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73))),
                              Text("Visa", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Expires", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73))),
                              Text("08/26", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (reason != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF0F0), Color(0xFFFFE5E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFFFA0A0), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 38),
                            const SizedBox(height: 6),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                  color: Color(0xFFB00020),
                                ),
                                children: [
                                  const TextSpan(text: "Selected reason: "),
                                  TextSpan(
                                    text: "\"$reason\".\n",
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const TextSpan(text: "Are you sure you want to delete this card?"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 🧭 Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFD1D1D6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // ✅ 1. First CLOSE the Delete Confirmation Dialog
                              Future.delayed(const Duration(milliseconds: 150), () { // ✅ 2. Then AFTER a small delay show OTP cleanly
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => OtpVerificationDialog(
                                    onConfirmed: (otp) {
                                      if (otp == "1111") {
                                        Navigator.pop(context); // ✅ Only close the OTP dialog
                                        Future.delayed(const Duration(milliseconds: 200), () {
                                          setState(() {
                                            isRequestSent = true; // ✅ Mark request as sent
                                            // 🔥 Force RESET everything after delete request:
                                            blockReason = null;
                                            isBlocked = false;
                                            showRequestNewCvv = false;
                                            showRequestCard = false;
                                            someoneTriedConfirmed = false;
                                            isJustBlockNowConfirmed = false;
                                            isAccountClosureConfirmed = false;
                                          });
                                          showCupertinoGlassToast(
                                            context,
                                            "Request sent. Your card deletion is being processed.",
                                            isSuccess: true,
                                            position: ToastPosition.top,
                                          );
                                        });
                                      } else {
                                        showCupertinoGlassToast(
                                          context,
                                          "Incorrect code.",
                                          isSuccess: false,
                                          position: ToastPosition.top,
                                        );
                                      }
                                    },

                                  ),
                                );
                              });
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget _buildAvailableLimitMessage(double selected, double max) {
    final double remaining = max - selected;
    final double percentUsed = selected / max;

    IconData icon;
    Color color;
    String message;

    if (percentUsed >= 1.0) {
      icon = Icons.block;
      color = Colors.redAccent;
      message = "Limit Reached";
    } else if (percentUsed >= 0.7) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orangeAccent;
      message = "Almost Reached – \$${remaining.toInt()} left";
    } else {
      icon = Icons.check_circle;
      color = Colors.green;
      message = "Available: \$${remaining.toInt()}";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                color.withOpacity(0.07),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _limitColor(double value) {
    if (value <= 1000) return const Color(0xFF34C759);
    if (value <= 3000) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  Widget _buildBlockCardSection() {
    bool isJustBlockNow = blockReason?.label == 'Just Block for Now (Temporary)';
    final bool isDropdownDisabled = isJustBlockNow || showRequestNewCvv || someoneTriedConfirmed || isAccountClosureConfirmed || requestSent;

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
                  child: Text(
                    "Block this card",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                UltraSwitch(
                  value: isBlocked,
                  onChanged: (val) async {
                    if (!val) {

                      // 🛑 Prevent unblock if virtual card request is pending
                      if (someoneTriedConfirmed && requestSent) {
                        showCupertinoGlassToast(
                          context,
                          "You cannot unblock this card until your new virtual card is generated.",
                          isSuccess: false,
                          position: ToastPosition.top,
                        );
                        return;
                      }

                      // 🛑 Prevent unblock if CVV regeneration is ongoing
                      if (showRequestNewCvv) {
                        showCupertinoGlassToast(
                          context,
                          "CVV is still being regenerated. You can't unblock the card yet.",
                          isSuccess: false,
                          position: ToastPosition.top,
                        );
                        return;
                      }

                      // Handle "Just Block for Now (Temporary)"
                      if (isJustBlockNowConfirmed && blockReason?.label == 'Just Block for Now (Temporary)') {
                        bool confirm = await _showUnblockConfirmation(
                          title: "Unblock Card",
                          message: "Turning off the block will cancel the reason:\n\n🛑 ${blockReason?.label ?? ''}",
                        );
                        if (confirm) {
                          setState(() {
                            isBlocked = false;
                            blockReason = null;
                            blockStartDate = null;
                            blockEndDate = null;
                            isPermanent = false;
                            showRequestCard = false;
                            isJustBlockNowConfirmed = false;
                            someoneTriedConfirmed = false;
                          });
                          showCupertinoGlassToast(
                            context,
                            "Card unblocked and reason cleared.",
                            isSuccess: true,
                            position: ToastPosition.top,
                          );
                        }
                        return;
                      }

                      // Handle "Someone Tried to Use My Card"
                      if (someoneTriedConfirmed && blockReason?.label == 'Someone Tried to Use My Card') {
                        bool confirm = await _showUnblockConfirmation(
                          title: "Unblock Card",
                          message: "Turning off the block will cancel the reason:\n\n⚠️ ${blockReason?.label ?? ''}",
                        );
                        if (confirm) {
                          setState(() {
                            isBlocked = false;
                            blockReason = null;
                            blockStartDate = null;
                            blockEndDate = null;
                            isPermanent = false;
                            showRequestCard = false;
                            someoneTriedConfirmed = false;
                          });
                          showCupertinoGlassToast(
                            context,
                            "Card unblocked and reason cleared.",
                            isSuccess: true,
                            position: ToastPosition.top,
                          );
                        }
                        return;
                      }

                      // Handle "I'm Closing My Account or Switching"
                      if (isAccountClosureConfirmed && blockReason?.label == 'I’m Closing My Account or Switching') {
                        bool confirm = await _showUnblockConfirmation(
                          title: "Clear Block Reason?",
                          message: "Turning off the block will cancel the closure reason and reactivate the card.\nAre you sure?",
                        );
                        if (confirm) {
                          setState(() {
                            isBlocked = false;
                            blockReason = null;
                            blockStartDate = null;
                            blockEndDate = null;
                            isPermanent = false;
                            showRequestCard = false;
                            isAccountClosureConfirmed = false;
                          });
                          showCupertinoGlassToast(
                            context,
                            "Block reason cleared. Card is now active.",
                            isSuccess: true,
                            position: ToastPosition.top,
                          );
                        }
                        return;
                      }


                    }



                    // ✅ If no confirmation needed, proceed normally
                    setState(() {
                      isBlocked = val;
                      if (val) _scrollToBottom();
                      if (!val) {
                        isJustBlockNowConfirmed = false;
                      }
                    });

                    // ⏳ Timeout if no reason selected within 15s after block
                    if (val && blockReason == null) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        showCupertinoGlassToast(
                          context,
                          "You must choose a reason within 15 seconds or the block will be cancelled.",
                          isSuccess: false,
                          position: ToastPosition.top,
                        );
                      });

                      Future.delayed(const Duration(seconds: 15), () {
                        if (mounted && blockReason == null && isBlocked) {
                          setState(() => isBlocked = false);
                          showCupertinoGlassToast(
                            context,
                            "Blocking has been cancelled due to no reason being selected.",
                            isSuccess: false,
                            position: ToastPosition.top,
                          );
                        }
                      });
                    }
                  },
                  activeColor: Colors.redAccent,
                ),

              ],
            ),
          ),
        ),
        if (isBlocked)
          Column(
            children: [
              buildLabeledField(
                "Reason for Blocking",
                Column(
                  children: [
                    IgnorePointer(
                          ignoring: isDropdownDisabled,
                          child: Opacity(
                            opacity: isDropdownDisabled ? 0.5 : 1.0,

                      child: CustomDropdown(
                          key: ValueKey(blockReason?.label ?? 'none'),
                          icon: Icons.warning_amber_rounded,
                          selectedItem: blockReason,
                          items: blockReasons,
                          onChanged: (value) {
                            setState(() {
                              blockReason = value;
                              showRequestCard = false;
                              isPermanent = false;
                              blockStartDate = null;
                              blockEndDate = null;
                              showRequestNewCvv = false;
                            });

                            if (value.label == 'Just Block for Now (Temporary)') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFFE8E8), Color(0xFFFFCCCC)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: const Icon(Icons.lock_clock_rounded, size: 60, color: Colors.redAccent),
                                          ),
                                          const SizedBox(height: 24),
                                          const Text(
                                            "Temporary Block",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1C1C1E),
                                              letterSpacing: -0.3,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              "This card will be temporarily blocked.\nAll card services will be disabled until reactivated.",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF3A3A3C),
                                                height: 1.55,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 20),
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFf7f7f7), Color(0xFFe0e0e0)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: Color(0xFFDDDDDD)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.03),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: const [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Cardholder", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
                                                    Text("Nada S. Rhandor", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Card Number", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
                                                    Text("•••• •••• •••• 345", style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Status", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
                                                    Text("Temporarily Blocked", style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: const Color(0xFFD1D1D6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = false;
                                                      blockReason = null;
                                                      isJustBlockNowConfirmed = false;
                                                    });
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "Temporary block cancelled.\nReason was: Just Block for Now",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                  },
                                                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: Colors.redAccent,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isJustBlockNowConfirmed = true;
                                                    });
                                                    Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "For the moment, card is temporarily blocked and all card services are disabled.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                  },
                                                  child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }

                            else if (value.label == 'My Card Details Got Leaked (CVV)') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.security, size: 50, color: Colors.redAccent),
                                          const SizedBox(height: 18),
                                          const Text(
                                            "CVV Leak Detected",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "We've temporarily blocked your card.\nWould you like to request a new CVV for enhanced security?",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C), height: 1.5),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: const Color(0xFFD1D1D6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = false;
                                                      blockReason = null;
                                                      showRequestNewCvv = false;
                                                      cvvCountdown = 0;
                                                    });
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "Request cancelled. Card is no longer blocked.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                  },
                                                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: Colors.redAccent,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = true;
                                                      showRequestNewCvv = true;
                                                      blockStartDate = null;
                                                      blockEndDate = null;
                                                    });

                                                    showCupertinoGlassToast(
                                                      context,
                                                      "New CVV request sent. Card is blocked for your protection.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );

                                                    // ⏱ Start CVV generation countdown
                                                    cvvCountdown = 60;
                                                    _cvvTimer?.cancel();
                                                    _cvvTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                                      if (!mounted || cvvCountdown == 0) {
                                                        timer.cancel();
                                                        _cvvTimer = null;
                                                        if (mounted && isBlocked && blockReason?.label == 'My Card Details Got Leaked (CVV)') {
                                                          setState(() {
                                                            showRequestNewCvv = false;
                                                            isBlocked = false;
                                                            blockReason = null;
                                                            _cvvController.text = '•••';
                                                          });
                                                          showCupertinoGlassToast(
                                                            context,
                                                            "New CVV generated. Card is now active.",
                                                            isSuccess: true,
                                                            position: ToastPosition.top,
                                                          );
                                                        }
                                                      } else {
                                                        setState(() => cvvCountdown--);
                                                      }
                                                    });
                                                  },
                                                  child: const Text("Request New CVV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }


                            else if (value.label == 'Someone Tried to Use My Card') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.redAccent),
                                          const SizedBox(height: 18),
                                          const Text("Suspicious Activity",
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
                                              textAlign: TextAlign.center),
                                          const SizedBox(height: 12),
                                          const Text(
                                              "We detected a report of unauthorized use.\nThis card will be permanently blocked.",
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C), height: 1.5),
                                              textAlign: TextAlign.center),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: const Color(0xFFD1D1D6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = false;
                                                      blockReason = null;
                                                      showRequestNewCvv = false;
                                                      isPermanent = false;
                                                      someoneTriedConfirmed = false;
                                                    });
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "Cancelled. Card not blocked.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                  },
                                                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: Colors.redAccent,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = true;
                                                      isPermanent = true;
                                                      showRequestNewCvv = false;
                                                      blockStartDate = null;
                                                      blockEndDate = null;
                                                      someoneTriedConfirmed = true; // ✅ FLAG SET
                                                    });
                                                    Future.delayed(const Duration(milliseconds: 150), () {
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Card is now permanently blocked.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    });
                                                  },
                                                  child: const Text("Confirm Block", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }


                            else if (value.label == 'I’m Closing My Account or Switching') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.arrow_right_arrow_left_circle_fill,
                                            size: 50,
                                            color: Colors.redAccent,
                                          ),
                                          const SizedBox(height: 18),
                                          const Text(
                                            "Closing Account",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1C1C1E),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "You’re closing your account or switching.\nThis card will be permanently blocked for your security.",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF3A3A3C),
                                              height: 1.55,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: const Color(0xFFD1D1D6),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = false;
                                                      blockReason = null;
                                                      isPermanent = false;
                                                      isAccountClosureConfirmed = false;
                                                    });
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "Cancelled. Card remains active.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                  },
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFF3B30), // Slightly stronger red
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isBlocked = true;
                                                      isPermanent = true;
                                                      showRequestCard = true;
                                                      isAccountClosureConfirmed = true; // ⬅️ This makes dropdown disabled
                                                    });
                                                    showCupertinoGlassToast(
                                                      context,
                                                      "Card permanently blocked.",
                                                      isSuccess: false,
                                                      position: ToastPosition.top,
                                                    );
                                                    Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
                                                  },
                                                  child: const Text(
                                                    "Confirm Block",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }

                          },
                          label: '',
                        ),

                      ),
                    ),

                    if (isJustBlockNowConfirmed)
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 380, // ⬅️ Adjust this if needed
                          child: Container(
                            margin: const EdgeInsets.only(top: 10), // ⬅️ Push it down a bit
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF1F1), Color(0xFFFFE2E2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    "Card is temporarily blocked.\nAll card services are currently disabled.",
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (someoneTriedConfirmed)
                      Column(
                        children: [
                          // 🔷 Modern Span Box
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  colors: requestSent
                                      ? [Color(0xFFDCF9E6), Color(0xFFB8EFCF)]
                                      : [Color(0xFFFFE0E0), Color(0xFFFFCCCC)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: requestSent
                                        ? Colors.green.withOpacity(0.06)
                                        : Colors.redAccent.withOpacity(0.06),
                                    blurRadius: 22,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: requestSent
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.redAccent.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // ⬅️ centered
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // ⬅️ center icon + title
                                    children: [
                                      Icon(
                                        requestSent
                                            ? CupertinoIcons.checkmark_seal_fill
                                            : CupertinoIcons.exclamationmark_triangle_fill,
                                        color: requestSent ? Colors.green : Colors.redAccent,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        requestSent ? "Request Sent" : "Warning",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: requestSent ? Colors.green : Colors.redAccent,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    requestSent
                                        ? "Your request for a new virtual card is being processed. You’ll be notified when it's ready."
                                        : "Suspicious activity detected. You can request a new card or disable the block to reset this reason.",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 🔘 Button Logic with CupertinoButton
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: requestSent
                                ? SizedBox(
                              width: 250,
                              key: const ValueKey("sentBtn"),
                              child: CupertinoButton.filled(
                                onPressed: null,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                borderRadius: BorderRadius.circular(18),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.checkmark_alt, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Request Sent",
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : SizedBox(
                              width: 250,
                              key: const ValueKey("requestBtn"),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                color: const Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(18),
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                      title: Column(
                                        children: const [
                                          Icon(CupertinoIcons.creditcard_fill, size: 40, color: Color(0xFF007AFF)),
                                          SizedBox(height: 10),
                                          Text(
                                            "Request Card?",
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      content: const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          "Do you want to request a new virtual card?\nYour current card is blocked.",
                                          style: TextStyle(height: 1.5),
                                        ),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text("Cancel"),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          child: const Text("Confirm"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() => requestSent = true);
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              showCupertinoGlassToast(
                                                context,
                                                "Virtual card request sent ✅",
                                                isSuccess: true,
                                                position: ToastPosition.top,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.creditcard, size: 18, color: Colors.white), // icon white
                                    SizedBox(width: 8),
                                    Text(
                                      "Request New Virtual Card",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.white, // ⬅️ force white text here
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )




                  ],
                ),
              ),
            ],
          ),

        if (showRequestNewCvv)
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showRequestNewCvv ? 1.0 : 0.0,
              curve: Curves.easeOut,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: showRequestNewCvv ? 1.0 : 0.95,
                curve: Curves.easeOutBack,
                child: SizedBox(
                  width: 360,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_rounded, size: 18, color: Colors.deepOrange),
                        const SizedBox(width: 10),
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                                height: 1.5,
                                letterSpacing: 0.1,
                              ),
                              children: [
                                const TextSpan(text: "Your card is blocked. "),
                                TextSpan(
                                  text: "New CVV in ${cvvCountdown}s",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const TextSpan(text: " ⏳"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),


        if (isBlocked && isPermanent && blockReason?.label == 'I’m Closing My Account or Switching') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB), // softer background instead of pure white
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(0.25),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        CupertinoIcons.arrow_right_arrow_left_circle_fill,
                        size: 26, // (slightly bigger for better visual balance)
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 12), // (a bit more space)
                      Text(
                        "Account Closure",
                        style: TextStyle(
                          fontSize: 18, // (slightly bigger)
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "This card is permanently blocked due to\naccount closure or switching to another bank.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

      ],
    );
  }



  Future<bool> _showUnblockConfirmation({required String title, required String message}) async {
    bool result = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD1D1D6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        result = false;
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        result = true;
                      },
                      child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result;
  }

  Widget _buildEcommerceToggle() {
    final isDisabled = isBlocked || isCardLocked;

    if (isDisabled && isEcommerceEnabled) {
      // 🔥 Force OFF if disabled and still ON
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isEcommerceEnabled = false);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1,
        child: IgnorePointer(
          ignoring: isDisabled,
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
                Icon(Icons.shopping_cart_checkout, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "E-Commerce Payments",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                UltraSwitch(
                  value: isBlocked ? false : isEcommerceEnabled,
                  onChanged: (val) {
                    setState(() => isEcommerceEnabled = val);
                  },
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildFrontCard() => _cardContainer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Virtual Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Image.asset('assets/visa_logo.png', width: 50, height: 50),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRequestSent ? '**** **** *** 456' : '1234 5678 9012',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
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
                const Text('EXPIRES',
                    style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 2),
                Text(
                  isRequestSent ? '**/**' : '08/26',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildBackCard() => _cardContainer(
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
              child: Text(
                isRequestSent ? '•••' : '527',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Signature',
                style: TextStyle(fontSize: 10, color: Colors.white54)),
            Text(
              isRequestSent ? '**/**' : 'Valid Thru 08/26',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
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
  Widget _buildDeleteCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Soft Black Line with Limited Width and Space Around the Label
              Container(
                width: 130, // Increased the width for a longer line
                child: const Divider(
                  color: Color(0xFFB0B0B0), // Soft black line color
                  thickness: 2, // Slightly bolder line
                ),
              ),
              // Adding space around the label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12), // Space between the label and lines
                child: const Text(
                  "Delete Card",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Soft Black Line with Limited Width and Space Around the Label
              Container(
                width: 130, // Increased the width for a longer line
                child: const Divider(
                  color: Color(0xFFB0B0B0), // Soft black line color
                  thickness: 2, // Slightly bolder line
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 370, // Slightly increased the width to 370 (adjust as needed)
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA), // iOS grey input style
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1D1D6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📝 Static RichText about card deletion
                RichText(
                  textAlign: TextAlign.justify,
                  text: const TextSpan(
                    text:
                    "Deleting this card will permanently remove it from your profile. "
                        "You will no longer be able to use it for transactions, and linked services "
                        "like subscriptions or online payments will be disabled.",
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: Color(0xFF3C3C43),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 🧠 Animated Process Section (Span + Button)
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔹 Info Span BEFORE sending
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: !isRequestSent
                            ? Padding(
                          key: const ValueKey("beforeRequestSpan"),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Submitting a secure unlink request...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.8,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // 🔹 Fancy Button (Delete ➔ Request Sent)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInBack,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: isRequestSent
                            ? CupertinoButton.filled(
                          key: const ValueKey("sentDeleteBtn"),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(18),
                          onPressed: null,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.checkmark_seal_fill, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Request Sent",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                            : GestureDetector(
                          key: const ValueKey("deleteBtn"),
                          onTap: () => _showDeleteConfirmationDialog(reason: blockReason?.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30), // iOS Delete Red
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.delete_solid, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Delete Card",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            ),
          ),
        ),
      ],
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
    _reasonResetTimer?.cancel();
    _cvvTimer?.cancel(); // ✅ cleanup CVV countdown timer
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final bounceScale = _scrollController.hasClients && _scrollController.offset < 0
        ? 1.0 - (_scrollController.offset / -150)
        : 1.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌈 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFD6F2F0),
                  Color(0xFFE3E4F7),
                  Color(0xFFF5F6FA),
                  Color(0xFFFFF1F3),
                  Color(0xFFE0F7FA),
                ],
              ),
            ),
          ),

          // 🧊 Frosted Glass Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // 📜 Scrollable Content
          Padding(
            padding: EdgeInsets.only(top: topPadding + kToolbarHeight + 16),
            child:ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                AnimatedScale(
                  scale: bounceScale.clamp(0.96, 1.02),
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: _buildCard(),
                ),
                _buildInfoSection(),

                // ✨ Only show Limit if request is NOT sent
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isRequestSent
                      ? const SizedBox.shrink()
                      : _buildLimitSection(),
                ),

                if (!isRequestSent) _buildSectionTitle("Security Settings"),

                // ✨ Only show E-Commerce toggle if request is NOT sent
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isRequestSent
                      ? const SizedBox.shrink()
                      : _buildEcommerceToggle(),
                ),

                // ✨ Only show Block Card if request is NOT sent
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isRequestSent
                      ? const SizedBox.shrink()
                      : _buildBlockCardSection(),
                ),

                _buildDeleteCardSection(),
                const SizedBox(height: 40),
              ],
            )

          ),

          // 🧭 Fixed Title Header
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  BackButton(color: Colors.black),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Card Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 🔐 PIN Popup
          if (showPinPopup) _buildPinPopup(),
        ],
      ),
    );
  }


}



