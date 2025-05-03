import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmationCodeScreen extends StatelessWidget {
  final String email;

  const ConfirmationCodeScreen({
    super.key,
    this.email = 'lucasscott3@email.com',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: ConfirmationCodeInput(
          email: email,
          onCodeCompleted: (code) {
            print('Code completed: $code');
          },
          onResendCode: () {
            print('Resend code requested');
          },
        ),
      ),
    );
  }
}

class ConfirmationCodeInput extends StatefulWidget {
  final String email;
  final Function(String) onCodeCompleted;
  final VoidCallback onResendCode;

  const ConfirmationCodeInput({
    Key? key,
    required this.email,
    required this.onCodeCompleted,
    required this.onResendCode,
  }) : super(key: key);

  @override
  State<ConfirmationCodeInput> createState() => _ConfirmationCodeInputState();
}

class _ConfirmationCodeInputState extends State<ConfirmationCodeInput> {
  final int length = 4;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value.substring(0, 1);
      if (index < length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    }

    setState(() {
      _isFormFilled = _controllers.every((c) => c.text.trim().isNotEmpty);
    });

    if (_isFormFilled) {
      final code = _controllers.map((c) => c.text).join();
      widget.onCodeCompleted(code);
    }
  }

  void _onKeyPress(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      final isBackspace = event.logicalKey == LogicalKeyboardKey.backspace;

      if (isBackspace && _controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        _controllers[index - 1].clear();

        setState(() {
          _isFormFilled = _controllers.every((c) => c.text.trim().isNotEmpty);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 375),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We’ve sent a 4-digit code to',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF006FFD),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(length, (index) {
                return _buildCodeInput(index);
              }),
            ),
            const SizedBox(height: 28),
            TextButton(
              onPressed: widget.onResendCode,
              child: const Text(
                'Didn’t get the code? Resend',
                style: TextStyle(
                  color: Color(0xFF006FFD),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isFormFilled ? 1 : 0.6,
              child: ElevatedButton(
                onPressed: _isFormFilled
                    ? () {
                  final code = _controllers.map((c) => c.text).join();
                  widget.onCodeCompleted(code);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isFormFilled ? 4 : 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput(int index) {
    return SizedBox(
      width: 64,
      height: 64,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyPress(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2024),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0E3EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF006FFD), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          onChanged: (value) => _onChanged(value, index),
        ),
      ),
    );
  }
}
