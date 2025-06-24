import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteCardSection extends StatelessWidget {
  final bool isRequestSent;
  final String? blockReasonLabel;
  final VoidCallback onDeleteTap;
  final String buttonTitle;
  final bool isEnabled;

  const DeleteCardSection({
    Key? key,
    required this.isRequestSent,
    required this.blockReasonLabel,
    required this.onDeleteTap,
    this.buttonTitle = "Delete Card",
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 130,
                child: Divider(color: Color(0xFFB0B0B0), thickness: 2),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Delete Card",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(
                width: 130,
                child: Divider(color: Color(0xFFB0B0B0), thickness: 2),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 370,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1D1D6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text.rich(
                  TextSpan(
                    text:
                    "Deleting this card will permanently remove it from your profile. You will no longer be able to use it for transactions, and linked services like subscriptions or online payments will be disabled.",
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: Color(0xFF3C3C43),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: !isRequestSent
                      ? Padding(
                    key: const ValueKey("beforeRequestSpan"),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Submitting a secure unlink request...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.8,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInBack,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                  child: isRequestSent
                      ? CupertinoButton.filled(
                    key: const ValueKey("sentDeleteBtn"),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.checkmark_seal_fill, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Request Sent",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                  )
                      : GestureDetector(
                    key: const ValueKey("deleteBtn"),
                    onTap: isEnabled ? onDeleteTap : null,  // ✅ Disable tap when isEnabled is false
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isEnabled ? const Color(0xFFFF3B30) : const Color(0xFFFF3B30).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isEnabled
                            ? [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                            : [],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.delete_solid, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text("Delete Card",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
