import 'package:finance_management/ui/screens/home.dart';
import 'package:flutter/material.dart';

class NoRecord extends StatelessWidget {
  const NoRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No records available.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(index: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Colors.teal,
            ),
            child: const Text(
              'Add Record',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}