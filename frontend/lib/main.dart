import 'package:flutter/material.dart';
import 'package:hps_direct/router/app_router.dart'; // ✅ Correct
// removed: import 'package:hps_direct/main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter, // ✅ Use your GoRouter instance
    );
  }
}
