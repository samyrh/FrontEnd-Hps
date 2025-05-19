// app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/AiScreen1.dart';
import '../screens/CardPacksScreen.dart';
import '../screens/ChooseCardColorScreen.dart';
import '../screens/ComplainScreen.dart';
import '../screens/ContactUs.dart';
import '../screens/Home.dart';
import '../screens/Landing1.dart';
import '../screens/Landing2.dart';
import '../screens/Landing3.dart';
import '../screens/Landing4.dart';
import '../screens/Menu.dart';
import '../screens/NewCard.dart';
import '../screens/NotificationsScreen.dart';
import '../screens/PhysicalCardDetailsScreen.dart';
import '../screens/ProfileScreen.dart';
import '../screens/SecurityCodeSetUp.dart';
import '../screens/SecurityCodeVerificationScreen.dart';
import '../screens/Settings.dart';
import '../screens/TravelPlanScreen.dart';
import '../screens/VirtualCardDetailsScreen.dart';
import '../screens/cards_screen.dart';
import '../screens/sign_in.dart';
import '../screens/transactions_screen.dart';
import '../widgets/ResetPassword/Identify_User.dart';
import '../widgets/ResetPassword/Reset_PasswordScreen.dart';


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
    GoRoute(
      path: '/sign_in',
      name: 'sign in',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const SignInScreen(), state: state),
    ),
    GoRoute(
      path: '/identify_user',
      name: 'identify user',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const IdentifyUserScreen(), state: state),
    ),
    GoRoute(
      path: '/reset_password',
      name: 'reset password',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const ResetPasswordScreen(), state: state),
    ),

    GoRoute(
      path: '/verify_code',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final isFirstLogin = extra['isFirstLogin'] as bool? ?? false;
        final fromLogin = extra['fromLogin'] as bool? ?? false;

        return buildSlideTransitionPage(
          state: state,
          child: SecurityCodeVerificationScreen(
            isFirstLogin: isFirstLogin,
            fromLogin: fromLogin,
          ),
        );
      },
    ),

    GoRoute(
      path: '/sign_in_with_toast',
      name: 'sign in with toast',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const SignInScreen(showRedirectToast: true), state: state),
    ),
    GoRoute(
      path: '/security_code_setup',
      name: 'security code setup',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const SecurityCodeSetupScreen(), state: state),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const ProfileScreen(), state: state),
    ),
    GoRoute(
      path: '/travel_plan',
      name: 'travel_plan',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const TravelPlanScreen(), state: state),
    ),
    GoRoute(
      path: '/contact_us',
      name: 'contact_us',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const ContactUsScreen(), state: state),
    ),
    GoRoute(
      path: '/complain',
      name: 'complain',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const ComplainScreen(), state: state),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const SettingsScreen(), state: state),
    ),
    GoRoute(
      path: '/card_packs',
      name: 'card_packs',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(child: const CardPacksScreen(), state: state),
    ),


  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('404 - Page not found')),
  ),
);
