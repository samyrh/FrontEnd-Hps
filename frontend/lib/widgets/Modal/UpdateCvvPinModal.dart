import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateCvvPinModal extends StatefulWidget {
  const UpdateCvvPinModal({super.key});

  @override
  State<UpdateCvvPinModal> createState() => _UpdateCvvPinModalState();
}

class _UpdateCvvPinModalState extends State<UpdateCvvPinModal> with TickerProviderStateMixin {
  String? selectedCardId;
  String? selectedCardType;
  bool pinEntered = false;
  bool cvvRequested = false;
  bool successShown = false;

  final List<Map<String, String>> cards = [
    {'id': '1', 'type': 'physical', 'label': 'Visa Physical •••• 1234'},
    {'id': '2', 'type': 'virtual', 'label': 'Virtual Card •••• 5678'},
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _pinController = TextEditingController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _resetState() {
    setState(() {
      selectedCardId = null;
      selectedCardType = null;
      pinEntered = false;
      cvvRequested = false;
      successShown = false;
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: successShown ? _buildSuccess() : _buildForm(),
                    ),
                  ),
                ),
                _buildStickyFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Update CVV / PIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        _buildCardDropdown(),
        const SizedBox(height: 24),
        if (selectedCardType == 'physical') _buildPinInput(),
        if (selectedCardId != null) ...[
          const SizedBox(height: 24),
          _buildRequestCvvButton(),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCardDropdown() {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<Map<String, String>>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => ListView(
            shrinkWrap: true,
            children: cards
                .map(
                  (card) => ListTile(
                leading: Icon(
                  card['type'] == 'physical' ? Icons.credit_card : Icons.phone_android,
                  color: Colors.blueAccent,
                ),
                title: Text(card['label']!),
                onTap: () => Navigator.pop(context, card),
              ),
            )
                .toList(),
          ),
        );
        if (selected != null) {
          setState(() {
            selectedCardId = selected['id'];
            selectedCardType = selected['type'];
          });
          _scrollToBottom();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCardId != null
                  ? cards.firstWhere((c) => c['id'] == selectedCardId)['label']!
                  : 'Select your card',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            counterText: '',
          ),
          onChanged: (value) => setState(() => pinEntered = value.length == 4),
        ),
      ],
    );
  }

  Widget _buildRequestCvvButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() => cvvRequested = true);
        _scrollToBottom();
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Request CVV', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    final confirmEnabled = selectedCardId != null && (selectedCardType != 'physical' ? true : pinEntered) && cvvRequested;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _resetState,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmEnabled ? Colors.green : Colors.grey.shade400,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: confirmEnabled
                  ? () {
                setState(() => successShown = true);
                _scrollToBottom();
              }
                  : null,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        const Text('Update Successful', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
