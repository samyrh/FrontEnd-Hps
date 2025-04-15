import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sami/widgets/Card_Scroller.dart';
import '../widgets/Countries_Dropdown.dart';
import '../widgets/CustomDropdown.dart';
import '../widgets/Navbar.dart';


class TravelPlanScreen extends StatefulWidget {
  const TravelPlanScreen({Key? key}) : super(key: key);

  @override
  State<TravelPlanScreen> createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen> {
  DropdownItem? selectedCountry;
  DropdownItem? selectedReason;
  DateTime? startDate;
  DateTime? endDate;
  int currentIndex = 0;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        isStart ? startDate = picked : endDate = picked;
      });
    }
  }

  final List<DropdownItem> reasonItems = [
    DropdownItem(label: 'Vacation', icon: Icons.beach_access),
    DropdownItem(label: 'Work', icon: Icons.work),
    DropdownItem(label: 'Study', icon: Icons.school),
    DropdownItem(label: 'Medical Treatment', icon: Icons.local_hospital),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 🔙 Back and Title
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
            const CardScroller(), // No padding needed here!

            const SizedBox(height: 24),

            // 🌍 Country Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CountriesDropdown(
                selectedCountry: selectedCountry?.label,
                onCountrySelected: (value) {
                  setState(() {
                    selectedCountry = DropdownItem(label: value, icon: null);
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📅 Date Selection
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
                      child: Container(
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
                              startDate == null
                                  ? 'Start Date'
                                  : DateFormat('dd MMM, yyyy').format(startDate!),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
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
                              endDate == null
                                  ? 'End Date'
                                  : DateFormat('dd MMM, yyyy').format(endDate!),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📄 Reason Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomDropdown(
                label: "Reason",
                icon: Icons.info_outline_rounded,
                selectedItem: selectedReason,
                items: reasonItems,
                onChanged: (item) => setState(() => selectedReason = item),
              ),
            ),

            const SizedBox(height: 40),

            // 📤 Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {}, // Add your action
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
          // Optional: Add navigation to different pages
        },
      ),
    );
  }
}
