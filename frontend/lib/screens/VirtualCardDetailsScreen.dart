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


  final TextEditingController _cvvController = TextEditingController(
      text: '•••');
  final TextEditingController _pinController = TextEditingController(
      text: '••••');

  DropdownItem? selectedLimitType;
  DropdownItem? blockReason;

  final ScrollController _scrollController = ScrollController(); // << ADDED

  final List<String> forceDeleteReasons = [
    'I Don’t Need This Card Anymore',
    'Someone Tried to Use My Card',
    'I’m Closing My Account or Switching',
    'I Lost My Phone or Device',
  ];


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
                    setState(() {
                      isBlocked = val;

                      if (!val) {
                        blockReason = null;
                        blockStartDate = null;
                        blockEndDate = null;
                        isPermanent = false;
                        showRequestCard = false;
                      } else {
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

                          // ⏳ Auto-turn off after 15 seconds if no reason is selected
                          Future.delayed(const Duration(seconds: 15), () {
                            if (mounted && blockReason == null && isBlocked) {
                              setState(() {
                                isBlocked = false;
                              });

                              // Optional: show cancellation toast
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
                    CustomDropdown(
                      key: ValueKey(blockReason?.label ?? 'none'),
                      icon: Icons.warning_amber_rounded,
                      selectedItem: blockReason,
                      items: blockReasons,
                      onChanged: (value) {
                        if (blockReason != null && blockReason?.label != value.label) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Clear the current reason before selecting another."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        final isTempSelected = blockReason?.label == 'Temporary Block' &&
                            blockStartDate != null && blockEndDate != null;
                        final isPermanentSelected = blockReason?.label == 'Permanent Block';
                        final isLostStolenDamaged = blockReason?.label == 'Card Lost – Cannot Find It' ||
                            blockReason?.label == 'Card Stolen – Unauthorized Use' ||
                            blockReason?.label == 'Card Damaged – Not Functional';

                        final isTryingToChangeFromPermanent = isPermanentSelected && value.label != 'Permanent Block';
                        final isTryingToChangeFromSpecial = isLostStolenDamaged && value.label != blockReason?.label;

                        if (isTempSelected && value.label != 'Temporary Block') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Clear the temporary block first before changing reason."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        if (isTryingToChangeFromPermanent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Clear the permanent block first before changing reason."),
                              backgroundColor: Colors.redAccent,
                            ),
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

                        // Start auto-reset and show confirmation if reason requires action
                        if (forceDeleteReasons.contains(value.label)) {

                          // Show confirmation dialog
                          Future.delayed(const Duration(milliseconds: 300), () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
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
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Delete Card",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Are you sure you want to cancel this card permanently?",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
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
                                              onPressed: () {
                                                Navigator.pop(context);

                                                // ✅ Reset block if user cancelled
                                                setState(() {
                                                  isBlocked = false;
                                                  blockReason = null;
                                                  blockStartDate = null;
                                                  blockEndDate = null;
                                                  isPermanent = false;
                                                  showRequestCard = false;
                                                  showRequestNewCvv = false;
                                                });

                                                showCupertinoGlassToast(
                                                  context,
                                                  "Block cancelled. Card is active.",
                                                  isSuccess: false,
                                                  position: ToastPosition.top,
                                                );
                                              },
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
                                                showCupertinoGlassToast(
                                                  context,
                                                  "Card has been deleted.",
                                                  isSuccess: true,
                                                  position: ToastPosition.top,
                                                );
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
                                      )
                                    ],
                                  ),
                                ),
                              ),

                            );
                          });
                        }

                        showRequestNewCvv = false;

                        setState(() {
                          blockReason = value;
                          showRequestCard = false;
                          isPermanent = false;
                          blockStartDate = null;
                          blockEndDate = null;

                          switch (value.label) {
                            case 'Temporary Block':
                              _pickBlockDates();
                              break;
                            case 'Permanent Block':
                              isPermanent = true;
                              break;
                            case 'Card Lost – Cannot Find It':
                            case 'Card Stolen – Unauthorized Use':
                            case 'Card Damaged – Not Functional':
                              isPermanent = true;
                              showRequestCard = true;
                              break;
                            case 'My Card Details Got Leaked (CVV)':
                              isPermanent = true;
                              showRequestCard = false;
                              showRequestNewCvv = true; // 💥 Ajouter ici
                              break;
                          }
                        });
                      },
                      label: '',
                    ),

                    if (blockReason != null || blockStartDate != null || blockEndDate != null) ...[
                      const SizedBox(height: 12),

                      if (blockReason?.label == 'Temporary Block' &&
                          blockStartDate != null &&
                          blockEndDate != null)
                        Container(
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
                                const Text(
                                  'Blocked from 01/01/2024 to 01/02/2024', // Replace with dynamic dates
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            )

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
                          // Clear Reason Button
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF2F2F5), Color(0xFFEAEAEC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Color(0xFFB3B3B7), width: 0.9), // Light iOS black
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
                                setState(() {
                                  isBlocked = false; // 💥 Turn off the switch
                                  blockReason = null;
                                  blockStartDate = null;
                                  blockEndDate = null;
                                  showRequestCard = false;
                                  isPermanent = false;
                                  showRequestNewCvv = false;
                                });
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

                          // Request New CVV Button
                          if (showRequestNewCvv)
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
                                    const SnackBar(content: Text("Request to generate new CVV has been sent.")),
                                  );
                                },
                                icon: const Icon(Icons.lock_reset_rounded, size: 18),
                                label: const Text(
                                  "Request New CVV",
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


                          // Request New Card Button
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

                          // Cancel/Delete Card Button
                          if (!forceDeleteReasons.contains(blockReason?.label ?? ''))
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFFEB3B3B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Color(0xFFB3B3B7), width: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
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
                                              "Delete Card",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              "Are you sure you want to cancel this card permanently?",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54,
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
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        isBlocked = false;
                                                        blockReason = null;
                                                        blockStartDate = null;
                                                        blockEndDate = null;
                                                        isPermanent = false;
                                                        showRequestCard = false;
                                                        showRequestNewCvv = false;
                                                      });

                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Block cancelled. Card is active.",
                                                        isSuccess: false,
                                                        position: ToastPosition.top,
                                                      );
                                                    },
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
                                                      showCupertinoGlassToast(
                                                        context,
                                                        "Card has been deleted.",
                                                        isSuccess: true,
                                                        position: ToastPosition.top,
                                                      );
                                                      // 👉 Add deletion logic here if needed
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
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete_forever, size: 18),
                                label: const Text(
                                  "Cancel / Delete Card",
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
              _buildSectionTitle("Security Settings"),
              _buildEcommerceToggle(),
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



