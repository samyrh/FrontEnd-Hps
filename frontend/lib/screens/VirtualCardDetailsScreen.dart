import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dto/card_dto/BlockVirtualCardRequest.dart';
import '../dto/card_dto/ReplaceVirtualCardRequest.dart';
import '../dto/card_dto/UpdateSecurityOptionRequest.dart';
import '../dto/card_dto/VirtualSecurityOption.dart';
import '../dto/card_dto/card_model.dart';
import '../services/VirtualCardOtpService/VirtualCardOtpService.dart';
import '../services/auth/auth_service.dart';
import '../services/card_service/CardSecurityService.dart';
import '../services/card_service/card_service.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/OtpVerificationDialog.dart';
import '../widgets/Toast.dart';
import '../widgets/UltraSwitch.dart';
import '../widgets/VirtualCard/cardholder_info_section.dart';
import '../widgets/VirtualCard/delete_card_section.dart';
import '../widgets/VirtualCard/ecommerce_toggle.dart';
import '../widgets/VirtualCard/flippable_card.dart';
import '../widgets/VirtualCard/online_limit_section.dart';
import '../widgets/VirtualCard/pin_popup.dart';
import '../widgets/VirtualCard/section_title.dart';


//test
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class VirtualCardDetailsScreen extends StatefulWidget {
  final String? cardId; // <-- Accept cardId from route

  const VirtualCardDetailsScreen({Key? key, this.cardId}) : super(key: key);

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
  bool? isEcommerceEnabled;
  bool isTpePaymentEnabled = true;
  DateTime? blockStartDate;
  DateTime? blockEndDate;
  bool showRequestCard = false;
  bool isPermanent = false;
  bool showRequestNewCvv = false;
  bool isJustBlockNowConfirmed = false;
  int cvvCountdown = 60;
  Timer? _cvvTimer;
  Timer? _autoFlipTimer;
  bool someoneTriedConfirmed = false;
  bool requestSent = false;
  bool isAccountClosureConfirmed = false;
  bool isCardDeleted = false;
  bool isRequestSent = false;
  bool isFlippedByCvv = false;
  bool isBackByTap = false;
  bool get isCardLocked => isRequestSent;
  final TextEditingController _cvvController = TextEditingController(
      text: '•••');
  final TextEditingController _pinController = TextEditingController(
      text: '••••');
  DropdownItem? selectedLimitType;
  DropdownItem? blockReason;
  final ScrollController _scrollController = ScrollController();
  Timer? _reasonResetTimer;
  bool isCardCancelled = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  double selectedLimit = 500;
  bool isBlocked = false;
  final List<DropdownItem> blockReasons = [
    DropdownItem(label: 'Just Block for Now (Temporary)', icon: Icons.timelapse),
    DropdownItem(label: 'My Card Details Got Leaked (CVV)', icon: Icons.security),
    DropdownItem(label: 'Someone Tried to Use My Card', icon: Icons.warning_amber_rounded),
    DropdownItem(label: "I'm Closing My Account or Switching", icon: Icons.logout),
  ];
  final Map<String, double> maxLimitByType = {
    'Online Purchase Limit (Per Year)': 5000, // or whatever you want as max
  };
  final Gradient cardGradient = const LinearGradient(
    colors: [Color(0xFFB6FBFF), Color(0xFF83A4D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  bool _pendingRevealCvv = false;
  CardModel? _cardModel;
  bool isLoading = true;

  // --- New for security options ---
  List<VirtualSecurityOption> _securityOptions = [];
  bool isSecurityOptionsLoading = true;

  Timer? _ecommerceStatusTimer;
  Timer? _cardStatusTimer;
  bool isPendingReasonSelection = false;

  final Map<String, String> blockReasonBackendValues = {
    'Just Block for Now (Temporary)': 'JUST_BLOCK_TEMPORARY',
    'My Card Details Got Leaked (CVV)': 'CVV_LEAK',
    'Someone Tried to Use My Card': 'FRAUD_SUSPECTED',
    "I'm Closing My Account or Switching": 'CLOSING_ACCOUNT',
  };

  Future<void> _loadSecurityOptions() async {
    try {
      final options = await SecurityOptionsService().fetchVirtualCardSecurityOptions();
      if (!mounted) return;
      setState(() {
        _securityOptions = options;
        isSecurityOptionsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isSecurityOptionsLoading = false);
    }
  }
  VirtualSecurityOption? get currentSecurityOption {
    if (_cardModel == null) return null;
    try {
      return _securityOptions.firstWhere(
            (opt) =>
        opt.label == _cardModel!.cardPack.label &&
            opt.cardholderName == _cardModel!.cardholderName,
      );
    } catch (e) {
      return null;
    }
  }
  void _flipCard({bool? forceFront, bool byTap = true}) {
    if (isCardCancelled) {
      showCupertinoGlassToast(context, "This card is cancelled and cannot be flipped.", isSuccess: false, position: ToastPosition.top);
      return;
    }

    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is blocked. Cannot flip.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }

    if (forceFront != null) {
      if (!forceFront && !isFront) {
        _controller.reverse();
        setState(() => isFront = true);
      } else if (forceFront && isFront) {
        _controller.forward();
        setState(() => isFront = false);
      }
      return;
    }

    if (isFront) {
      _controller.forward();
      setState(() {
        isFront = false;
        isBackByTap = byTap; // <-- Only set true if byTap
      });
      if (byTap) {
        _autoFlipTimer?.cancel();
        _autoFlipTimer = Timer(const Duration(seconds: 5), () {
          setState(() {
            isFront = true;
            isBackByTap = false;
          });
          _controller.reverse();
        });
      }
    } else {
      _controller.reverse();
      setState(() {
        isFront = true;
        isBackByTap = false;
      });
      _autoFlipTimer?.cancel();
    }
  }
  Future<void> _revealCVV() async {
    if (_cardModel == null || isCvvRevealed) return;

    _autoFlipTimer?.cancel();

    if (isFront) {
      _pendingRevealCvv = true;
      _flipCard(byTap: false);
      isFlippedByCvv = true;
      // Don't set isCvvRevealed yet!
    } else {
      // Only proceed if the CVV is about to be shown as numbers
      if (_cardModel!.cvv != null && _cardModel!.cvv != '•••') {
        setState(() {
          _cvvController.text = _cardModel!.cvv!;
          isCvvRevealed = true;
          isBackByTap = false;
          isFlippedByCvv = false;
        });
        _startAutoHideCvv();

        // Notify backend that CVV was viewed
        await CardService().viewVirtualCardCVV(_cardModel!.id.toString());
      } else {
        showCupertinoGlassToast(
          context,
          "CVV is not available.",
          isSuccess: false,
          position: ToastPosition.top,
        );
      }
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

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && _pendingRevealCvv) {
        setState(() {
          isCvvRevealed = true;
          isBackByTap = false;
          _pendingRevealCvv = false;
        });
        _startAutoHideCvv();

        if (_cardModel != null && _cardModel!.cvv != null && _cardModel!.cvv != '•••') {
          await CardService().viewVirtualCardCVV(_cardModel!.id.toString());
        }
      }
    });

    // Load card data first
    _loadCard().then((_) {
      _startCardStatusPolling(); // Start polling after initial load
    });

    _loadUserInfo();
    _loadSecurityOptions();
    _startEcommerceStatusPolling();
  }

  void _startAutoHideCvv() {
    _autoFlipTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        isCvvRevealed = false;
        if (isFlippedByCvv) {
          _flipCard();
        }
        isFlippedByCvv = false;
      });
    });
  }
  Future<void> _loadUserInfo() async {
    final info = await AuthService().loadUserInfo();
    if (info != null) {
      if (!mounted) return;
      setState(() {
        _usernameController.text = info.username ?? 'Unknown';
        _emailController.text = info.email ?? 'Unknown';
      });
    }
  }
  Future<void> _loadCard() async {
    try {
      final card = await CardService().fetchCardById(widget.cardId!);
      if (!mounted) return;
      setState(() {
        _cardModel = card;
        selectedLimit = card.annualLimit;
        _syncBlockingState();  // ✅ call it only once inside setState
      });

      await _fetchEcommerceStatus();

      // ✅ Optional debug logs
      print("✅ Loaded Card:");
      print("• Cardholder: ${card.cardholderName}");
      print("• Card Number: ${card.cardNumber}");
      print("• Expiry Date: ${card.expirationDate}");
      print("• Gradient: ${card.gradientStartColor} → ${card.gradientEndColor}");
      print("• Balance: ${card.balance}");
      print("• Pack: ${card.cardPack.label}");
      print("• Status: ${card.status}");
      print("• Block Reason: ${card.blockReason}");

    } catch (e) {
      if (!mounted) return;
      print("❌ Failed to load card: $e");
      showCupertinoGlassToast(context, "Failed to load card data", isSuccess: false);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
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
  Widget buildDeleteConfirmationDialog() {
    return Dialog(
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
                const Text("Delete Card?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)), textAlign: TextAlign.center),
                const SizedBox(height: 14),
                const Text(
                  "This action is irreversible. Once deleted, the card will be removed from your account and disabled permanently.",
                  style: TextStyle(fontSize: 14.5, height: 1.55, color: Color(0xFF3C3C43)),
                  textAlign: TextAlign.center,
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
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initiateCardDeletion() async {
    final username = _usernameController.text;

    // 🔐 1. Generate OTP via VirtualCardOtpService
    final otpGenerated = await VirtualCardOtpService.generateOtp(username: username);
    if (!otpGenerated) {
      showCupertinoGlassToast(
        context,
        "Failed to generate OTP ❌",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }

    // 🔐 2. Show OTP Dialog (auto-verification handled inside)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpVerificationDialog(
        username: username,
        isVirtualCardOtp: true,  // ✅ very important flag here
        onConfirmed: (otp) async {
          // OTP is already verified when we reach here

          Navigator.pop(context);  // close OTP dialog

          // 🔐 3. Ask final confirmation before cancelling card
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (_) => buildDeleteConfirmationDialog(),
          );

          if (confirmed == true) {
            try {
              await CardService().cancelVirtualCard(_cardModel!.id.toString());

              // 🔄 Small delay to let backend update status fully
              await Future.delayed(const Duration(seconds: 1));

              // 🔄 Refresh again after backend fully applied cancel status
              await _loadCard();

              setState(() {
                isCardCancelled = true;
              });

              _cardStatusTimer?.cancel();

              showCupertinoGlassToast(context, "Virtual card cancelled ✅", isSuccess: true);
            } catch (e) {
              showCupertinoGlassToast(context, "Failed to cancel card ❌", isSuccess: false);
            }
          }

        },
      ),
    );
  }

  Widget _buildBlockCardSection() {
    bool isJustBlockNow = blockReason?.label == 'Just Block for Now (Temporary)';
    final bool isDropdownDisabled = isJustBlockNow || showRequestNewCvv || someoneTriedConfirmed || isAccountClosureConfirmed || requestSent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Block Card"),
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

                      // 🛑 Handle "Someone Tried to Use My Card" logic
                      if (someoneTriedConfirmed) {
                        if (requestSent) {
                          showCupertinoGlassToast(
                            context,
                            "You cannot unblock this card until your new virtual card is generated.",
                            isSuccess: false,
                            position: ToastPosition.top,
                          );
                          return;
                        } else {
                          bool confirm = await _showUnblockConfirmation(
                            title: "Unblock Card",
                            message: "This will cancel the fraud suspicion reason and reactivate your card.",
                          );
                          if (confirm) {
                            try {
                              await SecurityOptionsService().unblockVirtualCard(_cardModel!.id.toString());
                              await _loadCard();
                              showCupertinoGlassToast(
                                context,
                                "Card unblocked successfully.",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            } catch (e) {
                              showCupertinoGlassToast(
                                context,
                                "Failed to unblock card.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                          }
                          return;
                        }
                      }

                      // 🔓 Handle "Just Block for Now (Temporary)"
                      if (isJustBlockNowConfirmed && blockReason?.label == 'Just Block for Now (Temporary)') {
                        bool confirm = await _showUnblockConfirmation(
                          title: "Unblock Card",
                          message: "This will cancel the temporary block.",
                        );
                        if (confirm) {
                          try {
                            await SecurityOptionsService().unblockVirtualCard(_cardModel!.id.toString());
                            await _loadCard();
                            showCupertinoGlassToast(
                              context,
                              "Card unblocked successfully.",
                              isSuccess: true,
                              position: ToastPosition.top,
                            );
                          } catch (e) {
                            showCupertinoGlassToast(
                              context,
                              "Failed to unblock card.",
                              isSuccess: false,
                              position: ToastPosition.top,
                            );
                          }
                        }
                        return;
                      }

                      // 🔓 Handle "I'm Closing My Account or Switching"
                      if (isAccountClosureConfirmed && blockReason?.label == "I'm Closing My Account or Switching") {
                        bool confirm = await _showUnblockConfirmation(
                          title: "Unblock Card",
                          message: "This will cancel the closure reason and reactivate your card.",
                        );
                        if (confirm) {
                          try {
                            await SecurityOptionsService().unblockVirtualCard(_cardModel!.id.toString());
                            await _loadCard();
                            showCupertinoGlassToast(
                              context,
                              "Card unblocked successfully.",
                              isSuccess: true,
                              position: ToastPosition.top,
                            );
                          } catch (e) {
                            showCupertinoGlassToast(
                              context,
                              "Failed to unblock card.",
                              isSuccess: false,
                              position: ToastPosition.top,
                            );
                          }
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
                      setState(() {
                        isPendingReasonSelection = true;
                      });

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
                          setState(() {
                            isBlocked = false;
                            isPendingReasonSelection = false;
                          });
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
                              // ✅ Resume polling once reason is chosen
                              isPendingReasonSelection = false;
                            });

                            if (value.label == 'Just Block for Now (Temporary)') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (!mounted) return;
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

                                          // ✅ Buttons
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
                                                      "Temporary block cancelled.",
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
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() => isBlocked = true);
                                                    try {
                                                      final backendReason = blockReasonBackendValues[blockReason!.label]!;
                                                      await SecurityOptionsService().blockVirtualCard(
                                                        _cardModel!.id.toString(),
                                                        BlockVirtualCardRequest(blockReason: backendReason),
                                                      );
                                                      await _loadCard();
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Card blocked successfully!",
                                                        isSuccess: true,
                                                        position: ToastPosition.top,
                                                      );


                                                    } catch (e) {
                                                      setState(() => isBlocked = false);
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Failed to block card.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    }
                                                  },
                                                  child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

                            else if (value.label == 'My Card Details Got Leaked (CVV)') {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (!mounted) return;
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
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() => isBlocked = true);
                                                    try {
                                                      final backendReason = blockReasonBackendValues[blockReason!.label]!;
                                                      await SecurityOptionsService().blockVirtualCard(
                                                        _cardModel!.id.toString(),
                                                        BlockVirtualCardRequest(blockReason: backendReason),
                                                      );
                                                      await _loadCard();
                                                      // ✅ After success — update UI state & start CVV generation timer
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "New CVV request sent. Card is blocked for your protection.",
                                                        isSuccess: true,
                                                        position: ToastPosition.top,
                                                      );

                                                      setState(() {
                                                        showRequestNewCvv = true;
                                                        blockStartDate = null;
                                                        blockEndDate = null;
                                                        cvvCountdown = 60;
                                                      });

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

                                                    } catch (e) {
                                                      setState(() => isBlocked = false);
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Failed to block card.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    }
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
                                if (!mounted) return;
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
                                          const Text(
                                            "Suspicious Activity",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "We detected a report of unauthorized use.\nThis card will be permanently blocked.",
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
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() => isBlocked = true);

                                                    try {
                                                      if (blockReason == null || !blockReasonBackendValues.containsKey(blockReason!.label)) {
                                                        throw Exception("Invalid block reason selected.");
                                                      }

                                                      final backendReason = blockReasonBackendValues[blockReason!.label]!;

                                                      await SecurityOptionsService().blockVirtualCard(
                                                        _cardModel!.id.toString(),
                                                        BlockVirtualCardRequest(blockReason: backendReason),
                                                      );
                                                      await _loadCard();


                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Card is now permanently blocked.",
                                                        isSuccess: true,
                                                        position: ToastPosition.top,
                                                      );

                                                    } catch (e) {
                                                      setState(() => isBlocked = false);
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Failed to block card.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    }
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

                            else if (value.label == "I'm Closing My Account or Switching") {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (!mounted) return;
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
                                          const Icon(CupertinoIcons.arrow_right_arrow_left_circle_fill, size: 50, color: Colors.redAccent),
                                          const SizedBox(height: 18),
                                          const Text(
                                            "Closing Account",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "You're closing your account or switching.\nThis card will be permanently blocked for your security.",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C), height: 1.55),
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
                                                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFF3B30),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    setState(() => isBlocked = true);

                                                    try {
                                                      if (blockReason == null || !blockReasonBackendValues.containsKey(blockReason!.label)) {
                                                        throw Exception("Invalid block reason selected.");
                                                      }

                                                      final backendReason = blockReasonBackendValues[blockReason!.label]!;

                                                      await SecurityOptionsService().blockVirtualCard(
                                                        _cardModel!.id.toString(),
                                                        BlockVirtualCardRequest(blockReason: backendReason),
                                                      );
                                                      await _loadCard();


                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Card blocked successfully!",
                                                        isSuccess: true,
                                                        position: ToastPosition.top,
                                                      );

                                                    } catch (e) {
                                                      setState(() => isBlocked = false);
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Failed to block card.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    }
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
                                        ? "Your request for a new virtual card is being processed. You'll be notified when it's ready."
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

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: requestSent
                                ? CupertinoButton.filled(
                              onPressed: null,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              borderRadius: BorderRadius.circular(18),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.checkmark_alt, size: 18),
                                  SizedBox(width: 8),
                                  Text("Request Sent", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                ],
                              ),
                            )
                                : CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(18),
                              onPressed: () async {
                                final confirmed = await showCupertinoDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                    title: Column(
                                      children: const [
                                        Icon(CupertinoIcons.creditcard_fill, size: 40, color: Color(0xFF007AFF)),
                                        SizedBox(height: 10),
                                        Text("Request Card?", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    content: const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text("Do you want to request a new virtual card?\nYour current card is blocked."),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("Cancel"),
                                        onPressed: () => Navigator.pop(context, false),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        child: const Text("Confirm"),
                                        onPressed: () => Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  // 🔥 Call the service
                                  final success = await CardService().requestVirtualCardReplacement(
                                    ReplaceVirtualCardRequest(blockedCardId: _cardModel!.id),
                                  );

                                  if (success) {
                                    setState(() => requestSent = true);
                                    showCupertinoGlassToast(context, "Virtual card request sent ✅", isSuccess: true, position: ToastPosition.top);
                                  } else {
                                    showCupertinoGlassToast(context, "Failed to send request", isSuccess: false, position: ToastPosition.top);
                                  }
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.creditcard, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Request New Virtual Card", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
                                ],
                              ),
                            ),
                          )

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


        if (isBlocked && isPermanent && blockReason?.label == "I'm Closing My Account or Switching") ...[
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

  Widget _buildCard() {
    if (isLoading || _cardModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlippableCard(
      animation: _animation,
      onTap: _flipCard,
      onCvvInputTap: isBackByTap ? null : _revealCVV,
      isRequestSent: isRequestSent,
      isFront: isFront,
      isFlippedByCvv: isFlippedByCvv,
      showCvv: isCvvRevealed,
      cardholderName: _cardModel!.cardholderName,
      cardNumber: isCardCancelled
          ? "**** **** **** ${_cardModel!.cardNumber.substring(_cardModel!.cardNumber.length - 3)}"
          : _cardModel!.cardNumber,
      cvv: isCardCancelled ? '***' : (_cardModel!.cvv ?? '•••'),
      expiryDate: isCardCancelled ? '****' : _cardModel!.expirationDate,
      cardGradient: LinearGradient(
        colors: [
          _hexToColor(_cardModel!.gradientStartColor),
          _hexToColor(_cardModel!.gradientEndColor),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      packName: _cardModel!.cardPack.label,
    );

  }
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
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
    _cvvTimer?.cancel();
    _autoFlipTimer?.cancel();
    _ecommerceStatusTimer?.cancel();
    _cardStatusTimer?.cancel();
    super.dispose();
  }



  Future<void> _startEcommerceStatusPolling() {
    _ecommerceStatusTimer?.cancel();
    _ecommerceStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchEcommerceStatus();
    });
    return Future.value();
  }

  Future<void> _fetchEcommerceStatus() async {
    if (_cardModel == null) return;
    try {
      final option = await SecurityOptionsService().fetchVirtualCardSecurityOptionById(_cardModel!.id.toString());
      if (!mounted) return;
      setState(() {
        isEcommerceEnabled = option.ecommerceEnabled;
      });
    } catch (e) {
      // Optionally handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Add this check to prevent null errors
    if (isLoading || _cardModel == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bounceScale = _scrollController.hasClients && _scrollController.offset < 0
        ? 1.0 - (_scrollController.offset / -150)
        : 1.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌈 iOS-style Light & Soft Pastel Gradient Background (Final)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFDFF7F6), // Light Aqua (very soft)
                  Color(0xFFEAE6FB), // Light Lavender
                  Color(0xFFFDF7F8), // Soft White Pink
                  Color(0xFFFFF5F7), // Almost white pink
                  Color(0xFFE3F7FB), // Soft Blue
                  Color(0xFFE9F9EC), // Light Green
                  Color(0xFFFFFBE8), // Very light yellow
                  Color(0xFFFFF2E7), // Very light peach
                ],
                stops: [
                  0.0,
                  0.2,
                  0.4,
                  0.55,
                  0.7,
                  0.85,
                  0.92,
                  1.0,
                ],
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // 📜 Scrollable Content
          Padding(
            padding: EdgeInsets.only(top: topPadding + kToolbarHeight + 16),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 40),
              children: [

                // Card rendering stays always visible (even if cancelled)
                AnimatedScale(
                  scale: bounceScale.clamp(0.96, 1.02),
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: _buildCard(),
                ),

                // Cardholder Info Section (masked when cancelled)
                CardholderInfoSection(
                  usernameController: _usernameController,
                  emailController: _emailController,
                  cvvController: _cvvController,
                  isRequestSent: isRequestSent,
                  isCvvRevealed: isCvvRevealed,
                  onTapRevealCvv: _revealCVV,
                  cardNumber: isCardCancelled
                      ? "**** **** **** ${_cardModel!.cardNumber.substring(_cardModel!.cardNumber.length - 3)}"
                      : _cardModel!.cardNumber,
                  expiryDate: isCardCancelled ? '****' : _cardModel!.expirationDate,
                ),

                // ✅ Fully Modern Cancelled Span (iOS Apple eWallet Style)
                if (isCardCancelled)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Container(
                        width: 340,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF1F1), Color(0xFFFFE5E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.creditcard_fill,
                              size: 48,
                              color: const Color(0xFFFF3B30),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Card Cancelled",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "This virtual card has been permanently disabled and can no longer be used for purchases or authorizations. All transactions, subscriptions, and linked payments associated with this card are automatically declined.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "If you need assistance or wish to request a replacement card, please contact our support team. Reactivation of this card is not possible for security reasons.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 13.8,
                                height: 1.55,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ✅ Online Limit Section (hidden if cancelled)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: (isRequestSent || isCardCancelled)
                      ? const SizedBox.shrink()
                      : OnlineLimitSection(
                    selectedLimit: selectedLimit,
                    maxLimit: _cardModel!.cardPack.limitAnnual,
                    isBlocked: isBlocked,
                    isCardLocked: isCardLocked,
                    onChanged: (val) {
                      setState(() => selectedLimit = val);
                    },
                    onChangeEnd: (val) async {
                      final success = await CardService().updateVirtualCardLimit(_cardModel!.id.toString(), val);
                      if (!mounted) return;
                      if (success) {
                        showCupertinoGlassToast(
                          context,
                          "Annual limit updated successfully!",
                          isSuccess: true,
                          position: ToastPosition.top,
                        );
                        await _loadCard();
                      } else {
                        showCupertinoGlassToast(
                          context,
                          "Failed to update annual limit.",
                          isSuccess: false,
                          position: ToastPosition.top,
                        );
                      }
                    },
                    isSecurityOptionsLoading: isSecurityOptionsLoading,
                    ecommerceEnabled: isEcommerceEnabled ?? false,
                  ),
                ),

                // ✅ Section Title Security Settings (hide if cancelled)
                if (!isRequestSent && !isCardCancelled)
                  const SectionTitle(title: "Security Settings"),

                // ✅ Ecommerce Toggle (hidden if cancelled)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: (isRequestSent || isCardCancelled)
                      ? const SizedBox.shrink()
                      : Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      EcommerceToggle(
                        isBlocked: isBlocked,
                        isCardLocked: isCardLocked,
                        isEcommerceEnabled: isEcommerceEnabled ?? false,
                        onChanged: (val) async {
                          setState(() => isEcommerceEnabled = val);
                          try {
                            await SecurityOptionsService().updateSecurityOptions(
                              UpdateSecurityOptionRequest(
                                cardId: _cardModel!.id,
                                ecommerceEnabled: val,
                              ),
                            );
                            await _fetchEcommerceStatus();
                            showCupertinoGlassToast(
                              context,
                              "E-commerce status updated!",
                              isSuccess: true,
                              position: ToastPosition.top,
                            );
                          } catch (e) {
                            setState(() => isEcommerceEnabled = !val);
                            showCupertinoGlassToast(
                              context,
                              "Failed to update e-commerce status.",
                              isSuccess: false,
                              position: ToastPosition.top,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ✅ Block Card Section (hidden if cancelled)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: (isRequestSent || isCardCancelled)
                      ? const SizedBox.shrink()
                      : _buildBlockCardSection(),
                ),

                // ✅ Delete Card Section (still allowed to show after cancellation)
                DeleteCardSection(
                  isRequestSent: isRequestSent,
                  blockReasonLabel: blockReason?.label,
                  onDeleteTap: () => _initiateCardDeletion(),
                  buttonTitle: "Cancel Card",
                  isEnabled: !isCardCancelled,
                ),

                const SizedBox(height: 40),
              ],
            ),
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
          if (showPinPopup) PinPopup(
            show: showPinPopup,
            pin: "9241", // or your dynamic PIN
            countdown: countdown,
          ),

        ],
      ),
    );
  }

  Future<void> _confirmAndBlockCard() async {
    setState(() => isBlocked = true);
    try {
      if (blockReason == null || !blockReasonBackendValues.containsKey(blockReason!.label)) {
        throw Exception("Invalid block reason selected.");
      }

      final backendReason = blockReasonBackendValues[blockReason!.label]!;

      await SecurityOptionsService().blockVirtualCard(
        _cardModel!.id.toString(),
        BlockVirtualCardRequest(blockReason: backendReason),
      );

      showCupertinoGlassToast(
        context,
        "Card blocked successfully!",
        isSuccess: true,
        position: ToastPosition.top,
      );
    } catch (e) {
      setState(() => isBlocked = false);
      showCupertinoGlassToast(
        context,
        "Failed to block card.",
        isSuccess: false,
        position: ToastPosition.top,
      );
    }
  }
  void _syncBlockingState() {
    if (_cardModel == null) return;

    // ✅ Read directly from backend value now
    isCardCancelled = _cardModel!.isCanceled;

    if (isCardCancelled) {
      // 🔥 Fully reset blocking related states if card is cancelled
      isBlocked = false;
      blockReason = null;
      isJustBlockNowConfirmed = false;
      someoneTriedConfirmed = false;
      isAccountClosureConfirmed = false;
      showRequestNewCvv = false;
      requestSent = false;
      return;  // Exit early — nothing else to process
    }

    // If still active card, map normal states
    isBlocked = _cardModel!.status != 'ACTIVE';

    // Map backend reason to dropdown
    if (_cardModel!.blockReason != null) {
      final reasonLabel = blockReasonBackendValues.entries
          .firstWhere(
            (entry) => entry.value == _cardModel!.blockReason,
        orElse: () => const MapEntry('', ''),
      ).key;

      if (reasonLabel.isNotEmpty) {
        blockReason = blockReasons.firstWhere(
              (item) => item.label == reasonLabel,
        );
      }
    } else {
      blockReason = null;
    }

    // Update flags depending on backend reason
    isJustBlockNowConfirmed = _cardModel!.blockReason == "JUST_BLOCK_TEMPORARY";
    someoneTriedConfirmed = _cardModel!.blockReason == "FRAUD_SUSPECTED";
    isAccountClosureConfirmed = _cardModel!.blockReason == "CLOSING_ACCOUNT";
    showRequestNewCvv = _cardModel!.blockReason == "CVV_LEAK";
    requestSent = _cardModel?.replacementRequested == true;
  }

  void _startCardStatusPolling() {
    _cardStatusTimer?.cancel();
    _cardStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (isPendingReasonSelection) return; // ✅ Pause polling while reason selection active
      await _refreshCardStatus();
    });
  }


// Refresh card state directly from backend
  Future<void> _refreshCardStatus() async {
    if (widget.cardId == null) return;
    try {
      final card = await CardService().fetchCardById(widget.cardId!);
      if (!mounted) return;
      setState(() {
        _cardModel = card;
        selectedLimit = card.annualLimit;
        _syncBlockingState();  // Always resync flags
      });
    } catch (e) {
      // Optional: handle network or backend errors
    }
  }


}