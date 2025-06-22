import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../dto/NotificationPreferencesDTO.dart';
import '../services/event/NotificationPreferenceService.dart';
import '../widgets/NotificationToggleSwitch.dart';
import '../widgets/Toast.dart';

class Notificationparametre extends StatefulWidget {
  const Notificationparametre({Key? key}) : super(key: key);

  @override
  State<Notificationparametre> createState() => _NotificationparametreState();
}

class _NotificationparametreState extends State<Notificationparametre> {
  bool cardStatusNotification = false;
  bool cardCancelNotification = false;
  bool newCardRequestNotification = false;
  bool cardReplacementNotification = false;
  bool travelPlanNotification = false;
  bool transactionNotification = false;
  bool _isDirty = false;
  bool isLoading = true;

  final NotificationPreferenceService _service = NotificationPreferenceService();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadPreferences());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    if (_isDirty) return;
    final dto = await _service.fetchPreferences();
    if (dto != null) {
      setState(() {
        cardStatusNotification = dto.cardStatusNotification;
        cardCancelNotification = dto.cardCancelNotification;
        newCardRequestNotification = dto.newCardRequestNotification;
        cardReplacementNotification = dto.cardReplacementNotification;
        travelPlanNotification = dto.travelPlanNotification;
        transactionNotification = dto.transactionNotification;
        isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    final dto = NotificationPreferencesDTO(
      cardStatusNotification: cardStatusNotification,
      cardCancelNotification: cardCancelNotification,
      newCardRequestNotification: newCardRequestNotification,
      cardReplacementNotification: cardReplacementNotification,
      travelPlanNotification: travelPlanNotification,
      transactionNotification: transactionNotification,
    );
    final success = await _service.updatePreferences(dto);
    showCupertinoGlassToast(context, success ? "Preferences updated" : "Update failed", isSuccess: success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFCFCFE), Color(0xFFF6F8FF), Color(0xFFFFF0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.05),
                            ),
                            child: const Icon(CupertinoIcons.back, size: 20),
                          ),
                        ),
                        const Text(
                          'Notification Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                ..._buildNotificationSections(context),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationSections(BuildContext context) {
    return [
      _buildSection('Card Status Changes', 'Card blocked/unblocked', cardStatusNotification, CupertinoIcons.lock),
      _buildSection('Card Cancel & Reactivation', 'Card canceled/reactivated', cardCancelNotification, CupertinoIcons.xmark_circle),
      _buildSection('New Card Requests', 'New card approved/rejected', newCardRequestNotification, CupertinoIcons.creditcard),
      _buildSection('Card Replacement', 'Replacement card status', cardReplacementNotification, CupertinoIcons.arrow_2_circlepath),
      _buildSection('Travel Plan Notifications', 'Travel plan updates', travelPlanNotification, CupertinoIcons.airplane),
      _buildSection('Transaction Notifications', 'Incoming transaction', transactionNotification, CupertinoIcons.money_dollar_circle),
    ];
  }

  Widget _buildSection(String title, String label, bool value, IconData icon) {
    final screenPadding = MediaQuery.of(context).size.width * 0.05;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 24, bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: CupertinoColors.systemGrey2,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 22, color: CupertinoColors.systemGrey),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _getSubtitle(label),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                        NotificationToggleSwitch(
                          value: value,
                          onChanged: (val) {
                            setState(() {
                              switch (label) {
                                case 'Card blocked/unblocked':
                                  cardStatusNotification = val;
                                  break;
                                case 'Card canceled/reactivated':
                                  cardCancelNotification = val;
                                  break;
                                case 'New card approved/rejected':
                                  newCardRequestNotification = val;
                                  break;
                                case 'Replacement card status':
                                  cardReplacementNotification = val;
                                  break;
                                case 'Travel plan updates':
                                  travelPlanNotification = val;
                                  break;
                                case 'Incoming transaction':
                                  transactionNotification = val;
                                  break;
                              }
                            });
                            _savePreferences();
                          },
                          label: label,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(String label) {
    switch (label) {
      case 'Card blocked/unblocked':
        return 'Alerts for card being locked or unlocked.';
      case 'Card canceled/reactivated':
        return 'Notified when card is closed or reactivated.';
      case 'New card approved/rejected':
        return 'Track status of new card requests.';
      case 'Replacement card status':
        return 'Updates on replacement card progress.';
      case 'Travel plan updates':
        return 'Travel alerts for card access abroad.';
      case 'Incoming transaction':
        return 'See when transactions hit your card.';
      default:
        return '';
    }
  }
}
