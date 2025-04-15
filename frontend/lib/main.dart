import 'package:flutter/material.dart';
import 'package:sami/screens/AiScreen1.dart';
import 'package:sami/screens/AiScreen2.dart';
import 'package:sami/screens/AiScreen3.dart';
import 'package:sami/screens/BrainBoxScreen.dart';
import 'package:sami/screens/ChangeLanguagesScreen.dart';
import 'package:sami/screens/ChangePassword.dart';
import 'package:sami/screens/ChooseCardColorScreen.dart';
import 'package:sami/screens/ComplainScreen.dart';
import 'package:sami/screens/Home.dart';
import 'package:sami/screens/Landing1.dart';
import 'package:sami/screens/Landing2.dart';
import 'package:sami/screens/Landing3.dart';
import 'package:sami/screens/Landing4.dart';
import 'package:sami/screens/NewCard.dart';
import 'package:sami/screens/PhysicalCardDetailsScreen.dart';
import 'package:sami/screens/ProfileScreen.dart';
import 'package:sami/screens/Settings.dart';
import 'package:sami/screens/SuccessScreen.dart';
import 'package:sami/screens/TestScreensSlider.dart';
import 'package:sami/screens/VirtualCardDetailsScreen.dart';
import 'package:sami/screens/TravelPlanScreen.dart';
import 'package:sami/screens/sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Screens Slider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AddNewCard(),
    );
  }
}
