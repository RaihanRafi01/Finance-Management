import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<Map<String, double>> _getTotalsStream() async* {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    while (true) {
      // Fetch income and expense snapshots
      final incomeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Income')
          .get();

      final expenseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Expense')
          .get();

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      // Calculate total income
      for (var doc in incomeSnapshot.docs) {
        totalIncome += doc.data()['amount']?.toDouble() ?? 0.0;
      }

      // Calculate total expense
      for (var doc in expenseSnapshot.docs) {
        totalExpense += doc.data()['amount']?.toDouble() ?? 0.0;
      }

      yield {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'totalBalance': totalIncome - totalExpense,
      };

      // Wait for a short time before the next update
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: StreamBuilder<Map<String, double>>(
        stream: _getTotalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Income: \$${data['totalIncome']?.toStringAsFixed(2)}'),
                  Text('Total Expense: \$${data['totalExpense']?.toStringAsFixed(2)}'),
                  Text('Total Balance: \$${data['totalBalance']?.toStringAsFixed(2)}'),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
