import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/screens/chart.dart';
import 'package:finance_management/ui/screens/details.dart';
import 'package:finance_management/ui/screens/newFinance.dart';
import 'package:finance_management/ui/screens/profile.dart';
import 'package:finance_management/ui/widgets/balanceBox.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:finance_management/ui/widgets/customCard.dart';
import 'package:finance_management/ui/widgets/pieChart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int index;

  const HomeScreen({super.key, required this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ChartScreen(),
    NewFinanceScreen(),
    DetailsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      setState(() {
        _currentIndex = widget.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? const CustomAppBar(title: 'Home') : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.cyan,
        color: Colors.teal,
        animationDuration: const Duration(milliseconds: 300),
        index: _currentIndex,
        // Update this line to reflect the current index
        items: const <Widget>[
          Icon(Icons.home_rounded, size: 26, color: Colors.white),
          Icon(Icons.bar_chart_rounded, size: 26, color: Colors.white),
          Icon(Icons.add_rounded, size: 26, color: Colors.white),
          Icon(Icons.list_rounded, size: 26, color: Colors.white),
          Icon(Icons.person_rounded, size: 26, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
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
                    children: [
                      BuildBalanceBox(data['totalBalance']),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BuildCard('Income', data['totalIncome'], Colors.green,
                              Icons.arrow_upward),
                          BuildCard('Expense', data['totalExpense'], Colors.red,
                              Icons.arrow_downward),
                        ],
                      ),
                      SizedBox(height: 16),
                      BuildPieChart(
                          data['totalIncome']!, data['totalExpense']!),
                    ],
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
}