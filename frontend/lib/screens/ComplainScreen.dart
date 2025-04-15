import 'package:flutter/material.dart';

class ComplainScreen extends StatefulWidget {
  const ComplainScreen({super.key});

  @override
  State<ComplainScreen> createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> {
  final TextEditingController controller = TextEditingController();
  bool isMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        isMessageEmpty = controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with centered title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),

                    ),
                  ),
                  const Text(
                    'Complain',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Text',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Justified Policy Description
              const Text(
                'We take every concern seriously. Please describe your issue clearly. Complaints must follow our community guidelines and terms of use.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Enter your Complain',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: controller,
                  maxLines: 7,
                  style: const TextStyle(fontSize: 15),
                  cursorColor: Colors.black87,
                  decoration: const InputDecoration(
                    hintText: 'Type your message here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isMessageEmpty
                      ? null
                      : () {
                    print('Message sent: ${controller.text}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMessageEmpty
                        ? const Color(0xFFB0C4DE)
                        : const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Text',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

    );
  }
}
