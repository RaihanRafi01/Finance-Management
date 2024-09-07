import 'package:finance_management/firebase_options.dart';
import 'package:finance_management/ui/screens/chart.dart';
import 'package:finance_management/ui/screens/authentication.dart';
import 'package:finance_management/ui/screens/home.dart';
import 'package:finance_management/ui/screens/newFinance.dart';
import 'package:finance_management/ui/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Management',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 17, 177, 172)),
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          if(snapshot.hasData){
            return const NewFinanceScreen();
          }
          return const AuthScreen();
        },),
    );
  }
}