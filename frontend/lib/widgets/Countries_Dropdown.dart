import 'package:flutter/material.dart';

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
  final String? selectedCountry;
  final ValueChanged<String> onCountrySelected;

  const CountriesDropdown({
    Key? key,
    required this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  void _openCountryModal(BuildContext context) {
    String localSearch = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = countryFlags.entries
                .where((entry) => entry.key
                .toLowerCase()
                .startsWith(localSearch.toLowerCase()))
                .toList();

            return Container(
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() => localSearch = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                      child: Text(
                        'No country found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final name = filtered[index].key;
                        final flag = filtered[index].value;
                        final isSelected = selectedCountry == name;

                        return ListTile(
                          leading: Text(flag, style: const TextStyle(fontSize: 24)),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded,
                              color: Colors.blue)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onCountrySelected(name);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCountryModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCountry != null
                  ? '${countryFlags[selectedCountry]} $selectedCountry'
                  : 'Choose Destination',
              style: const TextStyle(fontSize: 15),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}
