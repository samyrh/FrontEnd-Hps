// app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sami/screens/ChooseCardColorScreen.dart';
import 'package:sami/screens/Home.dart';
import 'package:sami/screens/Landing1.dart';
import 'package:sami/screens/Landing2.dart';
import 'package:sami/screens/Landing3.dart';
import 'package:sami/screens/NewCard.dart';
import 'package:sami/screens/PhysicalCardDetailsScreen.dart';
import 'package:sami/screens/VirtualCardDetailsScreen.dart';
import '../screens/AiScreen1.dart';
import '../screens/Landing4.dart';
import '../screens/Menu.dart';
import '../screens/NotificationsScreen.dart';
import '../screens/cards_screen.dart';
import '../screens/transactions_screen.dart';

/// ✅ Reusable slide transition page helper
CustomTransitionPage buildSlideTransitionPage({
  required Widget child,
  required GoRouterState state,
  bool slideFromRight = true,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: slideFromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      );
    },
  );
}

/// ✅ Your main GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: '/landing',
  routes: [
    GoRoute(
      path: '/landing',
      name: 'landing',
      builder: (context, state) => const Landing1(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome1',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const Landing2(), state: state),
    ),
    GoRoute(
      path: '/welcome2',
      name: 'welcome2',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const Landing3(), state: state),
    ),
    GoRoute(
      path: '/welcome3',
      name: 'welcome3',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const Landing4(), state: state),
    ),
    GoRoute(
      path: '/virtual_card_details',
      name: 'virtual_card_details',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const VirtualCardDetailsScreen(), state: state),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const HomeScreen(), state: state),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const NotificationsScreen(), state: state),
    ),
    GoRoute(
      path: '/physical_card_details',
      name: 'physical card details',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return buildSlideTransitionPage(
          child: PhysicalCardDetailsScreen(
            autoScroll: extra?['autoScroll'] == true, // ✅ pass it here
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/transactions',
      name: 'transactions',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const TransactionsScreen(), state: state),
    ),

    GoRoute(
      path: '/cards',
      name: 'cards',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const MyCardsScreen(), state: state),
    ),
    GoRoute(
      path: '/ai_support',
      name: 'ai support',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const AIScreen(), state: state),
    ),
    GoRoute(
      path: '/menu',
      name: 'menu',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const EBankingMenuScreen(), state: state),
    ),
    GoRoute(
      path: '/add_card',
      name: 'add card',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const AddNewCard(), state: state),
    ),
    GoRoute(
      path: '/choose_color',
      name: 'choose color',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const ChooseCardColorScreen(), state: state),
    ),

  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('404 - Page not found')),
  ),
);
