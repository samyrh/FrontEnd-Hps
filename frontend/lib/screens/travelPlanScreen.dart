import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sami/widgets/Card_Scroller.dart';
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


  final List<DropdownItem> reasonItems = [
    DropdownItem(label: 'Visa Youth', icon: Icons.school_rounded),
    DropdownItem(label: 'Visa Classic', icon: Icons.credit_card_rounded),
    DropdownItem(label: 'Visa Gold', icon: Icons.workspace_premium_rounded),
    DropdownItem(label: 'Visa Business', icon: Icons.business_center_rounded),
    DropdownItem(label: 'Visa Premium+', icon: Icons.stars_rounded),
    DropdownItem(label: 'Visa International', icon: Icons.public_rounded),
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    if (selectedPackLabel == null) return;

    final now = DateTime.now();
    final cleanNow = DateTime(now.year, now.month, now.day); // strip time precision

    DateTime selectedDate = isStart
        ? cleanNow
        : (startDatesPerPack[selectedPackLabel!] ?? cleanNow);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 30),
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
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    minimumDate: cleanNow,
                    maximumDate: cleanNow.add(const Duration(days: 90)),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isStart) {
                            startDatesPerPack[selectedPackLabel!] = selectedDate;
                            endDatesPerPack[selectedPackLabel!] = null;
                          } else {
                            endDatesPerPack[selectedPackLabel!] = selectedDate;
                          }
                        });
                      },
                    ),
                  ],
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            if (selectedPackLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1.2)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Travel Pack Summary",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1.2)),
                  ],
                ),
              ),
            if (selectedPackLabel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTravelPackSpan(physicalCardSpecsPacks[selectedPackLabel!]!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Row(
                children: const [
                  Expanded(child: Divider(thickness: 1.2)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Travel Plan Form",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1.2)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Destination Countries', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  if (selectedPackLabel != null)
                    CountriesDropdown(
                      selectedCountries: selectedCountriesPerPack[selectedPackLabel!]!
                          .map((e) => e.label)
                          .toList(),
                      onCountriesChanged: (List<String> countryList) {
                        setState(() {
                          selectedCountriesPerPack[selectedPackLabel!] =
                              countryList.map((name) => DropdownItem(
                                label: name,
                                icon: Icons.language, // optional, not shown in flag UI
                              )).toList();
                        });
                      },
                      maxSelection: physicalCardSpecsPacks[selectedPackLabel!]!.travelCountriesIncluded,
                    ),


                ],
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Select Date', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: _buildDateTile(startDatesPerPack[selectedPackLabel], 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: _buildDateTile(endDatesPerPack[selectedPackLabel], 'End Date'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedPackLabel == null) {
                      showError(context, "Please select a card pack.");
                      return;
                    }

                    final selectedPack = physicalCardSpecsPacks[selectedPackLabel!]!;
                    final selectedCountries = selectedCountriesPerPack[selectedPackLabel!] ?? [];
                    final startDate = startDatesPerPack[selectedPackLabel!];
                    final endDate = endDatesPerPack[selectedPackLabel!];

                    if (selectedCountries.isEmpty) {
                      showError(context, "Please select at least one destination country.");
                      return;
                    }

                    if (selectedCountries.length > selectedPack.travelCountriesIncluded) {
                      showError(context, "You can select up to ${selectedPack.travelCountriesIncluded} countries.");
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

                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text("Travel Plan Added"),
                        content: Text(
                          "Pack: ${selectedPack.label}\n"
                              "Countries: ${selectedCountries.map((e) => e.label).join(', ')}\n"
                              "Duration: $travelDays days\n"
                              "Max Allowed: ${selectedPack.maxTravelDays} days",
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: const Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Travel plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
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

  void showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
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
}
