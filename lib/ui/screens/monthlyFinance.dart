import 'package:finance_management/ui/widgets/addFinance.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';

class MonthlyFinanceScreen extends StatefulWidget {
  const MonthlyFinanceScreen({super.key});

  @override
  State<MonthlyFinanceScreen> createState() => _MonthlyFinanceScreenState();
}

class _MonthlyFinanceScreenState extends State<MonthlyFinanceScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Monthly Finance',),
      body: AddFinance(isRecurring: true),
    );
  }
}

