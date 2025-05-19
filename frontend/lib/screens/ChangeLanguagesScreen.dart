import 'package:flutter/material.dart';

import '../widgets/CustomDropdown.dart';


class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  DropdownItem? selectedLanguage;
  int currentIndex = 3; // Adjust according to nav index

  final List<DropdownItem> languages = const [
    DropdownItem(label: 'English (EN)', icon: null),
    DropdownItem(label: 'Français (FR)', icon: null),
    DropdownItem(label: 'العربية (AR)', icon: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),
                        ),
                        const Spacer(),
                        const Text(
                          'Change Language',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 36),
                      ],
                    ),

                    const SizedBox(height: 80),

                    // Image
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 32),
                      child: AspectRatio(
                        aspectRatio: 1.16,
                        child: Image.network(
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/05d25b2d67e8e34ae30976a256ec25d773211ef6?placeholderIfAbsent=true',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),

                    // Dropdown
                    CustomDropdown(
                      label: 'Choose the language',
                      items: languages,
                      selectedItem: selectedLanguage,
                      onChanged: (item) {
                        setState(() => selectedLanguage = item);
                      },
                      icon: Icons.language,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

    );
  }
}
