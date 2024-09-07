import 'package:flutter/material.dart';
import 'package:finance_management/services/submitFinance.dart';

class AddFinance extends StatefulWidget {
  final bool isRecurring;
  const AddFinance({super.key, required this.isRecurring});

  @override
  State<AddFinance> createState() => _AddFinanceState();
}

class _AddFinanceState extends State<AddFinance> with SingleTickerProviderStateMixin {
  bool isIncome = true; // Track whether "Income" or "Expense" is selected
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  void _toggleType(bool value) {
    setState(() {
      isIncome = value;
      if (isIncome) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define colors for Income and Expense
    final Color cardColor = isIncome ? Colors.teal[100]! : Colors.deepOrange[100]!;
    final Color iconColor = isIncome ? Colors.teal : Colors.deepOrange;
    final String text = isIncome
        ? (widget.isRecurring ? 'Monthly Income' : 'Income')
        : (widget.isRecurring ? 'Monthly Expense' : 'Expense');


    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardColor, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isIncome ? Icons.monetization_on : Icons.money_off,
                        size: 32,
                        color: iconColor,
                      ),
                      SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                          fontFamily: 'Roboto', // Replace with your custom font if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Switch(
                    value: isIncome,
                    onChanged: _toggleType,
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: iconColor.withOpacity(0.5),
                    inactiveTrackColor: iconColor.withOpacity(0.2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, Colors.white],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SubmitFinance(type: text,isRecurring: widget.isRecurring,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
