import 'package:flutter/cupertino.dart';
import 'package:sami/screens/AiScreen1.dart';
import 'package:sami/screens/AiScreen2.dart';
import 'package:sami/screens/AiScreen3.dart';
import 'package:sami/screens/BrainBoxScreen.dart';
import 'package:sami/screens/ChangeLanguagesScreen.dart';
import 'package:sami/screens/ChangePassword.dart';
import 'package:sami/screens/ComplainScreen.dart';
import 'package:sami/screens/NewCard.dart';
import 'package:sami/screens/NotificationsScreen.dart';
import 'package:sami/screens/PhysicalCardDetailsScreen.dart';
import 'package:sami/screens/ProfileScreen.dart';
import 'package:sami/screens/Settings.dart';
import 'package:sami/screens/SuccessScreen.dart';
import 'package:sami/screens/VirtualCardDetailsScreen.dart';
import 'package:sami/screens/sign_in.dart';
import 'package:sami/screens/sign_up.dart';
import 'package:sami/screens/transactions_screen.dart';
import 'package:sami/screens/travelPlanScreen.dart';

import 'ChooseCardColorScreen.dart';
import 'Home.dart';
import 'Landing1.dart';
import 'Landing2.dart';
import 'Landing3.dart';
import 'Landing4.dart';
import 'cards_screen.dart';
import 'confirmation.dart';

class TestScreensSlider extends StatelessWidget {
  const TestScreensSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Landing1(),
      const Landing2(),
      const Landing3(),
      const Landing4(),
      const SignInScreen(),
      const ChangePasswordScreen(),
      const ConfirmationCodeScreen(),
      const HomeScreen(),
      const NotificationsScreen(),
      const TransactionsScreen(),
      const MyCardsScreen(),
      const AddNewCard(),
      const ChooseCardColorScreen(),
      const SuccessScreen(),
      const PhysicalCardDetailsScreen(),
      const VirtualCardDetailsScreen(),
      const TravelPlanScreen(),
      const SettingsScreen(),
      const ComplainScreen(),
      const ChangeLanguage(),
      const ProfileScreen(),
      const ChangePasswordScreen(),
      const AIScreen(),
      const AIScreen2(),
      const AIScreen3(),
      const BrainBoxScreen(),
    ];

    return PageView.builder(
      itemCount: screens.length,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox.expand(
          child: SafeArea(
            child: screens[index],
          ),
        );
      },
    );
  }
}
