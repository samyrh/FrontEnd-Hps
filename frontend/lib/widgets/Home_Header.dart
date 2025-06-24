import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../dto/card_dto/UserInfoDto.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback? onNotificationsPressed;
  final int unreadCount;

  const HomeHeader({
    super.key,
    this.onNotificationsPressed,
    this.unreadCount = 0,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? username;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    _loadUser();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadUser());
  }

  Future<void> _loadUser() async {
    final user = await AuthService().loadUserInfo();
    if (user != null && mounted) {
      setState(() {
        username = user.username ?? 'Cardholder';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 18) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 👤 User icon + Greeting + Name in a Row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 👤 Custom icon
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.04),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/me_user.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),

              // 👋 Greeting + Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      username ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E2D),
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🔔 Notification icon with animation and badge
        GestureDetector(
          onTap: widget.onNotificationsPressed,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (widget.unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        '${widget.unreadCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

}
