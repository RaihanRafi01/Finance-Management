import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:finance_management/ui/widgets/noRecord.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() =>
      _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<BarChartGroupData> _incomeGroups = [];
  List<BarChartGroupData> _expenseGroups = [];
  List<BarChartGroupData> _allGroups = [];
  String _selectedView = 'weekly'; // default view
  String _selectedDataType = 'Income'; // 'income', 'expense', or 'both'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Query incomeQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Income')
        .orderBy('date');

    Query expenseQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Expense')
        .orderBy('date');

    DateTime startDate = _getStartDate();
    incomeQuery = incomeQuery.where('date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    expenseQuery = expenseQuery.where('date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));

    final incomeSnapshot = await incomeQuery.get();
    final expenseSnapshot = await expenseQuery.get();

    List<BarChartGroupData> incomeGroups = incomeSnapshot.docs.map((doc) {
      final income = doc.data() as Map<String, dynamic>;
      final date = (income['date'] as Timestamp).toDate();
      final amount = (income['amount'] as num).toDouble();

      double xValue = _getXValue(date);

      return BarChartGroupData(
        x: xValue.toInt(),
        barRods: [
          BarChartRodData(
            toY: amount < 0 ? 0 : amount, // Avoid negative amounts
            color: Colors.greenAccent,
            width: 16, // Adjust bar width as needed
          ),
        ],
      );
    }).toList();

    List<BarChartGroupData> expenseGroups = expenseSnapshot.docs.map((doc) {
      final expense = doc.data() as Map<String, dynamic>;
      final date = (expense['date'] as Timestamp).toDate();
      final amount = (expense['amount'] as num).toDouble();

      double xValue = _getXValue(date);

      return BarChartGroupData(
        x: xValue.toInt(),
        barRods: [
          BarChartRodData(
            toY: amount < 0 ? 0 : amount, // Avoid negative amounts
            color: Colors.redAccent,
            width: 16, // Adjust bar width as needed
          ),
        ],
      );
    }).toList();

    setState(() {
      _incomeGroups = incomeGroups;
      _expenseGroups = expenseGroups;
      _generateAllGroups();
    });
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedView) {
      case 'weekly':
        return now.subtract(Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month - 1, 1);
      case 'yearly':
        return DateTime(now.year - 2, 1, 1); // Adjusted for 5 years
      default:
        return now;
    }
  }

  double _getXValue(DateTime date) {
    switch (_selectedView) {
      case 'weekly':
        return date
            .difference(DateTime.now().subtract(Duration(days: 7)))
            .inDays
            .toDouble();
      case 'monthly':
        return date.month.toDouble();
      case 'yearly':
        return date.year.toDouble();
      default:
        return 0;
    }
  }

  void _generateAllGroups() {
    DateTime now = DateTime.now();
    _allGroups.clear();

    switch (_selectedView) {
      case 'weekly':
        for (int i = 0; i < 7; i++) {
          _addPlaceholderGroup(i);
        }
        break;
      case 'monthly':
        for (int i = 1; i <= 12; i++) {
          _addPlaceholderGroup(i);
        }
        break;
      case 'yearly':
        for (int i = now.year - 2; i <= now.year + 2; i++) {
          _addPlaceholderGroup(i);
        }
        break;
    }
  }

  void _addPlaceholderGroup(int x) {
    _allGroups.add(BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: 0, // Placeholder value
          color: Colors.transparent, // Transparent bars for placeholders
        ),
      ],
    ));
  }

  void _onViewChanged(String view) {
    setState(() {
      _selectedView = view;
      _fetchData(); // Re-fetch data based on selected view
    });
  }

  void _onDataTypeChanged(String dataType) {
    setState(() {
      _selectedDataType = dataType;
      _fetchData(); // Re-fetch data based on selected data type
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> mergedGroups = _mergeGroups();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Chart View',),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Income & Expense Chart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: ['Income', 'Expense', 'Both']
                  .map((dataType) => _selectedDataType == dataType)
                  .toList(),
              onPressed: (index) {
                _onDataTypeChanged(['Income', 'Expense', 'Both'][index]);
              },
              selectedColor: Colors.white, // Text color when selected
              fillColor: _selectedDataType == 'Income'
                  ? Colors.greenAccent
                  : _selectedDataType == 'Expense'
                  ? Colors.deepOrangeAccent
                  : Colors.blueGrey,
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Income')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Expense')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Both')),
              ],
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: ['weekly', 'monthly', 'yearly']
                  .map((view) => _selectedView == view)
                  .toList(),
              onPressed: (index) {
                _onViewChanged(['weekly', 'monthly', 'yearly'][index]);
              },
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Weekly')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Monthly')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Yearly')),
              ],
            ),
            const SizedBox(height: 20),
            _incomeGroups.isEmpty && _expenseGroups.isEmpty
                ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      NoRecord(),
                    ],
                  ),
                )
                : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 600,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: _calculateMaxY(),
                      titlesData: FlTitlesData(
                        bottomTitles: _buildBottomTitles(),
                        leftTitles: _buildLeftTitles(),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                            color: const Color(0xff37434d), width: 1),
                      ),
                      barGroups: mergedGroups,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AxisTitles _buildBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          String title;
          if (_selectedView == 'weekly') {
            final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            title = (value.toInt() >= 0 && value.toInt() < weekdays.length)
                ? weekdays[value.toInt()]
                : '';
          } else if (_selectedView == 'monthly') {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            title = (value.toInt() >= 0 && value.toInt() < months.length)
                ? months[value.toInt()]
                : '';
          } else if (_selectedView == 'yearly') {
            title = value.toInt().toString();
          } else {
            title = '';
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(title, style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }

  AxisTitles _buildLeftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        reservedSize: 40,
        showTitles: true,
        interval: _calculateYInterval(),
        getTitlesWidget: (value, meta) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  List<BarChartGroupData> _mergeGroups() {
    final mergedGroups = List<BarChartGroupData>.from(_allGroups);

    if (_selectedDataType == 'Income' || _selectedDataType == 'Both') {
      for (var group in _incomeGroups) {
        int index = mergedGroups.indexWhere((g) => g.x == group.x);
        if (index != -1) {
          mergedGroups[index] = mergedGroups[index].copyWith(
            barRods: [
              ...mergedGroups[index].barRods,
              ...group.barRods,
            ],
          );
        } else {
          mergedGroups.add(group);
        }
      }
    }

    if (_selectedDataType == 'Expense' || _selectedDataType == 'Both') {
      for (var group in _expenseGroups) {
        int index = mergedGroups.indexWhere((g) => g.x == group.x);
        if (index != -1) {
          mergedGroups[index] = mergedGroups[index].copyWith(
            barRods: [
              ...mergedGroups[index].barRods,
              ...group.barRods,
            ],
          );
        } else {
          mergedGroups.add(group);
        }
      }
    }

    return mergedGroups;
  }

  double _calculateMaxY() {
    final allYValues = [
      ..._incomeGroups.expand((group) => group.barRods.map((rod) => rod.toY)),
      ..._expenseGroups.expand((group) => group.barRods.map((rod) => rod.toY)),
    ];
    if (allYValues.isEmpty) return 0;
    final maxYValue = allYValues.reduce((a, b) => a > b ? a : b);
    return (maxYValue * 1.2).ceilToDouble(); // Add some padding to maxY
  }

  double _calculateYInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    return 50;
  }
}
