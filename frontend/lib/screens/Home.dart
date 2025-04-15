import 'package:flutter/material.dart';
import 'package:sami/widgets/Transactions_Home.dart';
import '../widgets/Alerts_Home.dart';
import '../widgets/BlockCard_Home.dart';
import '../widgets/Home_Header.dart';
import '../widgets/Card_Scroller.dart';
import '../widgets/Account_Summary.dart';
import '../widgets/Navbar.dart';
import '../widgets/ActivateDisactivate.dart';
import '../widgets/UltraSwitch.dart'; // Only imported here


// hello
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: const HomeHeader(),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const CardScroller(),
            const SizedBox(height: 0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AccountSummary(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const BlockCardToggle(),

                  const SizedBox(height: 20),
                  ActivateDisactivate(
                    toggleSwitch: UltraSwitch(
                      value: isBlocked,
                      onChanged: (val) {
                        setState(() {
                          isBlocked = val;
                        });
                      },
                      activeColor: isBlocked ? Colors.redAccent : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AlertsWidget(),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TransactionsWidget(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: Navbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
