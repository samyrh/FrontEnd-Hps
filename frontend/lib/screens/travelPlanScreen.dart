import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sami/widgets/Card_Scroller.dart';
import '../widgets/AddTravelPlan/DialogRow.dart';
import '../widgets/AddTravelPlan/buildScrollableCountryRow.dart';
import '../widgets/Countries_Dropdown.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/Navbar.dart';
import '../widgets/Toast.dart';

class PhysicalCardSpecsPack {
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
  final int travelCountriesIncluded;
  final int maxTravelDays;
  final int internationalWithdrawLimitPerTravel;

  const PhysicalCardSpecsPack({
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
    required this.travelCountriesIncluded,
    required this.maxTravelDays,
    required this.internationalWithdrawLimitPerTravel,
  });
  
  
}

final Map<String, PhysicalCardSpecsPack> physicalCardSpecsPacks = {
  'Visa Youth': PhysicalCardSpecsPack(
    label: 'Visa Youth',
    withdrawDaily: 500,
    paymentMonthly: 2000,
    onlineYearly: 1000,
    ecommerceEnabled: true,
    contactless: true,
    validityYears: 2,
    hasDeferred: true,
    yearlyFee: 0,
    audience: 'Étudiants de moins de 26 ans',
    internationalWithdraw: true,
    cardType: 'Visa',
    travelCountriesIncluded: 3, // ✅ Only 3 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 3000,
  ),
  'Visa Classic': PhysicalCardSpecsPack(
    label: 'Visa Classic',
    withdrawDaily: 2000,
    paymentMonthly: 8000,
    onlineYearly: 3000,
    ecommerceEnabled: true,
    contactless: true,
    validityYears: 3,
    hasDeferred: true,
    yearlyFee: 80,
    audience: 'Tous clients majeurs',
    internationalWithdraw: true,
    cardType: 'Visa',
    travelCountriesIncluded: 5, // ✅ 5 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 8000,
  ),
  'Visa Gold': PhysicalCardSpecsPack(
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
    travelCountriesIncluded: 10, // ✅ 10 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 12000,
  ),
  'Visa Business': PhysicalCardSpecsPack(
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
    travelCountriesIncluded: 15, // ✅ 15 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 18000,
  ),
  'Visa Premium+': PhysicalCardSpecsPack(
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
    travelCountriesIncluded: 20, // ✅ 20 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 25000,
  ),
  'Visa International': PhysicalCardSpecsPack(
    label: 'Visa International',
    withdrawDaily: 6000,
    paymentMonthly: 20000,
    onlineYearly: 12000,
    ecommerceEnabled: true,
    contactless: true,
    validityYears: 4,
    hasDeferred: true,
    yearlyFee: 250,
    audience: 'Voyageurs et expatriés',
    internationalWithdraw: true,
    cardType: 'Visa',
    travelCountriesIncluded: 15, // ✅ 15 countries
    maxTravelDays: 90,
    internationalWithdrawLimitPerTravel: 15000,
  ),
};

class TravelPlanScreen extends StatefulWidget {
  const TravelPlanScreen({Key? key}) : super(key: key);

  @override
  State<TravelPlanScreen> createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen> {
  final Map<String, List<DropdownItem>> selectedCountriesPerPack = {};
  final Map<String, DateTime?> startDatesPerPack = {};
  final Map<String, DateTime?> endDatesPerPack = {};
  int currentIndex = 0;
  String? selectedPackLabel;
  final Map<String, bool> approvalNoticeSeenPerPack = {};

// ✅ Declare cleanNow and maxDate as `late` (not final here)
  late DateTime cleanNow;
  late DateTime maxDate;
  final List<DropdownItem> reasonItems = [
    DropdownItem(label: 'Visa Youth', icon: Icons.school_rounded),
    DropdownItem(label: 'Visa Classic', icon: Icons.credit_card_rounded),
    DropdownItem(label: 'Visa Gold', icon: Icons.workspace_premium_rounded),
    DropdownItem(label: 'Visa Business', icon: Icons.business_center_rounded),
    DropdownItem(label: 'Visa Premium+', icon: Icons.stars_rounded),
    DropdownItem(label: 'Visa International', icon: Icons.public_rounded),
  ];
  final Map<String, bool> travelPlanSubmittedPerPack = {};
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    if (selectedPackLabel == null) return;

    final selectedPack = physicalCardSpecsPacks[selectedPackLabel!]!;

    // ✅ Set dynamic date range
    late DateTime minDate;
    late DateTime maxSelectableDate;

    if (isStart) {
      minDate = cleanNow;
      maxSelectableDate = cleanNow.add(Duration(days: selectedPack.maxTravelDays));
    } else {
      final startDate = startDatesPerPack[selectedPackLabel!];
      if (startDate == null) {
        showError(context, "Please select a start date first.");
        return;
      }
      minDate = startDate;
      maxSelectableDate = startDate.add(Duration(days: selectedPack.maxTravelDays));
    }

    // ✅ Get current selected value or fallback to minDate
    DateTime selectedDate = isStart
        ? (startDatesPerPack[selectedPackLabel!] ?? minDate)
        : (endDatesPerPack[selectedPackLabel!] ?? minDate);

    // 🔔 Show one-time approval notice
    final hasSeen = approvalNoticeSeenPerPack[selectedPackLabel!] ?? false;
    if (!hasSeen) {
      approvalNoticeSeenPerPack[selectedPackLabel!] = true;

      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text(
            "Approval Notice",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Approval may take 24–72 hours.\n\nNote: The maximum duration for a travel plan is 90 days.",
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Got it",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 📆 Show CupertinoDatePicker in modal
    DateTime tempSelectedDate = selectedDate; // 👈 Holds the latest selected value

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF2F2F7), Color(0xFFE5E5EA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 20, bottom: 30),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(brightness: Brightness.light),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumDate: minDate,
                      maximumDate: maxSelectableDate,
                      onDateTimeChanged: (DateTime newDate) {
                        tempSelectedDate = newDate;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFF2F2F7),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3A3A3C),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          borderRadius: BorderRadius.circular(14),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              if (isStart) {
                                startDatesPerPack[selectedPackLabel!] = tempSelectedDate;
                                endDatesPerPack[selectedPackLabel!] = null;
                              } else {
                                endDatesPerPack[selectedPackLabel!] = tempSelectedDate;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    final isSubmitted = selectedPackLabel != null &&
        travelPlanSubmittedPerPack[selectedPackLabel!] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            const SizedBox(height: 24), // 🔝 Top spacing after SafeArea

            // 🔙 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  const Text(
                    'Travel Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // 👇 space after title

            // 📇 Card Scroller
            CardScroller(
              onCardChanged: (label) {
                setState(() {
                  selectedPackLabel = label;
                  selectedCountriesPerPack.putIfAbsent(label, () => []);
                  startDatesPerPack.putIfAbsent(label, () => null);
                  endDatesPerPack.putIfAbsent(label, () => null);
                });
              },
            ),

            if (selectedPackLabel != null) ...[
              const SizedBox(height: 32),

              // 🔹 Travel Pack Summary Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1.2)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Travel Pack Summary",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1.2)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🧾 Travel Pack Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTravelPackSpan(
                  physicalCardSpecsPacks[selectedPackLabel!]!,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ✈️ Travel Plan Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Expanded(child: Divider(thickness: 1.2)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Travel Plan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1.2)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🧳 Travel Plan Form or Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: selectedPackLabel != null
                  ? (isSubmitted
                  ? _buildTravelPlanSummaryWithKey() // ✅ Show Summary
                  : _buildTravelForm()) // ✅ Show Form
                  : const SizedBox(),
            ),

            const SizedBox(height: 40), // ⬇️ Bottom spacer
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    cleanNow = DateTime(now.year, now.month, now.day); // 👈 today at 00:00
    maxDate = cleanNow.add(const Duration(days: 90));  // 👈 max range from today
  }
  void showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        insetAnimationDuration: const Duration(milliseconds: 300),
        title: Column(
          children: const [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Color(0xFFFF3B30), // iOS red tone
              size: 34,
            ),
            SizedBox(height: 12),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 2),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5E5E5E), // soft dark grey
              height: 1.5,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
  void showCupertinoGlassToast(BuildContext context, String message,
      {bool isSuccess = true, ToastPosition position = ToastPosition.bottom}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: position == ToastPosition.bottom ? 80 : null,
        top: position == ToastPosition.top ? 80 : null,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.greenAccent.withOpacity(0.9) : Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _summaryKey = GlobalKey();



  Widget _buildTravelPlanSummary() {
    final start = startDatesPerPack[selectedPackLabel!]!;
    final end = endDatesPerPack[selectedPackLabel!]!;
    final duration = end.difference(start).inDays;
    final selectedCountries = selectedCountriesPerPack[selectedPackLabel!]!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1C1C1E).withOpacity(0.4),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Travel Plan Summary",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 🔴 Status span
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEAEA), Color(0xFFFFDADA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFFFF3B30).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.clock, size: 18, color: Color(0xFFB91C1C)),
                  SizedBox(width: 8),
                  Text(
                    "Travel Plan In Review",
                    style: TextStyle(
                      color: Color(0xFF991B1B),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ⏱ Review note
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Your travel plan will be reviewed and approved within 72 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          _buildIconRow(CupertinoIcons.creditcard, "Visa Pack", selectedPackLabel!),
          _buildIconRow(CupertinoIcons.calendar, "Start Date", DateFormat('dd MMM yyyy').format(start)),
          _buildIconRow(CupertinoIcons.time, "End Date", DateFormat('dd MMM yyyy').format(end)),
          _buildIconRow(CupertinoIcons.timer, "Duration", "$duration Days"),


          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: Divider(thickness: 1.2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Countries",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Expanded(child: Divider(thickness: 1.2)),
            ],
          ),
          const SizedBox(height: 10),

          buildScrollableCountryRow(selectedCountries.map((e) => e.label).toList()),

          const Divider(height: 28),
          const Text(
            "You can create another travel plan after this one ends.",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDateTile(DateTime? date, String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 8),
          Text(
            date == null ? placeholder : DateFormat('dd MMM, yyyy').format(date),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
  Widget _buildTravelForm() {
    final selectedPack = physicalCardSpecsPacks[selectedPackLabel!]!;
    final selectedCountries = selectedCountriesPerPack[selectedPackLabel!]!;
    final startDate = startDatesPerPack[selectedPackLabel!];
    final endDate = endDatesPerPack[selectedPackLabel!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Destination Countries', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        CountriesDropdown(
          selectedCountries: selectedCountries.map((e) => e.label).toList(),
          onCountriesChanged: (List<String> countryList) {
            setState(() {
              selectedCountriesPerPack[selectedPackLabel!] =
                  countryList.map((name) => DropdownItem(label: name, icon: null)).toList();
            });
          },
          maxSelection: selectedPack.travelCountriesIncluded,
        ),
        const SizedBox(height: 20),
        const Text('Select Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, true),
                child: _buildDateTile(startDate, 'Start Date'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, false),
                child: _buildDateTile(endDate, 'End Date'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final selectedCountries = selectedCountriesPerPack[selectedPackLabel!] ?? [];
              final startDate = startDatesPerPack[selectedPackLabel!];
              final endDate = endDatesPerPack[selectedPackLabel!];

              if (selectedCountries.isEmpty) {
                showError(context, "Please select at least one destination country.");
                return;
              }

              if (startDate == null || endDate == null) {
                showError(context, "Please select both start and end dates.");
                return;
              }

              final travelDays = endDate.difference(startDate).inDays;

              if (travelDays <= 0) {
                showError(context, "End date must be after start date.");
                return;
              }

              if (travelDays > selectedPack.maxTravelDays) {
                showError(context, "You can travel up to ${selectedPack.maxTravelDays} days with this card.");
                return;
              }

              travelPlanSubmittedPerPack[selectedPackLabel!] = true;

              await showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF34C759), Color(0xFF30D158)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4034C759),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.checkmark_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Travel Plan Added",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CupertinoColors.systemGrey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildDialogRow("Pack", selectedPack.label),
                            buildDialogRow("Countries", selectedCountries.map((e) => e.label).join(', ')),
                            buildDialogRow("Duration", "$travelDays days"),
                            buildDialogRow("Max Allowed", "${selectedPack.maxTravelDays} days"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "You’ll be able to submit a new travel plan after this one ends.",
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                        Future.delayed(const Duration(milliseconds: 300), () {
                          final keyContext = _summaryKey.currentContext;
                          if (keyContext != null) {
                            Scrollable.ensureVisible(
                              keyContext,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                              alignment: 0.2,
                            );
                          }
                        });
                      },
                      child: const Text(
                        "Got it",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              );

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add Travel plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }


  Widget _buildTravelPackSpan(PhysicalCardSpecsPack pack) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1C1C1E).withOpacity(0.4),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "${pack.label} – Travel Pack",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildIconRow(CupertinoIcons.globe, "Countries Included", "${pack.travelCountriesIncluded} Country"),
          _buildIconRow(CupertinoIcons.calendar, "Max Travel Days", "${pack.maxTravelDays} Days"),
          _buildIconRow(CupertinoIcons.creditcard, "Intl Withdraw Limit", "${pack.internationalWithdrawLimitPerTravel} MAD"),
          _buildIconRow(CupertinoIcons.person_2, "Audience", pack.audience),
        ],
      ),
    );
  }
  Widget _buildIconRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFF3C3C43), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFF111827).withOpacity(0.25), width: 0.8),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTravelPlanSummaryWithKey() {
    return Container(
      key: _summaryKey,
      child: _buildTravelPlanSummary(),
    );
  }

}
