import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dto/card_dto/EventResponseDTO.dart';
import '../services/event/EventService.dart';
import '../widgets/FilterTab.dart';
import '../widgets/NotificationItem.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';
  List<EventResponseDTO> allEvents = [];
  bool isLoading = true;
  bool isFilterLoading = false;

  final List<String> alertCategories = [
    'VIRTUAL_CARD_BLOCKED',
    'VIRTUAL_CARD_UNBLOCKED',
    'VIRTUAL_CARD_CANCELED',
    'PHYSICAL_CARD_BLOCKED',
    'PHYSICAL_CARD_UNBLOCKED',
    'PHYSICAL_CARD_CANCELED',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      await EventService().markAllEventsAsRead();
      final events = await EventService().fetchCardholderEvents();
      setState(() {
        allEvents = events;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load events: $e');
      setState(() => isLoading = false);
    }
  }

  void _onFilterChange(String newFilter) async {
    if (newFilter == selectedFilter) return;
    setState(() {
      isFilterLoading = true;
      selectedFilter = newFilter;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    setState(() {
      isFilterLoading = false;
    });
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'VIRTUAL_CARD_BLOCKED':
      case 'PHYSICAL_CARD_BLOCKED':
        return CupertinoIcons.lock_fill;
      case 'VIRTUAL_CARD_UNBLOCKED':
      case 'PHYSICAL_CARD_UNBLOCKED':
        return CupertinoIcons.lock_open_fill;
      case 'VIRTUAL_CARD_CANCELED':
      case 'PHYSICAL_CARD_CANCELED':
        return CupertinoIcons.clear_thick;
      default:
        return CupertinoIcons.bell;
    }
  }

  String formatTimestamp(String isoDate) {
    try {
      final parsedDate = DateTime.parse(isoDate);
      return DateFormat('EEEE, HH:mm').format(parsedDate);
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> _deleteEvent(EventResponseDTO event) async {
    try {
      await EventService().deleteEventById(event.id);
      setState(() {
        allEvents.removeWhere((e) => e.id == event.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Notification deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final alertEvents = allEvents.where((e) => alertCategories.contains(e.category)).toList();
    final displayedEvents = selectedFilter == 'All' ? allEvents : alertEvents;

    return CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF7F5),
              Color(0xFFFDF3F6),
              Color(0xFFF2EDF9),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E2D),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(CupertinoIcons.back, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _onFilterChange('All'),
                          child: FilterTab(
                            label: 'All',
                            count: allEvents.length,
                            isSelected: selectedFilter == 'All',
                            countColor: const Color(0xFF007BFF),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onFilterChange('Alerts'),
                          child: FilterTab(
                            label: 'Alerts',
                            count: alertEvents.length,
                            isSelected: selectedFilter == 'Alerts',
                            countColor: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Content with transition
                Expanded(
                  child: isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: Curves.fastOutSlowIn,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.02), // smoother entry
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: isFilterLoading
                        ? const Center(
                      key: ValueKey('loading'),
                      child: CupertinoActivityIndicator(radius: 10),
                    )
                        : ListView.builder(
                      key: ValueKey(selectedFilter),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayedEvents.length,
                      itemBuilder: (context, index) {
                        final event = displayedEvents[index];
                        return NotificationItem(
                          icon: getIconForCategory(event.category),
                          message: event.message,
                          timeAgo: formatTimestamp(event.sentAt),
                          type: event.category,
                          onClear: () => _deleteEvent(event),
                        );
                      },
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
