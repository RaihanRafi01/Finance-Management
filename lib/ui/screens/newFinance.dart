import 'package:finance_management/ui/widgets/addFinance.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';

class NewFinanceScreen extends StatefulWidget {
  const NewFinanceScreen({super.key});

  @override
  State<NewFinanceScreen> createState() => _NewFinanceScreenState();
}

class _NewFinanceScreenState extends State<NewFinanceScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Add Finance',
      ),
      body: AddFinance(isRecurring: false),
    );
  }
}