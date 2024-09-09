import 'package:finance_management/ui/screens/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.teal,
      actions: [
        IconButton(
          onPressed: () async {
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              // Sign out from Google (if signed in with Google)
              GoogleSignIn googleSignIn = GoogleSignIn();
              if (await googleSignIn.isSignedIn()) {
                await googleSignIn.signOut();
              }
              // Clear all previous routes and navigate to the AuthScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
          },
          icon: const Icon(Icons.exit_to_app_rounded),
        ),
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
