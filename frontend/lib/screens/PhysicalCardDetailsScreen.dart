import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dto/card_dto/UpdatePhysicalCardLimitsRequest.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/OtpVerificationDialog.dart';
import '../widgets/PhysicalCard/card_info_section.dart';
import '../widgets/PhysicalCard/flippable_card.dart';
import '../widgets/PhysicalCard/helpers.dart';
import '../widgets/PhysicalCard/limit_section.dart';
import '../widgets/PhysicalCard/security_settings_section.dart';
import '../widgets/Toast.dart';
import '../widgets/UltraSwitch.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/card_service/card_service.dart';
import '../../services/card_service/CardSecurityService.dart';
import '../../dto/card_dto/card_model.dart';
import '../../dto/card_dto/PhysicalCardSecurityOption.dart';
import '../../dto/card_dto/UpdatePhysicalSecurityOptionRequest.dart';

//test
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

// ✅ ANTI-FLICKER APPROACH:
// - Security options are nullable and start as null
// - UI only shows toggles when _securityOptions != null (after first fetch)
// - No default values shown to user, preventing flicker
// - Periodic timer starts only after first successful fetch
// - If fetch fails, last successful data is preserved
class PhysicalCardDetailsScreen extends StatefulWidget {
  final bool autoScroll; // ✅ NEW
  final String? cardId;

  const PhysicalCardDetailsScreen({Key? key, this.cardId, this.autoScroll = false}) : super(key: key);

  @override
  State<PhysicalCardDetailsScreen> createState() => _PhysicalCardDetailsScreenState();
}

class _PhysicalCardDetailsScreenState extends State<PhysicalCardDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  bool showPinPopup = false;
  int cvvCountdown = 5;
  int pinCountdown = 5;
  bool isCvvRevealed = false;
  // bool isEcommerceEnabled = true;
  // bool isTpePaymentEnabled = true;
  // bool isInternationalWithdrawEnabled = true;
  DateTime? blockStartDate;
  DateTime? blockEndDate;
  bool showRequestCard = false;
  bool isPermanent = false;
  bool confirmedPermanentBlock = false;
  bool lostConfirmed = false;
  bool hasRequestedNewCard = false;
  DateTime? requestedNewCardDate;
  bool isCardDeleted = false;
  bool deleteRequestSent = false;
  bool isRequestSent = false;
  final String username = 'nada@example.com';
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool isPendingNewCardApproval = false;

  DropdownItem? selectedLimitType;
  DropdownItem? blockReason;

  final ScrollController _scrollController = ScrollController(); // << ADDED

  Timer? _refreshTimer; // << ADDED for periodic refresh
  Timer? _securityOptionsTimer; // << ADDED for security options refresh

  final List<DropdownItem> limitTypes = [
    DropdownItem(label: 'Daily Spending Limit', icon: Icons.calendar_today),
    DropdownItem(label: 'Monthly Spending Cap', icon: Icons.date_range),
    DropdownItem(label: 'Online Purchase Restriction',
        icon: Icons.shopping_cart_outlined),
  ];

  final List<DropdownItem> blockReasons = [
    DropdownItem(label: 'Permanent Block', value: 'PERMANENT_BLOCK', icon: Icons.cancel),
    DropdownItem(label: 'Card Lost – Cannot Find It', value: 'LOST', icon: Icons.report_gmailerrorred),
    DropdownItem(label: 'Card Stolen – Unauthorized Use', value: 'STOLEN', icon: Icons.lock_person),
    DropdownItem(label: 'Card Damaged – Not Functional', value: 'DAMAGED', icon: Icons.settings_backup_restore),
  ];


  double selectedLimit = 0.0;
  bool isBlocked = false;


  final Map<String, double> maxLimitByType = {
    'Daily Spending Limit': 1000,
    'Monthly Spending Cap': 10000,
    'Online Purchase Restriction': 2000,
  };
  final Gradient cardGradient = const LinearGradient(
    colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  CardModel? card;
  bool isLoading = true;
  String? errorMessage;
  bool showCvv = false;
  bool showCvvPopup = false;
  String? modalCvv;
  String? modalPin;
  PhysicalCardSecurityOption? _securityOptions; // ✅ Track when first fetch completes

  bool? isContactlessEnabled;
  bool? isEcommerceEnabled;
  bool? isTpePaymentEnabled;
  bool? isInternationalWithdrawEnabled;

  @override
  void initState() {
    super.initState();
    print("🔍 INIT_STATE - Starting initialization");
    print("🔍 INIT_STATE - cardId: ${widget.cardId}");
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    
    print("🔍 INIT_STATE - Calling _fetchCard");
    _fetchCard();
    print("🔍 INIT_STATE - _fetchCard called");
    
    // ✅ Start initial security options fetch (timer will start after first success)
    _fetchSecurityOptions();
    print("🔍 INIT_STATE - Initial security options fetch started");
  }

  Future<void> _fetchCard() async {
    print("🔍 _FETCH_CARD - Starting fetch");
    print("🔍 _FETCH_CARD - cardId: ${widget.cardId}");

    if (widget.cardId == null) {
      print("❌ _FETCH_CARD - No card ID provided");
      setState(() {
        isLoading = false;
        errorMessage = 'No card ID provided.';
      });
      return;
    }

    try {
      print("🔍 _FETCH_CARD - Calling CardService.fetchCardById");
      final fetchedCard = await CardService().fetchCardById(widget.cardId!);
      print("✅ _FETCH_CARD - Card fetched successfully");
      print("   status: ${fetchedCard.status}");
      print("   blockReason: ${fetchedCard.blockReason}");
      print("   replacementRequested: ${fetchedCard.replacementRequested}");

      setState(() {
        card = fetchedCard;
        isLoading = false;
        errorMessage = null;

        _cvvController.text = '•••';
        _pinController.text = '••••';

        if (selectedLimitType == null ||
            !limitTypes.any((item) => item.label == selectedLimitType!.label)) {
          selectedLimitType = limitTypes.first;
        }

        if (selectedLimitType != null && card != null) {
          switch (selectedLimitType!.label) {
            case 'Daily Spending Limit':
              selectedLimit = card!.dailyLimit;
              break;
            case 'Monthly Spending Cap':
              selectedLimit = card!.monthlyLimit;
              break;
            case 'Online Purchase Restriction':
              selectedLimit = card!.annualLimit;
              break;
          }
        }

        isBlocked = card!.status != 'ACTIVE';

        // 🟢 Determine if pending approval (NEW_REQUEST but no replacementRequested yet)
        isPendingNewCardApproval = card!.status == 'NEW_REQUEST' && !(card!.replacementRequested ?? false);

        if (isPendingNewCardApproval) {
          // Pending approval: show banner, disable flips, no block reason
          lostConfirmed = false;
          blockReason = null;
          showRequestCard = false;
          hasRequestedNewCard = false;
          requestedNewCardDate = null;
          print("✅ Detected pending approval scenario");
        }
        // 🟢 Handle LOST status (card is blocked, replacement not yet requested)
        else if (card!.status == 'LOST') {
          lostConfirmed = true;
          blockReason = blockReasons.firstWhere((b) => b.value == 'LOST');
          showRequestCard = true;
          hasRequestedNewCard = false; // ✅ Key fix: not requested yet
          requestedNewCardDate = null; // ✅ No delivery date yet
          print("✅ Detected LOST scenario - replacement not yet requested");
        }
        // 🟢 Handle DAMAGED status (card is blocked, replacement not yet requested)
        else if (card!.status == 'DAMAGED') {
          lostConfirmed = true;
          blockReason = blockReasons.firstWhere((b) => b.value == 'DAMAGED');
          showRequestCard = true;
          hasRequestedNewCard = false; // ✅ Key fix: not requested yet
          requestedNewCardDate = null; // ✅ No delivery date yet
          print("✅ Detected DAMAGED scenario - replacement not yet requested");
        }
        // 🟢 Handle NEW_REQUEST with replacementRequested = true (replacement was requested)
        else if (card!.status == 'NEW_REQUEST' && card!.replacementRequested == true) {
          lostConfirmed = true; // ✅ Keep lost confirmed so dropdown stays disabled
          
          // ✅ Determine the correct block reason based on the original reason
          if (card!.blockReason == 'DAMAGED') {
            blockReason = blockReasons.firstWhere((b) => b.value == 'DAMAGED');
          } else {
            blockReason = blockReasons.firstWhere((b) => b.value == 'LOST');
          }
          
          showRequestCard = true;
          hasRequestedNewCard = true;
          print("✅ Detected NEW_REQUEST+replacementRequested scenario");
        }
        // 🟢 Map other block reasons (STOLEN, DAMAGED, PERMANENT_BLOCK)
        else if (card!.blockReason != null) {
          final matching = blockReasons.where((item) => item.value == card!.blockReason);
          if (matching.isNotEmpty) {
            blockReason = matching.first;
          } else {
            blockReason = null;
          }
          lostConfirmed = card!.blockReason == 'LOST' || card!.blockReason == 'STOLEN' || card!.blockReason == 'DAMAGED';
          showRequestCard = lostConfirmed || card!.blockReason == 'PERMANENT_BLOCK';
          hasRequestedNewCard = card!.replacementRequested == true;
        }
        // 🟢 No block reason and no special state
        else {
          blockReason = null;
          lostConfirmed = false;
          showRequestCard = false;
          hasRequestedNewCard = false;
          requestedNewCardDate = null;
        }

        // 🟢 Expected delivery date logic
        if (hasRequestedNewCard) {
          if (card!.blockEndDate != null && card!.blockEndDate!.isNotEmpty) {
            requestedNewCardDate = DateTime.tryParse(card!.blockEndDate!);
            print("🔍 Using backend delivery date: ${card!.blockEndDate}");
          }
          if (requestedNewCardDate == null) {
            requestedNewCardDate = DateTime.now().add(const Duration(days: 7));
            print("🔍 Using default delivery date: $requestedNewCardDate");
          }
        } else {
          requestedNewCardDate = null;
        }

        isPermanent = card!.blockReason == 'PERMANENT_BLOCK' || lostConfirmed;
        confirmedPermanentBlock = card!.blockReason == 'PERMANENT_BLOCK';

        // Reset delete state if card is active
        if (!isBlocked) {
          isCardDeleted = false;
          deleteRequestSent = false;
          isRequestSent = false;
        }

        print("✅ Final state:");
        print("   isBlocked: $isBlocked");
        print("   blockReason: ${blockReason?.label}");
        print("   lostConfirmed: $lostConfirmed");
        print("   showRequestCard: $showRequestCard");
        print("   hasRequestedNewCard: $hasRequestedNewCard");
        print("   isPendingNewCardApproval: $isPendingNewCardApproval");
        print("   requestedNewCardDate: $requestedNewCardDate");
      });
    } catch (e) {
      print("❌ _FETCH_CARD - Error: $e");
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchSecurityOptions() async {
    if (widget.cardId == null) return;

    try {
      print("🔍 _FETCH_SECURITY_OPTIONS - Starting fetch");
      final securityOptions = await SecurityOptionsService().fetchPhysicalCardSecurityOptionById(widget.cardId!);
      
      setState(() {
        isContactlessEnabled = securityOptions.contactlessEnabled;
        isEcommerceEnabled = securityOptions.ecommerceEnabled;
        isTpePaymentEnabled = securityOptions.tpeEnabled;
        isInternationalWithdrawEnabled = securityOptions.internationalWithdrawEnabled;
        _securityOptions = securityOptions;
      });
      
      // ✅ Start periodic refresh only after first successful fetch
      if (_securityOptionsTimer == null) {
        _startSecurityOptionsTimer();
        print("✅ _FETCH_SECURITY_OPTIONS - Started periodic timer");
      }
      
      print("✅ _FETCH_SECURITY_OPTIONS - Updated state:");
      print("   contactless: $isContactlessEnabled");
      print("   ecommerce: $isEcommerceEnabled");
      print("   tpe: $isTpePaymentEnabled");
      print("   international: $isInternationalWithdrawEnabled");
    } catch (e) {
      print("❌ _FETCH_SECURITY_OPTIONS - Error: $e");
      // Don't show error to user, just log it
    }
  }

  void _flipCard() {
    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is currently blocked. Flip disabled.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    if (isPendingNewCardApproval) {
      showCupertinoGlassToast(
        context,
        "Your new card is pending approval. Card interactions are disabled.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    setState(() {
      isFront = !isFront;
      if (isFront) {
        showCvv = false; // Always hide CVV when flipping to front
      }
    });
    if (isFront) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }
  void _revealCVV() {
    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is currently blocked. CVV access denied.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    if (isPendingNewCardApproval) {
      showCupertinoGlassToast(
        context,
        "Your new card is pending approval. CVV and PIN are not available.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    setState(() {
      showCvvPopup = true;
      cvvCountdown = 5;
      modalCvv = card?.cvv ?? '';
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        cvvCountdown--;
        if (cvvCountdown == 0) {
          showCvvPopup = false;
          timer.cancel();
        }
      });
    });
  }
  void _revealPINPopup() {
    if (isBlocked) {
      showCupertinoGlassToast(
        context,
        "Card is currently blocked. PIN access denied.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    if (isPendingNewCardApproval) {
      showCupertinoGlassToast(
        context,
        "Your new card is pending approval. CVV and PIN are not available.",
        isSuccess: false,
        position: ToastPosition.top,
      );
      return;
    }
    
    setState(() {
      showPinPopup = true;
      pinCountdown = 5;
      modalPin = card?.pin ?? '';
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        pinCountdown--;
        if (pinCountdown == 0) {
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
  Future<void> _pickBlockDates() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // normalize

    // Step 1: Show iOS-style warning popup before calendar
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF2F2F5), Color(0xFFEAEAEC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                "Temporary Block Limit",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "You can only block your card temporarily for up to 30 days. The start date is always today.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
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
                      onPressed: () => Navigator.pop(context, false),
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
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    DateTime? tempEnd;
    DateTime focusedDay = today.add(const Duration(days: 1));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Text("Select End Date",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TableCalendar(
                      firstDay: today,
                      lastDay: today.add(const Duration(days: 30)),
                      focusedDay: focusedDay,
                      rangeStartDay: today,
                      rangeEndDay: tempEnd,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focused) {
                        if (selectedDay.difference(today).inDays > 30) {
                          showCupertinoGlassToast(
                            context,
                            "End date must be within 30 days.",
                            isSuccess: false,
                            position: ToastPosition.top,
                          );
                          return;
                        }
                        setModalState(() {
                          focusedDay = focused;
                          tempEnd = selectedDay;
                        });
                      },
                      selectedDayPredicate: (_) => false,
                      onPageChanged: (focused) => setModalState(() => focusedDay = focused),
                      calendarStyle: CalendarStyle(
                        rangeHighlightColor: Colors.blueAccent.withOpacity(0.25),
                        rangeStartDecoration: const BoxDecoration(
                          color: Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: const BoxDecoration(
                          color: Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        dateLabel("Start", today),
                        if (tempEnd != null) dateLabel("End", tempEnd!),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: ElevatedButton(
                        onPressed: tempEnd != null
                            ? () async {
                          final diff = tempEnd!.difference(today).inDays;
                          if (diff > 30) {
                            showCupertinoGlassToast(
                              context,
                              "End date must be within 30 days.",
                              isSuccess: false,
                              position: ToastPosition.top,
                            );
                            return;
                          }

                          setState(() {
                            blockStartDate = today;
                            blockEndDate = tempEnd!;
                          });

                          Navigator.pop(context); // Close sheet first
                          await Future.delayed(const Duration(milliseconds: 200));

                          if (context.mounted) {
                            showGeneralDialog(
                              context: context,
                              barrierLabel: "Card Temporarily Blocked",
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.35),
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return const SizedBox(); // Not used
                              },
                              transitionBuilder: (context, animation, secondaryAnimation, _) {
                                final curved = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                  reverseCurve: Curves.easeInCubic,
                                );

                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1.0),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFf5f5f7), Color(0xFFe3e3e5)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(28),
                                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.06),
                                                blurRadius: 18,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
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
                                                child: const Icon(Icons.lock_clock_rounded, size: 72, color: Colors.redAccent),
                                              ),
                                              const SizedBox(height: 24),
                                              const Text(
                                                "Card Temporarily Blocked",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF1C1C1E),
                                                  letterSpacing: -0.3,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16),
                                              RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF3A3A3C),
                                                    height: 1.5,
                                                  ),
                                                  children: [
                                                    const TextSpan(text: "Your "),
                                                    TextSpan(
                                                      text: "Physical Card",
                                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                                    ),
                                                    const TextSpan(text: " will be temporarily blocked\nfrom "),
                                                    TextSpan(
                                                      text: "${today.toString().split(' ')[0]}",
                                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                                    ),
                                                    const TextSpan(text: " to "),
                                                    TextSpan(
                                                      text: "${tempEnd!.toString().split(' ')[0]}",
                                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                                    ),
                                                    const TextSpan(
                                                      text: ".\n\nAll transactions will be restricted during this period.",
                                                      style: TextStyle(color: Color(0xFF636366)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 18),
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
                                                        Text("Card Type", style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
                                                        Text("Visa", style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF007AFF),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "OK, Got it",
                                                    style: TextStyle(fontSize: 16.2, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tempEnd != null ? const Color(0xFF3A3A3C) : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Confirm", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

  }
  Widget _buildInput(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isObscured = false,
        VoidCallback? onTapSuffix,
        IconData? suffixIcon,
      }) {
    return buildLabeledField(
      label,
      TextField(
        controller: controller,
        readOnly: true,
        obscureText: isObscured,
        maxLength: 4, // <-- Add this line
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
          ),
          suffixIcon: (onTapSuffix != null && !isRequestSent)
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
    final cardNumber = "1234 5678 9012 3456";
    final maskedCardNumber = isRequestSent
        ? '**** **** *** ${cardNumber.substring(cardNumber.length - 3)}'
        : cardNumber;

    final expiryDate = isRequestSent ? '**/**' : '08/26';
    final cvv = isRequestSent ? '•••' : _cvvController.text;
    final pin = isRequestSent ? '••••' : _pinController.text;

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

        if (!isRequestSent)
          _buildInput(
            "Expiry Date",
            TextEditingController(text: expiryDate),
            Icons.calendar_today,
          ),

        if (!isRequestSent)
          _buildInput(
            "CVV",
            TextEditingController(text: cvv),
            Icons.lock_outline,
            isObscured: false,
            onTapSuffix: _revealCVV,
            suffixIcon: isCvvRevealed
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
          ),

        if (!isRequestSent)
          _buildInput(
            "PIN",
            TextEditingController(text: pin),
            Icons.key,
            isObscured: true,
            // Remove onTapSuffix if you don't want to reveal PIN
            // Add maxLength: 4 to the TextField
          ),
      ],
    );
  }
  Widget _buildLimitSection() {
    final double maxLimit =
    selectedLimitType != null ? (maxLimitByType[selectedLimitType!.label] ?? 5000) : 5000;

    final isInteractionsDisabled = isBlocked || isPendingNewCardApproval;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Manage Limits"),

        Opacity(
          opacity: isInteractionsDisabled ? 0.4 : 1,
          child: IgnorePointer(
            ignoring: isInteractionsDisabled,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CustomDropdown(
                icon: Icons.tune,
                selectedItem: selectedLimitType,
                items: limitTypes,
                onChanged: (value) async {
                  setState(() {
                    selectedLimitType = value;
                    selectedLimit = min(selectedLimit, maxLimitByType[value.label] ?? 500);
                  });
                  _scrollToBottom();
                },
                label: '',
              ),
            ),
          ),
        ),

        if (selectedLimitType != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Opacity(
              opacity: isInteractionsDisabled ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: isInteractionsDisabled,
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
                            "Spending Limit",
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
                                  final fade = FadeTransition(opacity: animation, child: child);
                                  final slide = SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: fade,
                                  );
                                  return slide;
                                },
                                child: Text(
                                  "\$${(isInteractionsDisabled ? 0 : selectedLimit).toInt()}",
                                  key: ValueKey<int>((isInteractionsDisabled ? 0 : selectedLimit).toInt()),
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
                                    "Max: \$${maxLimit.toInt()}",
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
                        isInteractionsDisabled ? 0 : selectedLimit,
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
  void _showPermanentBlockDialog() {
    if (!context.mounted) return;

    showGeneralDialog(
      context: context,
      barrierLabel: "Permanent Block",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5F5F7), Color(0xFFE3E3E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
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
                        child: const Icon(Icons.cancel_rounded, size: 64, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Permanent Block Activated",
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
                          "This card will be permanently disabled.\nAll transactions and actions will be blocked.",
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
                                Text("Disabled", style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w700, color: Colors.redAccent)),
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
                                  isPermanent = false;
                                  confirmedPermanentBlock = false;
                                  showRequestCard = false;
                                  blockStartDate = null;
                                  blockEndDate = null;
                                });

                                showCupertinoGlassToast(
                                  context,
                                  "Block cancelled. Card active.",
                                  isSuccess: true,
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
                                
                                print("🔍 Permanent Block Dialog - blockReason: ${blockReason?.label}");
                                print("🔍 Permanent Block Dialog - blockReason value: ${blockReason?.value}");
                                
                                // Call the service to block the card
                                if (widget.cardId != null && blockReason?.value != null) {
                                  try {
                                    print("🔒 Permanent Block - Card ID: ${widget.cardId}");
                                    print("🔒 Permanent Block - Reason: ${blockReason!.value}");
                                    
                                    await SecurityOptionsService().blockPhysicalCard(
                                      widget.cardId!,
                                      blockReason!.value!,
                                    );
                                    
                                    showCupertinoGlassToast(
                                      context,
                                      "Card blocked successfully!",
                                      isSuccess: true,
                                      position: ToastPosition.top,
                                    );
                                  } catch (e) {
                                    print("❌ Permanent Block failed: $e");
                                    showCupertinoGlassToast(
                                      context,
                                      "Failed to block card: ${e.toString()}",
                                      isSuccess: false,
                                      position: ToastPosition.top,
                                    );
                                  }
                                } else {
                                  print("❌ Permanent Block - Missing cardId or reason value");
                                  print("❌ CardId: ${widget.cardId}");
                                  print("❌ Reason value: ${blockReason?.value}");
                                }
                              },
                              child: const Text("Understood", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
  void _showRequestConfirmationDialog() {
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
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F5F8), Color(0xFFE3E3E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE6FDEB), Color(0xFFC9F0D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mark_email_read_outlined, size: 44, color: Colors.green),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    "Request Confirmed",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _iosInfoSpan("Cardholder", "Nada S. Rhandor"),
                      _iosInfoSpan("Card", "•••• •••• •••• 345"),
                      _iosInfoSpan("Phone", "+212 777****333"),
                      _iosInfoSpan("Email", "rhalimsami8@gmail.com"),
                    ],
                  )
                  ,

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "You'll receive an email once your new card is ready for pickup at your agency.",
                      style: TextStyle(
                        fontSize: 14.7,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3A3A3C),
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        "Got it",
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                      ),
                    ),
                  ),
                ]
                ,
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showCardLostDialogs({required String reasonLabel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8F8FB), Color(0xFFEFEFF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 46, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    reasonLabel == 'Card Stolen – Unauthorized Use'
                        ? "Card Reported as Stolen"
                        : "Card Reported as Lost",
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    reasonLabel == 'Card Stolen – Unauthorized Use'
                        ? "Hello Nada S. Rhandor,\n\nWe've marked your card as stolen for security. This action has been forwarded to our fraud investigation team."
                        : "Hello Nada S. Rhandor,\n\nWe've marked your card as lost for security. This action has been forwarded to our internal fraud and card issuance department.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "To continue safely, you may request a new card. You'll receive a confirmation email and be invited to retrieve your new card from the nearest banking agency.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.5, color: Colors.black54, height: 1.55),
                  ),
                  const SizedBox(height: 26),
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
                              showRequestCard = false;
                              confirmedPermanentBlock = false;
                            });
                            showCupertinoGlassToast(
                              context,
                              "Block cancelled. Card restored.",
                              isSuccess: true,
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
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            
                            print("🔍 Card Lost Dialog - reasonLabel: $reasonLabel");
                            print("🔍 Card Lost Dialog - blockReason before: ${blockReason?.label}");
                            
                            // Get the selected reason with its value
                            final selectedReason = blockReasons.firstWhere((item) => item.label == reasonLabel);
                            print("🔍 Card Lost Dialog - selectedReason value: ${selectedReason.value}");
                            
                            setState(() {
                              lostConfirmed = true;
                              blockReason = selectedReason;
                              isBlocked = true;
                              showRequestCard = true;
                              blockStartDate = null;
                              blockEndDate = null;
                              isPermanent = true;
                              confirmedPermanentBlock = false;
                            });
                            
                            print("🔍 Card Lost Dialog - blockReason after: ${blockReason?.label}");
                            print("🔍 Card Lost Dialog - blockReason value after: ${blockReason?.value}");
                            
                            // Call the service to block the card
                            if (widget.cardId != null && selectedReason.value != null) {
                              try {
                                print("🔒 Card Lost/Stolen/Damaged - Card ID: ${widget.cardId}");
                                print("🔒 Card Lost/Stolen/Damaged - Reason: ${selectedReason.value}");
                                
                                await SecurityOptionsService().blockPhysicalCard(
                                  widget.cardId!,
                                  selectedReason.value!,
                                );
                                
                                showCupertinoGlassToast(
                                  context,
                                  "Card blocked successfully!",
                                  isSuccess: true,
                                  position: ToastPosition.top,
                                );
                              } catch (e) {
                                print("❌ Card Lost/Stolen/Damaged failed: $e");
                                showCupertinoGlassToast(
                                  context,
                                  "Failed to block card: ${e.toString()}",
                                  isSuccess: false,
                                  position: ToastPosition.top,
                                );
                              }
                            } else {
                              print("❌ Card Lost/Stolen/Damaged - Missing cardId or reason value");
                              print("❌ CardId: ${widget.cardId}");
                              print("❌ Reason value: ${selectedReason.value}");
                            }
                            
                            _scrollToBottom();
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
        ),
      ),
    );
  }
  Color _limitColor(double value) {
    if (value <= 1000) return const Color(0xFF34C759);
    if (value <= 3000) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }
  Widget _buildRequestNewCardButton({bool iOSStyle = false}) {
    final bool isSent = hasRequestedNewCard;

    return Container(
      decoration: BoxDecoration(
        color: iOSStyle ? const Color(0xFFE5E5EA) : null,
        gradient: iOSStyle
            ? null
            : const LinearGradient(
          colors: [Color(0xFF72B2FF), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iOSStyle ? const Color(0xFFB3B3B7) : Colors.transparent,
          width: 0.9,
        ),
        boxShadow: iOSStyle
            ? []
            : [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSent
            ? null
            : () async {
          _showRequestConfirmationDialog();

          if (widget.cardId == null) {
            showCupertinoGlassToast(
              context,
              "Card ID not available. Please try again.",
              isSuccess: false,
              position: ToastPosition.top,
            );
            return;
          }

          try {
            bool success = false;

            // ✅ Check blockReason and call the appropriate service
            if (blockReason?.value == 'STOLEN') {
              success = await CardService()
                  .requestPhysicalCardReplacementDueToStolen(widget.cardId!);
            } else if (blockReason?.value == 'DAMAGED') {
              success = await CardService()
                  .requestPhysicalCardReplacementDueToDamaged(widget.cardId!);
            } else {
              success = await CardService()
                  .requestPhysicalCardReplacementDueToLoss(widget.cardId!);
            }

            if (success) {
              await _fetchCard();

              setState(() {
                hasRequestedNewCard = card?.replacementRequested == true;

                // Retain the block reason after refresh
                if (blockReason?.value == 'STOLEN') {
                  blockReason =
                      blockReasons.firstWhere((b) => b.value == 'STOLEN');
                } else if (blockReason?.value == 'DAMAGED') {
                  blockReason =
                      blockReasons.firstWhere((b) => b.value == 'DAMAGED');
                } else {
                  blockReason =
                      blockReasons.firstWhere((b) => b.value == 'LOST');
                }

                requestedNewCardDate =
                (card?.blockEndDate != null && card!.blockEndDate!.isNotEmpty)
                    ? DateTime.tryParse(card!.blockEndDate!)
                    : DateTime.now().add(const Duration(days: 7));
              });

              showCupertinoGlassToast(
                context,
                "Replacement request sent successfully!",
                isSuccess: true,
                position: ToastPosition.top,
              );
            } else {
              showCupertinoGlassToast(
                context,
                "Failed to send replacement request. Please try again.",
                isSuccess: false,
                position: ToastPosition.top,
              );
            }
          } catch (e) {
            print("❌ Request replacement failed: $e");
            showCupertinoGlassToast(
              context,
              "Failed to send replacement request: ${e.toString()}",
              isSuccess: false,
              position: ToastPosition.top,
            );
          }
        },
        icon: Icon(
          Icons.credit_card_rounded,
          size: 20,
          color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
        ),
        label: Text(
          isSent ? "Request Sent" : "Request New Card",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: isSent ? 0 : 4,
          backgroundColor: isSent
              ? const Color(0xFFF2F2F7)
              : (iOSStyle
              ? Colors.white.withOpacity(0.85)
              : const Color(0xFF007AFF)),
          shadowColor: isSent ? Colors.transparent : Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSent
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide(
              color: iOSStyle
                  ? const Color(0xFFE5E5EA)
                  : Colors.transparent,
            ),
          ),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRequestDamagedCardButton({bool iOSStyle = false}) {
    final bool isSent = hasRequestedNewCard;

    return Container(
      decoration: BoxDecoration(
        color: iOSStyle ? const Color(0xFFE5E5EA) : null,
        gradient: iOSStyle
            ? null
            : const LinearGradient(
          colors: [Color(0xFF72B2FF), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iOSStyle ? const Color(0xFFB3B3B7) : Colors.transparent,
          width: 0.9,
        ),
        boxShadow: iOSStyle
            ? []
            : [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSent
            ? null
            : () async {
          // Show confirmation dialog first
          _showRequestConfirmationDialog();

          if (widget.cardId == null) {
            showCupertinoGlassToast(
              context,
              "Card ID not available. Please try again.",
              isSuccess: false,
              position: ToastPosition.top,
            );
            return;
          }

          try {
            bool success = false;

            // ✅ Decide which service to call
            if (blockReason?.value == 'STOLEN') {
              success = await CardService().requestPhysicalCardReplacementDueToStolen(widget.cardId!);
            } else if (blockReason?.value == 'DAMAGED') {
              success = await CardService().requestPhysicalCardReplacementDueToDamaged(widget.cardId!);
            } else {
              success = await CardService().requestPhysicalCardReplacementDueToLoss(widget.cardId!);
            }

            if (success) {
              // Refresh card data to get updated backend state
              await _fetchCard();

              setState(() {
                hasRequestedNewCard = card?.replacementRequested == true;
                lostConfirmed = true;

                // Keep the selected reason visible
                if (blockReason == null && card?.status == 'NEW_REQUEST') {
                  blockReason = blockReasons.firstWhere(
                        (b) => b.value == 'LOST' || b.value == 'STOLEN',
                    orElse: () => blockReasons.first,
                  );
                }

                // Use backend date or fallback
                requestedNewCardDate =
                (card?.blockEndDate != null && card!.blockEndDate!.isNotEmpty)
                    ? DateTime.tryParse(card!.blockEndDate!)
                    : DateTime.now().add(const Duration(days: 7));
              });

              showCupertinoGlassToast(
                context,
                "Replacement request sent successfully!",
                isSuccess: true,
                position: ToastPosition.top,
              );
            } else {
              showCupertinoGlassToast(
                context,
                "Failed to send replacement request. Please try again.",
                isSuccess: false,
                position: ToastPosition.top,
              );
            }
          } catch (e) {
            print("❌ Request replacement failed: $e");
            showCupertinoGlassToast(
              context,
              "Failed to send replacement request: ${e.toString()}",
              isSuccess: false,
              position: ToastPosition.top,
            );
          }
        },
        icon: Icon(
          Icons.construction_rounded,
          size: 20,
          color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
        ),
        label: Text(
          isSent ? "Request Sent" : "Request Card for Damage",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: isSent ? 0 : 4,
          backgroundColor: isSent
              ? const Color(0xFFF2F2F7)
              : (iOSStyle ? Colors.white.withOpacity(0.85) : const Color(0xFF007AFF)),
          shadowColor: isSent ? Colors.transparent : Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSent
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide(color: iOSStyle ? const Color(0xFFE5E5EA) : Colors.transparent),
          ),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  Widget _iosInfoSpan(String label, String value) {
    return SizedBox(
      width: 220, // Fixed width to align all spans equally
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center( // 🔥 Center the text
          child: RichText(
            textAlign: TextAlign.center, // Also center multiline text if needed
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    color: Color(0xFF8E8E93), // iOS muted grey
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCardDeliveryInfo() {
    return Container(
      width: 360, // ✅ Fixed width to match button
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // ✅ Match the soft glass look
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ E-banking icons row for consistency
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconCircle(Icons.credit_card),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.lock_outline),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.access_time),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.account_balance_wallet),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "New Card Request Confirmed",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We've received your request for a new card. It is currently being prepared and should be available in your account soon. You will be notified when it's ready.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3C3C43),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Text(
              "Expected after ${_formatDate(requestedNewCardDate!)}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalInfoBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // darker to match inputs
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // E-banking icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconCircle(Icons.credit_card),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.lock_outline),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.access_time),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.account_balance_wallet),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Replacement Card is On the Way",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We've received your request for a replacement card due to loss. Your new card will be prepared shortly and should be available in your account within 7–10 business days. You can continue using e-banking services without interruption.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3C3C43),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

// Helper for icons with a slightly darker color
  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Color(0xFF4A4A4D), // slightly darker icon
        size: 20,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.autoScroll) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
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
                  child: Text(
                    "Block this card",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                UltraSwitch(
                  value: isBlocked,
                  onChanged: (val) async {
                    final today = DateTime.now();

                    // 🛑 1. Prevent disabling if card is marked lost, stolen, or damaged
                    final criticalReasons = [
                      'Card Lost – Cannot Find It',
                      'Card Stolen – Unauthorized Use',
                      'Card Damaged – Not Functional',
                    ];

                    if (!val && lostConfirmed && criticalReasons.contains(blockReason?.label)) {
                      String reasonText;

                      if (blockReason!.label.contains("Lost")) {
                        reasonText = "Card is lost. It stays blocked until your new card request is approved.";
                      } else if (blockReason!.label.contains("Stolen")) {
                        reasonText = "Card is stolen. It stays blocked until your replacement card request is approved.";
                      } else if (blockReason!.label.contains("Damaged")) {
                        reasonText = "Card is damaged. It stays blocked until your replacement card is ready.";
                      } else {
                        reasonText = "This card issue requires it to remain blocked until resolved.";
                      }

                      showCupertinoGlassToast(
                        context,
                        reasonText,
                        isSuccess: false,
                        position: ToastPosition.top,
                      );
                      return;
                    }










                    // 🛑 2. Prevent unblocking if Temporary Block not finished
                    if (!val && blockReason != null) {
                      // ✅ 3. Standard unblock confirmation modal
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF2F2F5), Color(0xFFEAEAEC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
                                const SizedBox(height: 16),
                                const Text(
                                  "Unblock Card",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Turning off the block will cancel the reason:\n\n",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                      ),
                                      TextSpan(
                                        text: "🛑  ${blockReason!.label}",
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.redAccent,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
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
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          
                                          try {
                                            // ✅ Call backend service to unblock the card
                                            await SecurityOptionsService().unblockPhysicalCard(widget.cardId!);
                                            
                                            // ✅ Update local state
                                            setState(() {
                                              isBlocked = false;
                                              blockReason = null;
                                              blockStartDate = null;
                                              blockEndDate = null;
                                              isPermanent = false;
                                              showRequestCard = false;
                                              lostConfirmed = false;
                                            });

                                            // ✅ Show success toast
                                            if (mounted) {
                                              showCupertinoGlassToast(
                                                context,
                                                "Card unblocked successfully!",
                                                isSuccess: true,
                                                position: ToastPosition.top,
                                              );
                                            }
                                          } catch (e) {
                                            print("❌ Unblock card failed: $e");
                                            
                                            // ✅ Show error toast
                                            if (mounted) {
                                              showCupertinoGlassToast(
                                                context,
                                                "Failed to unblock card. Please try again.",
                                                isSuccess: false,
                                                position: ToastPosition.top,
                                              );
                                            }
                                          }
                                        },
                                        child: const Text("Unblock", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // ✅ 4. Toggle ON logic
                      setState(() {
                        isBlocked = val;

                        if (val) {
                          _scrollToBottom();
                          if (blockReason != null) {
                            _startRefreshTimer(); // Start periodic refresh when blocked and reason selected
                          }
                          if (blockReason == null) {
                            Future.delayed(const Duration(milliseconds: 300), () {
                              showCupertinoGlassToast(
                                context,
                                "You must choose a reason within 10 minutes or the block will be cancelled.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            });

                            Future.delayed(const Duration(minutes: 10), () {
                              if (mounted && blockReason == null && isBlocked) {
                                setState(() => isBlocked = false);
                                _stopRefreshTimer(); // Stop timer if block is cancelled
                                showCupertinoGlassToast(
                                  context,
                                  "Blocking has been cancelled due to no reason being selected.",
                                  isSuccess: false,
                                  position: ToastPosition.top,
                                );
                              }
                            });
                          }
                        } else {
                          _stopRefreshTimer(); // Stop periodic refresh when unblocked
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isBlocked
              ? Column(
            children: [
              buildLabeledField(
                "Reason for Blocking",
                Column(
                  children: [
                    AbsorbPointer(
                      absorbing: confirmedPermanentBlock && blockReason?.label == 'Permanent Block',
                      child:Opacity(
                        opacity: lostConfirmed ? 0.5 : 1.0, // ✅ Disable if lost confirmed (even after request)
                        child: IgnorePointer(
                          ignoring: lostConfirmed, // ✅ Disable interaction if lost confirmed (even after request)
                          child: CustomDropdown(
                            key: ValueKey(blockReason?.label ?? 'none'),
                            icon: Icons.warning_amber_rounded,
                            selectedItem: blockReason,
                            items: blockReasons,
                            onChanged: (value) async {
                              final today = DateTime.now();

                              final isPermanentSelected = blockReason?.label == 'Permanent Block';
                              final isLostStolenDamaged = blockReason?.label == 'Card Lost – Cannot Find It' ||
                                  blockReason?.label == 'Card Stolen – Unauthorized Use' ||
                                  blockReason?.label == 'Card Damaged – Not Functional';

                              final isTryingToChangeFromPermanent =
                                  isPermanentSelected && value.label != 'Permanent Block' && confirmedPermanentBlock && isBlocked;
                              final isTryingToChangeFromSpecial =
                                  isLostStolenDamaged && value.label != blockReason?.label;

                              if (isTryingToChangeFromPermanent) {
                                showCupertinoGlassToast(
                                  context,
                                  "To change the reason, please turn off the 'Block this card' option first.",
                                  isSuccess: false,
                                  position: ToastPosition.top,
                                );
                                return;
                              }

                              if (isTryingToChangeFromSpecial) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Clear the current block reason before selecting another."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              if (value.label == 'Permanent Block') {
                                print("🔍 Permanent Block selected - value: ${value.value}");
                                _showPermanentBlockDialog();
                                setState(() {
                                  blockReason = value;
                                  isPermanent = true;
                                  confirmedPermanentBlock = true;
                                  showRequestCard = false;
                                  blockStartDate = null;
                                  blockEndDate = null;
                                });
                                print("🔍 blockReason set to: ${blockReason?.value}");
                                return;
                              }

                              if (value.label == 'Card Lost – Cannot Find It' ||
                                  value.label == 'Card Stolen – Unauthorized Use' ||
                                  value.label == 'Card Damaged – Not Functional') {
                                print("🔍 Card Lost/Stolen/Damaged selected - value: ${value.value}");
                                setState(() {
                                  blockReason = value;
                                });
                                print("🔍 blockReason set to: ${blockReason?.value}");
                                _showCardLostDialogs(reasonLabel: value.label); // 👈 Reuse the same modal
                                return;
                              }
                              setState(() {
                                blockReason = value;
                                isPermanent = true;
                                showRequestCard = true;
                                confirmedPermanentBlock = false;
                                blockStartDate = null;
                                blockEndDate = null;
                              });
                              if (isBlocked && blockReason != null) {
                                _startRefreshTimer();
                              }
                              Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
                            },
                            label: '',
                          ),
                        ),
                      ),
                    ),

                    if (blockReason != null || blockStartDate != null || blockEndDate != null)
                      ...[
                        const SizedBox(height: 12),
                        // Warning for Permanent or Request Card
                        if ((isPermanent || showRequestCard) && blockReason?.label != 'Temporary Block')
                          Builder(
                            builder: (context) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFE8E8), Color(0xFFFFD1D1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "This card will be permanently deactivated.",
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        // Request New Card Button and Delivery Span - SIMPLIFIED LOGIC
                        if (lostConfirmed || hasRequestedNewCard) ...[
                          // Show appropriate button based on backend reason
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: double.infinity,
                                ),
                                child: _buildRequestNewCardButton(iOSStyle: false),
                              ),
                            ),
                          ),
                          // Show delivery info if request was made
                          if (hasRequestedNewCard && requestedNewCardDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Center(
                                child: _buildCardDeliveryInfo(),
                              ),
                            ),
                        ],
                      ]
                  ],
                ),
              ),
            ],
          )
              : const SizedBox.shrink(key: ValueKey("empty")),
        )
      ],
    );
  }
  Widget _buildRequestReplacementCardButton({bool iOSStyle = false}) {
    final bool isSent = hasRequestedNewCard;

    return Container(
      decoration: BoxDecoration(
        color: iOSStyle ? const Color(0xFFE5E5EA) : null,
        gradient: iOSStyle
            ? null
            : const LinearGradient(
          colors: [Color(0xFF72B2FF), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iOSStyle ? const Color(0xFFB3B3B7) : Colors.transparent,
          width: 0.9,
        ),
        boxShadow: iOSStyle
            ? []
            : [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSent
            ? null
            : () async {
          // Show confirmation dialog first
          _showRequestConfirmationDialog();
          
          // Call the service to request replacement
          if (widget.cardId != null) {
            try {
              final success = await CardService().requestPhysicalCardReplacementDueToLoss(widget.cardId!);
              
              if (success) {
                setState(() {
                  hasRequestedNewCard = true;
                  // Use backend date if available, otherwise estimate 7 days from now
                  requestedNewCardDate = DateTime.tryParse(card?.blockEndDate ?? '') ?? DateTime.now().add(const Duration(days: 7));
                });
                
                // Refresh card data to get updated backend state
                await _fetchCard();
                
                showCupertinoGlassToast(
                  context,
                  "Replacement request sent successfully!",
                  isSuccess: true,
                  position: ToastPosition.top,
                );
              } else {
                showCupertinoGlassToast(
                  context,
                  "Failed to send replacement request. Please try again.",
                  isSuccess: false,
                  position: ToastPosition.top,
                );
              }
            } catch (e) {
              print("❌ Request replacement failed: $e");
              showCupertinoGlassToast(
                context,
                "Failed to send replacement request: ${e.toString()}",
                isSuccess: false,
                position: ToastPosition.top,
              );
            }
          } else {
            showCupertinoGlassToast(
              context,
              "Card ID not available. Please try again.",
              isSuccess: false,
              position: ToastPosition.top,
            );
          }
        },
        icon: Icon(
          Icons.credit_card_rounded,
          size: 20,
          color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
        ),
        label: Text(
          isSent ? "Request Sent" : "Request Replacement Card",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: isSent ? Colors.grey[400] : (iOSStyle ? Colors.black : Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: isSent ? 0 : 4,
          backgroundColor: isSent
              ? const Color(0xFFF2F2F7)
              : (iOSStyle ? Colors.white.withOpacity(0.85) : const Color(0xFF007AFF)),
          shadowColor: isSent ? Colors.transparent : Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSent
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide(color: iOSStyle ? const Color(0xFFE5E5EA) : Colors.transparent),
          ),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  Widget _buildContactlessToggle() {
    final isDisabled = isBlocked || isPendingNewCardApproval;

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
                Icon(Icons.nfc, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Contactless Payments",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                UltraSwitch(
                  value: isDisabled ? false : (isContactlessEnabled ?? false),
                  onChanged: (val) {
                    setState(() => isContactlessEnabled = val);
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
  Widget _buildEcommerceToggle() {
    final isDisabled = isBlocked || isPendingNewCardApproval;

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
                  value: isDisabled ? false : (isEcommerceEnabled ?? false),
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
  Widget _buildTpeToggle() {
    final isDisabled = isBlocked || isPendingNewCardApproval;

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
                Icon(Icons.point_of_sale, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "TPE Payments",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                UltraSwitch(
                  value: isDisabled ? false : (isTpePaymentEnabled ?? false),
                  onChanged: (val) {
                    setState(() => isTpePaymentEnabled = val);
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
        onTap: isPendingNewCardApproval ? null : _flipCard,
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
              'My Physical Card',
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
              isRequestSent ? '**** **** *** 456' : '1234 5678 9012 3456',
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
            const Text('Signature', style: TextStyle(fontSize: 10, color: Colors.white54)),
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
        gradient: LinearGradient(
          colors: [
            Color(int.parse(card!.gradientStartColor.replaceFirst('#', '0xff'))),
            Color(int.parse(card!.gradientEndColor.replaceFirst('#', '0xff'))),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, 12))
        ],
      ),
      child: child,
    );
  }
  Widget _buildCvvPopup() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: AnimatedScale(
              scale: showCvvPopup ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    const Text("Your CVV",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70)),
                    const SizedBox(height: 14),
                    Text(modalCvv ?? '',
                        style: const TextStyle(
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
                    Text("This will close in $cvvCountdown sec",
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    Text(modalPin ?? '',
                        style: const TextStyle(
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
                    Text("This will close in $pinCountdown sec",
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
  Widget _buildDeleteCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                child: const Divider(
                  color: Color(0xFFB0B0B0),
                  thickness: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
              Container(
                width: 130,
                child: const Divider(
                  color: Color(0xFFB0B0B0),
                  thickness: 2,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 370,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
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
                RichText(
                  textAlign: TextAlign.justify,
                  text: const TextSpan(
                    text: "Deleting this card will permanently remove it from your profile. "
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
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              color: const Color(0xFFFF3B30),
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
  void _showDeleteConfirmationDialog({String? reason}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🗑️ Trash Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE8E8), Color(0xFFFFCCCC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.delete_forever_rounded, size: 42, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  const Text(
                    "Confirm Deletion",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtext
                  const Text(
                    "Are you sure you want to delete this card? This action is permanent and cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: Color(0xFF3C3C43),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 📄 Card Info only (NO Email)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD1D1D6)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow("Cardholder", "Nada S. Rhandor"),
                        const SizedBox(height: 8),
                        _buildInfoRow("Card Number", "•••• •••• •••• 345"),
                        const SizedBox(height: 8),
                        _buildInfoRow("Card Type", "Visa"),
                        const SizedBox(height: 8),
                        _buildInfoRow("Expires", "08/26"),
                      ],
                    ),
                  ),

                  if (reason != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF0F0), Color(0xFFFFE5E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFFFA0A0), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Reason: \"$reason\"",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB00020),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 26),

                  // 🧭 Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFD1D1D6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => OtpVerificationDialog(
                                  username: username, // ✅ You must pass this
                                  onConfirmed: (otp) {
                                    if (otp == "1111") {
                                      Navigator.pop(context);
                                      setState(() {
                                        isRequestSent = true;
                                        deleteRequestSent = true;
                                        isCardDeleted = true;
                                        isBlocked = false;
                                        blockReason = null;
                                        blockStartDate = null;
                                        blockEndDate = null;
                                        isPermanent = false;
                                        confirmedPermanentBlock = false;
                                        lostConfirmed = false;
                                        showRequestCard = false;
                                      });
                                      showCupertinoGlassToast(
                                        context,
                                        "Card deleted successfully.",
                                        isSuccess: true,
                                        position: ToastPosition.top,
                                      );
                                    } else {
                                      showCupertinoGlassToast(
                                        context,
                                        "Incorrect code. Try again.",
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
      ),
    );
  }
// Helper Widget
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13.2, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _scrollController.dispose(); // << Dispose controller
    _refreshTimer?.cancel(); // << Dispose refresh timer
    _securityOptionsTimer?.cancel(); // << Dispose security options timer
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final fadeOpacity = _scrollController.hasClients
        ? max(0.85, 1 - (_scrollController.offset.clamp(0.0, 100.0) / 100))
        : 1.0;

    final bounceScale = _scrollController.hasClients && _scrollController.offset < 0
        ? 1.0 - (_scrollController.offset / -150)
        : 1.0;

    // Debug prints for state
    print("🔍 BUILD - isBlocked: $isBlocked");
    print("🔍 BUILD - blockReason: ${blockReason?.label} (${blockReason?.value})");
    print("🔍 BUILD - lostConfirmed: $lostConfirmed");
    print("🔍 BUILD - hasRequestedNewCard: $hasRequestedNewCard");
    print("🔍 BUILD - requestedNewCardDate: $requestedNewCardDate");
    print("🔍 BUILD - card?.blockReason: ${card?.blockReason}");
    print("🔍 BUILD - card?.replacementRequested: ${card?.replacementRequested}");
    print("🔍 BUILD - isPendingNewCardApproval: $isPendingNewCardApproval");

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }
    if (card == null) {
      return Scaffold(
        body: Center(child: Text('Card not found.')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🎨 Full-Screen Gradient
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

          // 🧊 Frosted Glass Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // 📜 Scrollable content under the header
          Padding(
            padding: EdgeInsets.only(top: topPadding + kToolbarHeight + 16),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  AnimatedScale(
                    scale: bounceScale.clamp(0.96, 1.02),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    child: FlippableCard(
                      animation: _animation,
                      isRequestSent: isRequestSent,
                      cardGradient: LinearGradient(
                        colors: [
                          Color(int.parse(card!.gradientStartColor.replaceFirst('#', '0xff'))),
                          Color(int.parse(card!.gradientEndColor.replaceFirst('#', '0xff'))),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: _flipCard,
                      cardholderName: card?.cardholderName ?? '',
                      cardNumber: card?.cardNumber ?? '',
                      expiryDate: card?.expirationDate ?? '',
                      cvv: card?.cvv ?? '',
                      packName: card?.cardPack.label ?? '',
                      showCvv: false, // Always false, never reveal CVV on card
                    ),
                  ),

                  CardInfoSection(
                    isRequestSent: isRequestSent,
                    cvvController: _cvvController,
                    pinController: _pinController,
                    onRevealCvv: _revealCVV,
                    isCvvRevealed: isCvvRevealed,
                    onRevealPin: _revealPINPopup,
                    cardholderName: card?.cardholderName ?? '',
                    cardNumber: card?.cardNumber ?? '',
                    expiryDate: card?.expirationDate ?? '',
                    cvv: card?.cvv ?? '',
                    pin: card?.pin ?? '',
                    hideCvvAndPin: isPendingNewCardApproval, // ✅ Hide CVV and PIN when pending approval
                  ),

                  // Show pending approval info box when applicable
                  if (isPendingNewCardApproval)
                    _buildPendingApprovalInfoBox(),

                  // Only show other sections if NOT pending approval
                  if (!isRequestSent && !isPendingNewCardApproval) ...[
                    Builder(
                      builder: (context) {
                        if (card == null || selectedLimitType == null) {
                          return const SizedBox.shrink();
                        }

                        double maxLimit = 0.0;
                        switch (selectedLimitType!.label) {
                          case 'Daily Spending Limit':
                            maxLimit = card!.cardPack.limitDaily;
                            break;
                          case 'Monthly Spending Cap':
                            maxLimit = card!.cardPack.limitMonthly;
                            break;
                          case 'Online Purchase Restriction':
                            maxLimit = card!.cardPack.limitAnnual;
                            break;
                        }

                        return LimitSection(
                          isBlocked: isBlocked,
                          selectedLimitType: selectedLimitType,
                          limitTypes: limitTypes,
                          onLimitTypeChanged: (value) {
                            setState(() {
                              selectedLimitType = value;
                              // When limit type changes, reset selectedLimit to the card's current value
                              switch (value.label) {
                                case 'Daily Spending Limit':
                                  selectedLimit = card!.dailyLimit;
                                  break;
                                case 'Monthly Spending Cap':
                                  selectedLimit = card!.monthlyLimit;
                                  break;
                                case 'Online Purchase Restriction':
                                  selectedLimit = card!.annualLimit;
                                  break;
                              }
                            });
                          },
                          selectedLimit: selectedLimit,
                          onLimitChanged: (value) {
                            setState(() {
                              selectedLimit = value;
                            });
                          },
                          onChangeEnd: (value) async {
                            final oldValue = selectedLimit;
                            setState(() {
                              selectedLimit = value;
                            });
                            if (card == null) return;
                            double newDaily = card!.dailyLimit;
                            double newMonthly = card!.monthlyLimit;
                            double newAnnual = card!.annualLimit;
                            switch (selectedLimitType!.label) {
                              case 'Daily Spending Limit':
                                newDaily = value;
                                break;
                              case 'Monthly Spending Cap':
                                newMonthly = value;
                                break;
                              case 'Online Purchase Restriction':
                                newAnnual = value;
                                break;
                            }
                            final success = await CardService().updatePhysicalCardLimits(
                              cardId: card!.id.toString(),
                              request: UpdatePhysicalCardLimitsRequest(
                                newDailyLimit: newDaily,
                                newMonthlyLimit: newMonthly,
                                newAnnualLimit: newAnnual,
                              ),
                            );
                            if (!mounted) return;
                            if (success) {
                              showCupertinoGlassToast(
                                context,
                                "Limit updated successfully!",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                              await _fetchCard();
                            } else {
                              showCupertinoGlassToast(
                                context,
                                "Failed to update limit.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                              setState(() {
                                selectedLimit = oldValue;
                              });
                            }
                          },
                          maxLimit: maxLimit,
                          scrollToBottom: _scrollToBottom,
                        );
                      },
                    ),
                    // ✅ Only show security settings when we have data to avoid flicker
                    if (_securityOptions != null)
                      SecuritySettingsSection(
                        isBlocked: isBlocked,
                        isContactlessEnabled: isContactlessEnabled ?? false,
                        isEcommerceEnabled: isEcommerceEnabled ?? false,
                        isTpePaymentEnabled: isTpePaymentEnabled ?? false,
                        isInternationalWithdrawEnabled: isInternationalWithdrawEnabled ?? false,
                        onContactlessChanged: (val) async {
                          // ✅ Store previous state for potential rollback
                          final previousValue = isContactlessEnabled;
                          
                          // ✅ Immediately update local UI state
                          setState(() => isContactlessEnabled = val);
                          
                          try {
                            // ✅ Call backend with all four current values
                            await SecurityOptionsService().updatePhysicalCardSecurityOptions(
                              UpdatePhysicalSecurityOptionRequest(
                                cardId: int.parse(widget.cardId!),
                                contactlessEnabled: val,
                                ecommerceEnabled: isEcommerceEnabled ?? false,
                                tpeEnabled: isTpePaymentEnabled ?? false,
                                internationalWithdrawEnabled: isInternationalWithdrawEnabled ?? false,
                              ),
                            );
                            
                            print("✅ Contactless toggle updated successfully");
                            
                            // ✅ Show success toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "Contactless payments ${val ? 'enabled' : 'disabled'}",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            }
                          } catch (e) {
                            print("❌ Contactless toggle update failed: $e");
                            
                            // ✅ Show error toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "Failed to update contactless setting. Please try again.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                            
                            // ✅ Revert to previous state
                            setState(() => isContactlessEnabled = previousValue);
                          }
                        },
                        onEcommerceChanged: (val) async {
                          // ✅ Store previous state for potential rollback
                          final previousValue = isEcommerceEnabled;
                          
                          // ✅ Immediately update local UI state
                          setState(() => isEcommerceEnabled = val);
                          
                          try {
                            // ✅ Call backend with all four current values
                            await SecurityOptionsService().updatePhysicalCardSecurityOptions(
                              UpdatePhysicalSecurityOptionRequest(
                                cardId: int.parse(widget.cardId!),
                                contactlessEnabled: isContactlessEnabled ?? false,
                                ecommerceEnabled: val,
                                tpeEnabled: isTpePaymentEnabled ?? false,
                                internationalWithdrawEnabled: isInternationalWithdrawEnabled ?? false,
                              ),
                            );
                            
                            print("✅ E-commerce toggle updated successfully");
                            
                            // ✅ Show success toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "E-commerce payments ${val ? 'enabled' : 'disabled'}",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            }
                          } catch (e) {
                            print("❌ E-commerce toggle update failed: $e");
                            
                            // ✅ Show error toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "Failed to update e-commerce setting. Please try again.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                            
                            // ✅ Revert to previous state
                            setState(() => isEcommerceEnabled = previousValue);
                          }
                        },
                        onTpeChanged: (val) async {
                          // ✅ Store previous state for potential rollback
                          final previousValue = isTpePaymentEnabled;
                          
                          // ✅ Immediately update local UI state
                          setState(() => isTpePaymentEnabled = val);
                          
                          try {
                            // ✅ Call backend with all four current values
                            await SecurityOptionsService().updatePhysicalCardSecurityOptions(
                              UpdatePhysicalSecurityOptionRequest(
                                cardId: int.parse(widget.cardId!),
                                contactlessEnabled: isContactlessEnabled ?? false,
                                ecommerceEnabled: isEcommerceEnabled ?? false,
                                tpeEnabled: val,
                                internationalWithdrawEnabled: isInternationalWithdrawEnabled ?? false,
                              ),
                            );
                            
                            print("✅ TPE toggle updated successfully");
                            
                            // ✅ Show success toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "TPE payments ${val ? 'enabled' : 'disabled'}",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            }
                          } catch (e) {
                            print("❌ TPE toggle update failed: $e");
                            
                            // ✅ Show error toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "Failed to update TPE setting. Please try again.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                            
                            // ✅ Revert to previous state
                            setState(() => isTpePaymentEnabled = previousValue);
                          }
                        },
                        onInternationalWithdrawChanged: (val) async {
                          // ✅ Store previous state for potential rollback
                          final previousValue = isInternationalWithdrawEnabled;
                          
                          // ✅ Immediately update local UI state
                          setState(() => isInternationalWithdrawEnabled = val);
                          
                          try {
                            // ✅ Call backend with all four current values
                            await SecurityOptionsService().updatePhysicalCardSecurityOptions(
                              UpdatePhysicalSecurityOptionRequest(
                                cardId: int.parse(widget.cardId!),
                                contactlessEnabled: isContactlessEnabled ?? false,
                                ecommerceEnabled: isEcommerceEnabled ?? false,
                                tpeEnabled: isTpePaymentEnabled ?? false,
                                internationalWithdrawEnabled: val,
                              ),
                            );
                            
                            print("✅ International withdraw toggle updated successfully");
                            
                            // ✅ Show success toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "International withdrawals ${val ? 'enabled' : 'disabled'}",
                                isSuccess: true,
                                position: ToastPosition.top,
                              );
                            }
                          } catch (e) {
                            print("❌ International withdraw toggle update failed: $e");
                            
                            // ✅ Show error toast
                            if (mounted) {
                              showCupertinoGlassToast(
                                context,
                                "Failed to update international withdraw setting. Please try again.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                            
                            // ✅ Revert to previous state
                            setState(() => isInternationalWithdrawEnabled = previousValue);
                          }
                        },
                        isPendingApproval: isPendingNewCardApproval, // ✅ Pass pending approval state
                      ),
                    _buildBlockCardSection(),
                  ],

                  // Only show delete card section if NOT pending approval
                  if (!isPendingNewCardApproval)
                    _buildDeleteCardSection(),
                ],
              ),

            ),
          ),

          // 🧭 Manual Header with Fade
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BackButton(color: Colors.black),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: fadeOpacity.clamp(0.6, 1.0), // ✅ fade but never fully invisible
                      child: const Center(
                        child: Text(
                          'Card Details',
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
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 🔐 PIN Popup
          if (showPinPopup)
            _buildPinPopup(),
          if (showCvvPopup)
            _buildCvvPopup(),
        ],
      ),
    );
  }

  // --- Add this helper to manage the refresh timer ---
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _fetchCard();
      // TODO: Add other service refreshes here if needed
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // --- Add this helper to manage the security options timer ---
  void _startSecurityOptionsTimer() {
    _securityOptionsTimer?.cancel();
    _securityOptionsTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _fetchSecurityOptions();
    });
  }

  void _stopSecurityOptionsTimer() {
    _securityOptionsTimer?.cancel();
    _securityOptionsTimer = null;
  }
}


Widget _dateLabel(String label, DateTime date) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9FB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD1D1D6)),
    ),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(date.toString().split(' ')[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
String _formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
