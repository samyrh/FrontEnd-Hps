import 'package:flutter/material.dart';
import '../widgets/FilterTab.dart';
import '../widgets/NotificationItem.dart';
import '../widgets/Navbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';
  int currentIndex = 0; // Set the proper index for this screen in navbar

  final List<Map<String, String>> notifications = [
    {
      'type': 'All',
      'message': 'Last chance to add a little extra to your Tuesday delivery.',
      'timeAgo': '9 days ago',
    },
    {
      'type': 'Block Card',
      'message': 'Your card has been successfully blocked.',
      'timeAgo': '2 days ago',
    },
    {
      'type': 'All',
      'message': 'Your weekly report is ready to view.',
      'timeAgo': '1 day ago',
    },
    {
      'type': 'Block Card',
      'message': 'Suspicious activity detected. Card auto-blocked.',
      'timeAgo': '4 hours ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final allCount = notifications.length;
    final blockCardCount =
        notifications.where((n) => n['type'] == 'Block Card').length;

    final filteredList = selectedFilter == 'All'
        ? notifications
        : notifications.where((n) => n['type'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
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
                        child: const Icon(Icons.chevron_left,
                            color: Colors.black),
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
                      onTap: () => setState(() => selectedFilter = 'All'),
                      child: FilterTab(
                        label: 'All',
                        count: allCount,
                        isSelected: selectedFilter == 'All',
                        countColor: const Color(0xFF007BFF),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => selectedFilter = 'Block Card'),
                      child: FilterTab(
                        label: 'Block Card',
                        count: blockCardCount,
                        isSelected: selectedFilter == 'Block Card',
                        countColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notifications List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isForward = selectedFilter == 'All';
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(isForward ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ));

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: ListView.builder(
                  key: ValueKey<String>(selectedFilter),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final notif = filteredList[index];
                    return NotificationItem(
                      imageUrl:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/6fe1bb5a78eaf52bfdf097e3b6efd803539803b1',
                      message: notif['message']!,
                      timeAgo: notif['timeAgo']!,
                      type: notif['type']!,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // 👇 iOS-style bottom nav bar
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
