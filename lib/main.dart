import 'package:finance_management/firebase_options.dart';
import 'package:finance_management/services/recurringFinanceManager.dart';
import 'package:finance_management/ui/screens/authentication.dart';
import 'package:finance_management/ui/screens/home.dart';
import 'package:finance_management/ui/screens/monthlyFinance.dart';
import 'package:finance_management/ui/screens/newFinance.dart';
import 'package:finance_management/ui/screens/profile.dart';
import 'package:finance_management/ui/screens/splash.dart';
import 'package:finance_management/ui/widgets/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();

  // Initialize RecurringFinanceManager and check recurring entries
  final recurringFinanceManager = RecurringFinanceManager();
  await recurringFinanceManager.checkAndAddRecurringFinance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Management',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 17, 177, 172)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return HomeScreen(index: 0,);
          }
          return AuthScreen();
        },
      ),
    );
  }
}
