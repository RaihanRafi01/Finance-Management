import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/screens/chart.dart';
import 'package:finance_management/ui/screens/incomeExpenseDetails.dart';
import 'package:finance_management/ui/screens/monthlyFinance.dart';
import 'package:finance_management/ui/screens/newFinance.dart';
import 'package:finance_management/ui/screens/profile.dart';
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

      for (var doc in incomeSnapshot.docs) {
        totalIncome += doc.data()['amount']?.toDouble() ?? 0.0;
      }

      for (var doc in expenseSnapshot.docs) {
        totalExpense += doc.data()['amount']?.toDouble() ?? 0.0;
      }

      yield {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'totalBalance': totalIncome - totalExpense,
      };

      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<Map<String, double>>(
              stream: _getTotalsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Income: \$${data['totalIncome']?.toStringAsFixed(2)}'),
                      Text('Total Expense: \$${data['totalExpense']?.toStringAsFixed(2)}'),
                      Text('Total Balance: \$${data['totalBalance']?.toStringAsFixed(2)}'),
                    ],
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartScreen()),
                );
              },
              child: Text('View Chart'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailsScreen()),
                );
              },
              child: Text('View Finance'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MonthlyFinanceScreen()),
                );
              },
              child: Text('Add Monthly Finance'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewFinanceScreen()),
                );
              },
              child: Text('Add Finance'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
