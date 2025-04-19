import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/Toast.dart';
import '../widgets/UltraSwitch.dart';
import 'package:table_calendar/table_calendar.dart';

//test
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
  bool isContactlessEnabled = true;
  bool isEcommerceEnabled = true;
  bool isTpePaymentEnabled = true;
  DateTime? blockStartDate;
  DateTime? blockEndDate;
  bool showRequestCard = false;
  bool isPermanent = false;
  bool confirmedPermanentBlock = false;


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
    DropdownItem(label: 'Temporary Block', icon: Icons.timelapse),
    DropdownItem(label: 'Permanent Block', icon: Icons.cancel),
    DropdownItem(label: 'Card Lost – Cannot Find It', icon: Icons.report_gmailerrorred),
    DropdownItem(label: 'Card Stolen – Unauthorized Use', icon: Icons.lock_person),
    DropdownItem(label: 'Card Damaged – Not Functional', icon: Icons.settings_backup_restore),
  ];


  double selectedLimit = 500;
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
        "Card is currently blocked. Flip disabled.",
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
        "Card is currently blocked. CVV access denied.",
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
                        _dateLabel("Start", today),
                        if (tempEnd != null) _dateLabel("End", tempEnd!),
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
    final double maxLimit =
    selectedLimitType != null ? (maxLimitByType[selectedLimitType!.label] ?? 5000) : 5000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Manage Limits"),

        Opacity(
          opacity: isBlocked ? 0.4 : 1,
          child: IgnorePointer(
            ignoring: isBlocked,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CustomDropdown(
                icon: Icons.tune,
                selectedItem: selectedLimitType,
                items: limitTypes,
                onChanged: (value) {
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
              opacity: isBlocked ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: isBlocked,
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

                    // 🛑 Prevent unblocking for Temporary Block before end date
                    if (!val && blockReason != null) {
                      if (blockReason!.label == 'Temporary Block' &&
                          blockEndDate != null &&
                          today.isBefore(blockEndDate!)) {
                        showCupertinoGlassToast(
                          context,
                          "You can't unblock this card until ${blockEndDate!.toLocal().toString().split(' ')[0]}",
                          isSuccess: false,
                          position: ToastPosition.top,
                        );
                        return;
                      }

                      // ✅ Show unblock dialog
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
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Turning off the block will cancel the reason:\n\n",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isBlocked = false;
                                            blockReason = null;
                                            blockStartDate = null;
                                            blockEndDate = null;
                                            isPermanent = false;
                                            showRequestCard = false;
                                          });

                                          showCupertinoGlassToast(
                                            context,
                                            "Card unblocked and reason cleared.",
                                            isSuccess: true,
                                            position: ToastPosition.top,
                                          );
                                        },
                                        child: const Text(
                                          "Unblock",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
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
                      setState(() {
                        isBlocked = val;

                        if (val) {
                          _scrollToBottom();

                          if (blockReason == null) {
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
                    IgnorePointer(
                      ignoring: false, // Always allow interaction
                      child: GestureDetector(
                        onTap: () {
                          if (confirmedPermanentBlock && blockReason?.label == 'Permanent Block') {
                            if (isBlocked) {
                              showCupertinoGlassToast(
                                context,
                                "To change the reason, please turn off the 'Block this card' option first.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            } else {
                              showCupertinoGlassToast(
                                context,
                                "You must unblock the card before changing the reason.",
                                isSuccess: false,
                                position: ToastPosition.top,
                              );
                            }
                          }
                        },
                        child: AbsorbPointer(
                          absorbing: confirmedPermanentBlock && blockReason?.label == 'Permanent Block',
                          child:CustomDropdown(
                            key: ValueKey(blockReason?.label ?? 'none'),
                            icon: Icons.warning_amber_rounded,
                            selectedItem: blockReason,
                            items: blockReasons,
                            onChanged: (value) {
                              final today = DateTime.now();

                              final isTempStillActive = blockReason?.label == 'Temporary Block' &&
                                  blockEndDate != null &&
                                  today.isBefore(blockEndDate!) &&
                                  value.label != 'Temporary Block';

                              if (isTempStillActive) {
                                showCupertinoGlassToast(
                                  context,
                                  "You can't change the reason until ${blockEndDate!.toLocal().toString().split(' ')[0]}",
                                  isSuccess: false,
                                  position: ToastPosition.top,
                                );
                                return;
                              }

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

                              if (value.label == 'Temporary Block') {
                                setState(() {
                                  blockReason = value;
                                  showRequestCard = false;
                                  isPermanent = false;
                                  confirmedPermanentBlock = false;
                                  blockStartDate = null;
                                  blockEndDate = null;
                                });
                                _pickBlockDates();
                                return;
                              }

                              if (value.label == 'Card Lost – Cannot Find It') {
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
                                              const Text(
                                                "Card Reported as Lost",
                                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 14),
                                              const Text(
                                                "Hello Nada S. Rhandor,\n\nWe've marked your card as lost for security. This action has been forwarded to our internal fraud and card issuance department.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                "To continue safely, you may request a new card. You’ll receive a confirmation email and be invited to retrieve your new card from the nearest banking agency.",
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
                                                      onPressed: () {
                                                        Navigator.pop(context);
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
                                                                  child:Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets.all(20),
                                                                        decoration: BoxDecoration(
                                                                          shape: BoxShape.circle,
                                                                          gradient: const LinearGradient(
                                                                            colors: [Color(0xFFE4FBE9), Color(0xFFD5F5E3)],
                                                                            begin: Alignment.topLeft,
                                                                            end: Alignment.bottomRight,
                                                                          ),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.green.withOpacity(0.2),
                                                                              blurRadius: 12,
                                                                              offset: const Offset(0, 4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: const Icon(Icons.mark_email_read_outlined, size: 42, color: Colors.green),
                                                                      ),
                                                                      const SizedBox(height: 22),
                                                                      const Text(
                                                                        "New Card Request Confirmed",
                                                                        style: TextStyle(
                                                                          fontSize: 19,
                                                                          fontWeight: FontWeight.w800,
                                                                          color: Color(0xFF1C1C1E),
                                                                          letterSpacing: -0.3,
                                                                        ),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                      const SizedBox(height: 16),
                                                                      const Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                                                        child: Text(
                                                                          "Cardholder: Nada S. Rhandor\nCard: •••• •••• •••• 345\nPhone: +212 777****333\n\nYour request has been received. We’ll notify you by email once your new card is available for pickup at the nearest banking agency.",
                                                                          style: TextStyle(
                                                                            fontSize: 15,
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
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(16),
                                                                            ),
                                                                          ),
                                                                          child: const Text(
                                                                            "Got it",
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w600,
                                                                              letterSpacing: 0.3,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )

                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text("Request New Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

                                setState(() {
                                  blockReason = value;
                                  isBlocked = true;
                                  confirmedPermanentBlock = false;
                                  showRequestCard = false;
                                  isPermanent = true;
                                  blockStartDate = null;
                                  blockEndDate = null;
                                });
                                return;
                              }

                              // Default case (other reasons)
                              setState(() {
                                blockReason = value;
                                isPermanent = true;
                                showRequestCard = true;
                                confirmedPermanentBlock = false;
                                blockStartDate = null;
                                blockEndDate = null;
                              });

                              Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
                            },
                            label: '',
                          )

                        ),
                      ),
                    ),
                    if ((blockReason != null || blockStartDate != null || blockEndDate != null) && !confirmedPermanentBlock) ...[
                      const SizedBox(height: 12),

                      if (blockReason?.label == 'Temporary Block' &&
                          blockStartDate != null &&
                          blockEndDate != null)
                        Builder(
                          builder: (context) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFF1F1), Color(0xFFFFE2E2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.date_range, size: 18, color: Colors.redAccent),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Blocked from ${blockStartDate!.toLocal().toString().split(' ')[0]} to ${blockEndDate!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      if (isPermanent || showRequestCard)
                        Container(
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
                        ),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          if (!(blockReason?.label == 'Permanent Block' && confirmedPermanentBlock) &&
                              blockReason?.label != 'Temporary Block')
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF2F2F5), Color(0xFFEAEAEC)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Color(0xFFB3B3B7), width: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  final today = DateTime.now();

                                  if (blockReason?.label == 'Temporary Block' &&
                                      blockEndDate != null &&
                                      today.isBefore(blockEndDate!)) {
                                    showCupertinoGlassToast(
                                      context,
                                      "You can't reset this block until the end date.",
                                      isSuccess: false,
                                      position: ToastPosition.top,
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isBlocked = false;
                                    blockReason = null;
                                    blockStartDate = null;
                                    blockEndDate = null;
                                    showRequestCard = false;
                                    isPermanent = false;
                                    confirmedPermanentBlock = false;
                                  });

                                  showCupertinoGlassToast(
                                    context,
                                    "Block reason reset. Card is now active.",
                                    isSuccess: false,
                                    position: ToastPosition.top,
                                  );
                                },
                                icon: const Icon(Icons.close, size: 16, color: Colors.black87),
                                label: const Text(
                                  "Clear Reason",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ),

                          if (showRequestCard)
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF72B2FF), Color(0xFF007AFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Color(0xFFB3B3B7), width: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("New card request sent.")),
                                  );
                                },
                                icon: const Icon(Icons.credit_card_rounded, size: 18),
                                label: const Text(
                                  "Request New Card",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ]

                  ],
                ),
              ),
            ],
          )
              : const SizedBox.shrink(key: ValueKey("empty")),
        ),
      ],
    );
  }

  Widget _buildContactlessToggle() {
    final isDisabled = isBlocked;

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
                  value: isBlocked ? false : isContactlessEnabled,
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
    final isDisabled = isBlocked;

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

  Widget _buildTpeToggle() {
    final isDisabled = isBlocked;

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
                  value: isBlocked ? false : isTpePaymentEnabled,
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
    final topPadding = MediaQuery.of(context).padding.top;

    final fadeOpacity = _scrollController.hasClients
        ? max(0.85, 1 - (_scrollController.offset.clamp(0.0, 100.0) / 100))
        : 1.0;

    final bounceScale = _scrollController.hasClients && _scrollController.offset < 0
        ? 1.0 - (_scrollController.offset / -150)
        : 1.0;

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
                    child: _buildCard(),
                  ),
                  _buildInfoSection(),
                  _buildLimitSection(),
                  _buildSectionTitle("Security Settings"),
                  _buildContactlessToggle(),
                  _buildEcommerceToggle(),
                  _buildTpeToggle(),
                  _buildBlockCardSection(),
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
          if (showPinPopup) _buildPinPopup(),
        ],
      ),
    );
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
