import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

final Map<String, String> countryFlags = {
  "Afghanistan": "🇦🇫",
  "Albania": "🇦🇱",
  "Algeria": "🇩🇿",
  "Andorra": "🇦🇩",
  "Angola": "🇦🇴",
  "Argentina": "🇦🇷",
  "Armenia": "🇦🇲",
  "Australia": "🇦🇺",
  "Austria": "🇦🇹",
  "Azerbaijan": "🇦🇿",
  "Bahamas": "🇧🇸",
  "Bahrain": "🇧🇭",
  "Bangladesh": "🇧🇩",
  "Belarus": "🇧🇾",
  "Belgium": "🇧🇪",
  "Benin": "🇧🇯",
  "Bhutan": "🇧🇹",
  "Bolivia": "🇧🇴",
  "Bosnia": "🇧🇦",
  "Botswana": "🇧🇼",
  "Brazil": "🇧🇷",
  "Brunei": "🇧🇳",
  "Bulgaria": "🇧🇬",
  "Burkina Faso": "🇧🇫",
  "Burundi": "🇧🇮",
  "Cambodia": "🇰🇭",
  "Cameroon": "🇨🇲",
  "Canada": "🇨🇦",
  "Chad": "🇹🇩",
  "Chile": "🇨🇱",
  "China": "🇨🇳",
  "Colombia": "🇨🇴",
  "Congo": "🇨🇬",
  "Costa Rica": "🇨🇷",
  "Croatia": "🇭🇷",
  "Cuba": "🇨🇺",
  "Cyprus": "🇨🇾",
  "Czech Republic": "🇨🇿",
  "Denmark": "🇩🇰",
  "Djibouti": "🇩🇯",
  "Dominican Republic": "🇩🇴",
  "Ecuador": "🇪🇨",
  "Egypt": "🇪🇬",
  "El Salvador": "🇸🇻",
  "Estonia": "🇪🇪",
  "Ethiopia": "🇪🇹",
  "Fiji": "🇫🇯",
  "Finland": "🇫🇮",
  "France": "🇫🇷",
  "Gabon": "🇬🇦",
  "Gambia": "🇬🇲",
  "Georgia": "🇬🇪",
  "Germany": "🇩🇪",
  "Ghana": "🇬🇭",
  "Greece": "🇬🇷",
  "Guatemala": "🇬🇹",
  "Haiti": "🇭🇹",
  "Honduras": "🇭🇳",
  "Hungary": "🇭🇺",
  "Iceland": "🇮🇸",
  "India": "🇮🇳",
  "Indonesia": "🇮🇩",
  "Iran": "🇮🇷",
  "Iraq": "🇮🇶",
  "Ireland": "🇮🇪",
  "Israel": "🇮🇱",
  "Italy": "🇮🇹",
  "Ivory Coast": "🇨🇮",
  "Jamaica": "🇯🇲",
  "Japan": "🇯🇵",
  "Jordan": "🇯🇴",
  "Kazakhstan": "🇰🇿",
  "Kenya": "🇰🇪",
  "Kuwait": "🇰🇼",
  "Laos": "🇱🇦",
  "Latvia": "🇱🇻",
  "Lebanon": "🇱🇧",
  "Liberia": "🇱🇷",
  "Libya": "🇱🇾",
  "Lithuania": "🇱🇹",
  "Luxembourg": "🇱🇺",
  "Madagascar": "🇲🇬",
  "Malawi": "🇲🇼",
  "Malaysia": "🇲🇾",
  "Maldives": "🇲🇻",
  "Mali": "🇲🇱",
  "Malta": "🇲🇹",
  "Mexico": "🇲🇽",
  "Moldova": "🇲🇩",
  "Monaco": "🇲🇨",
  "Mongolia": "🇲🇳",
  "Morocco": "🇲🇦",
  "Mozambique": "🇲🇿",
  "Myanmar": "🇲🇲",
  "Namibia": "🇳🇦",
  "Nepal": "🇳🇵",
  "Netherlands": "🇳🇱",
  "New Zealand": "🇳🇿",
  "Nicaragua": "🇳🇮",
  "Niger": "🇳🇪",
  "Nigeria": "🇳🇬",
  "North Korea": "🇰🇵",
  "Norway": "🇳🇴",
  "Oman": "🇴🇲",
  "Pakistan": "🇵🇰",
  "Panama": "🇵🇦",
  "Paraguay": "🇵🇾",
  "Peru": "🇵🇪",
  "Philippines": "🇵🇭",
  "Poland": "🇵🇱",
  "Portugal": "🇵🇹",
  "Qatar": "🇶🇦",
  "Romania": "🇷🇴",
  "Russia": "🇷🇺",
  "Rwanda": "🇷🇼",
  "Saudi Arabia": "🇸🇦",
  "Senegal": "🇸🇳",
  "Serbia": "🇷🇸",
  "Singapore": "🇸🇬",
  "Slovakia": "🇸🇰",
  "Slovenia": "🇸🇮",
  "Somalia": "🇸🇴",
  "South Africa": "🇿🇦",
  "South Korea": "🇰🇷",
  "Spain": "🇪🇸",
  "Sri Lanka": "🇱🇰",
  "Sudan": "🇸🇩",
  "Sweden": "🇸🇪",
  "Switzerland": "🇨🇭",
  "Syria": "🇸🇾",
  "Taiwan": "🇹🇼",
  "Tajikistan": "🇹🇯",
  "Tanzania": "🇹🇿",
  "Thailand": "🇹🇭",
  "Tunisia": "🇹🇳",
  "Turkey": "🇹🇷",
  "Uganda": "🇺🇬",
  "Ukraine": "🇺🇦",
  "United Arab Emirates": "🇦🇪",
  "United Kingdom": "🇬🇧",
  "United States": "🇺🇸",
  "Uruguay": "🇺🇾",
  "Uzbekistan": "🇺🇿",
  "Venezuela": "🇻🇪",
  "Vietnam": "🇻🇳",
  "Yemen": "🇾🇪",
  "Zambia": "🇿🇲",
  "Zimbabwe": "🇿🇼",
};

class CountriesDropdown extends StatelessWidget {
  final List<String> selectedCountries;
  final ValueChanged<List<String>> onCountriesChanged;
  final int maxSelection;

  const CountriesDropdown({
    Key? key,
    required this.selectedCountries,
    required this.onCountriesChanged,
    required this.maxSelection,
  }) : super(key: key);



  void _openCountryModal(BuildContext context) {
    String localSearch = '';
    List<String> tempSelected = List.from(selectedCountries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 18,
                  offset: Offset(0, -4),
                )
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final filtered = countryFlags.entries
                    .where((entry) => entry.key
                    .toLowerCase()
                    .contains(localSearch.toLowerCase()))
                    .toList();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      CupertinoSearchTextField(
                        placeholder: "Search countries",
                        onChanged: (value) => setModalState(() {
                          localSearch = value;
                        }),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                          child: Text(
                            "No country found.",
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        )
                            : ScrollConfiguration(
                          behavior: const CupertinoScrollBehavior(),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                            ),
                            itemBuilder: (context, index) {
                              final country = filtered[index].key;
                              final flag = filtered[index].value;
                              final isSelected = tempSelected.contains(country);
                              final isEnabled = isSelected || tempSelected.length < maxSelection;

                              return ListTile(
                                enabled: isEnabled,
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                leading: Text(flag, style: const TextStyle(fontSize: 22)),
                                title: Text(
                                  country,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isEnabled ? Colors.black : Colors.grey,
                                  ),
                                ),
                                trailing: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: isSelected
                                      ? Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.black,
                                    size: 22,
                                    key: ValueKey(true),
                                  )
                                      : const SizedBox(
                                      width: 22, key: ValueKey(false)),
                                ),
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      tempSelected.remove(country);
                                    } else {
                                      if (tempSelected.length < maxSelection) {
                                        tempSelected.add(country);
                                      } else {
                                        HapticFeedback.mediumImpact();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'You can select up to $maxSelection countries.',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            if (tempSelected.length <= maxSelection &&
                                !ListEquality().equals(tempSelected, selectedCountries)) {
                              onCountriesChanged(tempSelected);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tempSelected.isEmpty
                                    ? 'Cancel'
                                    : 'Confirm Selection',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                    (tempSelected.isEmpty ||
                                        tempSelected.length <= maxSelection)
                                        ? 1
                                        : 0.5,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final text = selectedCountries.isEmpty
        ? 'Choose countries'
        : selectedCountries
        .map((country) => '${countryFlags[country]} $country')
        .join(', ');

    return GestureDetector(
      onTap: () => _openCountryModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4.withOpacity(0.5),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
