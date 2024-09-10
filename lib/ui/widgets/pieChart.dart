import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget BuildPieChart(double income, double expense, BuildContext context) {
  final total = income + expense;
  final incomePercent = total == 0 ? 0.0 : (income / total) * 100.0;
  final expensePercent = total == 0 ? 0.0 : (expense / total) * 100.0;

  bool isNotEmpty = total != 0;

  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Income vs Expense',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: incomePercent,
                      color: Colors.greenAccent,
                      title: '${incomePercent.toStringAsFixed(1)}%',
                      titleStyle: TextStyle(color: Colors.white, fontSize: 18),
                      radius: 90,
                    ),
                    PieChartSectionData(
                      value: expensePercent,
                      color: Colors.deepOrangeAccent,
                      title: '${expensePercent.toStringAsFixed(1)}%',
                      titleStyle: TextStyle(color: Colors.white, fontSize: 18),
                      radius: 90,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 11,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No Data Available'),
                        content: Text('The data for income and expense is not available or is zero.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/images/currency_logo.png'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
