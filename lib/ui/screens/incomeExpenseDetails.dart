import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/screens/home.dart';
import 'package:finance_management/ui/screens/newFinance.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:finance_management/ui/widgets/financeDetails.dart';
import 'package:finance_management/ui/widgets/noRecord.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _selectedIndex = 1;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<List<QuerySnapshot>> _getCombinedIncomeExpenseStream() {
    final incomeStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Income')
        .orderBy('date', descending: true)
        .snapshots();

    final expenseStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Expense')
        .orderBy('date', descending: true)
        .snapshots();

    return CombineLatestStream.list([incomeStream, expenseStream]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Finance Details'),
      body: Column(
        children: [
          // Top Navigation Bar
          BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.monetization_on,
                  color: _selectedIndex == 0 ? Colors.greenAccent : Colors.grey,
                ),
                label: 'Income',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.compare_arrows,
                  color: _selectedIndex == 1 ? Colors.teal : Colors.grey,
                ),
                label: 'Income + Expense',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.money_off,
                  color: _selectedIndex == 2 ? Colors.redAccent : Colors.grey,
                ),
                label: 'Expense',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: _selectedIndex == 2 ? Colors.redAccent : Colors.teal,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _selectedIndex == 1
                  ? StreamBuilder<List<QuerySnapshot>>(
                stream: _getCombinedIncomeExpenseStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      (snapshot.data![0].docs.isEmpty && snapshot.data![1].docs.isEmpty)) {
                    return NoRecord();
                  }

                  final combinedDocs = [
                    ...snapshot.data![0].docs,
                    ...snapshot.data![1].docs
                  ]..sort((a, b) => (b['date'] as Timestamp)
                      .compareTo(a['date'] as Timestamp));

                  final colors = combinedDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] as String?;
                    return type == 'Income'
                        ? Colors.greenAccent
                        : Colors.redAccent;
                  }).toList();

                  return FinanceDetails(
                    itemCount: combinedDocs.length,
                    financeDocs: combinedDocs,
                    colors: colors,
                    selectedIndex: _selectedIndex,
                  );
                },
              )
                  : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection(_selectedIndex == 0 ? 'Income' : 'Expense')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return NoRecord();
                  }

                  final color = _selectedIndex == 0
                      ? Colors.greenAccent
                      : Colors.redAccent;

                  return FinanceDetails(
                    itemCount: snapshot.data!.docs.length,
                    financeDocs: snapshot.data!.docs,
                    colors: List.generate(
                        snapshot.data!.docs.length, (_) => color),
                    selectedIndex: _selectedIndex,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
