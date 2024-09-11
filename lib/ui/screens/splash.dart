import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Management'),
      ),
      body: Center(
        child: SizedBox(
            height: 150,
            width: 150,
            child: Image.asset('assets/images/app_icon.png')),
      ),
    );
  }
}
