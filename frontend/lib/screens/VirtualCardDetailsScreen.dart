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
  bool showJustBlockNowSpan = false;
  bool isJustBlockNowConfirmed = false;


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
    DropdownItem(label: 'I Don’t Need This Card Anymore', icon: Icons.cancel),
    DropdownItem(label: 'My Card Details Got Leaked (CVV)', icon: Icons.security),
    DropdownItem(label: 'Someone Tried to Use My Card', icon: Icons.warning_amber_rounded),
    DropdownItem(label: 'I Lost My Phone or Device', icon: Icons.phonelink_erase),
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


  // Calendar will works with travelplan
  Future<void> _pickBlockDates() async {
    DateTime now = DateTime.now();
    DateTime? tempStart;
    DateTime? tempEnd;
    DateTime focusedDay = now;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // handles keyboard safely
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
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // iOS-style drag pill
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      // Title
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Select Block Date Range',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),

                      // TableCalendar
                      TableCalendar(
                        firstDay: now,
                        lastDay: now.add(const Duration(days: 365)),
                        focusedDay: focusedDay,
                        currentDay: null,
                        calendarFormat: CalendarFormat.month,
                        rangeStartDay: tempStart,
                        rangeEndDay: tempEnd,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor: Colors.blueAccent.withOpacity(0.25),
                          rangeStartDecoration: const BoxDecoration(
                            color: Color(0xFF717172),
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: const TextStyle(fontSize: 14),
                          withinRangeTextStyle: const TextStyle(color: Colors.black87),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        selectedDayPredicate: (day) =>
                        (tempStart != null && isSameDay(tempStart, day)) ||
                            (tempEnd != null && isSameDay(tempEnd, day)),
                        onDaySelected: (selectedDay, focused) {
                          setModalState(() {
                            focusedDay = focused;
                            if (tempStart != null &&
                                tempEnd == null &&
                                selectedDay.isAfter(tempStart!)) {
                              tempEnd = selectedDay;
                            } else {
                              tempStart = selectedDay;
                              tempEnd = null;
                            }
                          });
                        },
                        onPageChanged: (focused) {
                          setModalState(() => focusedDay = focused);
                        },
                      ),

                      const SizedBox(height: 12),

                      // Spans of start/end dates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempStart != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9FB), // light iOS-style grey
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Color(0xFFD1D1D6)), // ✅ iOS soft black border
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    "Start: ",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF3A3A3C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${tempStart!.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (tempEnd != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9FB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Color(0xFFD1D1D6)), // ✅ border
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    "End: ",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF3A3A3C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${tempEnd!.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Confirm Button (50% width)
                      FractionallySizedBox(
                        widthFactor: 0.5, // ✅ 50% of screen width
                        child: ElevatedButton(
                          onPressed: (tempStart != null && tempEnd != null)
                              ? () {
                            setState(() {
                              blockStartDate = tempStart!;
                              blockEndDate = tempEnd!;
                            });
                            Navigator.pop(context);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (tempStart != null && tempEnd != null)
                                ? const Color(0xFF3A3A3C)
                                : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                    ],
                  ),
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
                  onChanged: (val) {
                    // 🛑 User tries to unblock after confirming "Just Block for Now"
                    if (!val && isJustBlockNowConfirmed && blockReason?.label == 'Just Block for Now (Temporary)') {
                      showDialog(
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
                                        text: "🛑  ${blockReason?.label ?? ''}",
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
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isBlocked = false;
                                            blockReason = null;
                                            blockStartDate = null;
                                            blockEndDate = null;
                                            isPermanent = false;
                                            showRequestCard = false;
                                            isJustBlockNowConfirmed = false;
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
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
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
                      return; // Stop further logic
                    }

                    // ✅ Default toggle logic
                    setState(() {
                      isBlocked = val;
                      isJustBlockNowConfirmed = false; // reset span
                    });

                    if (val) _scrollToBottom();

                    if (blockReason == null && val) {
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
                      ignoring: isJustBlockNow,
                      child: Opacity(
                        opacity: isJustBlockNow ? 0.5 : 1.0,
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

                  ],
                ),
              ),
            ],
          ),
      ],
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
                const Text('My Virtual Card',
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
    _scrollController.dispose();
    _reasonResetTimer?.cancel(); // ✅ Cancel the auto-reset timer if active
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
                _buildEcommerceToggle(),
                _buildBlockCardSection(),
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
          if (showPinPopup) _buildPinPopup(),
        ],
      ),
    );
  }


}



