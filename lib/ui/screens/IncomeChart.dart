import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeChartScreen extends StatefulWidget {
  const IncomeChartScreen({super.key});

  @override
  State<IncomeChartScreen> createState() => _IncomeChartScreenState();
}

class _IncomeChartScreenState extends State<IncomeChartScreen> {
  List<BarChartGroupData> _incomeGroups = [];
  List<BarChartGroupData> _allGroups = [];
  String _selectedView = 'weekly'; // default view

  @override
  void initState() {
    super.initState();
    _fetchIncomeData();
  }

  Future<void> _fetchIncomeData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('income')
        .orderBy('date');

    DateTime startDate = _getStartDate();
    query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));

    final snapshot = await query.get();
    List<BarChartGroupData> groups = snapshot.docs.map((doc) {
      final income = doc.data() as Map<String, dynamic>;
      final date = (income['date'] as Timestamp).toDate();
      final amount = (income['amount'] as num).toDouble();

      double xValue = _getXValue(date);

      return BarChartGroupData(
        x: xValue.toInt(),
        barRods: [
          BarChartRodData(
            toY: amount < 0 ? 0 : amount, // Avoid negative amounts
            color: Colors.blue,
            width: 16, // Adjust bar width as needed
          ),
        ],
      );
    }).toList();

    setState(() {
      _incomeGroups = groups;
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
        return date.difference(DateTime.now().subtract(Duration(days: 7))).inDays.toDouble();
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
      _fetchIncomeData(); // Re-fetch data based on selected view
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> mergedGroups = _mergeGroups();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Income Chart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: ['weekly', 'monthly', 'yearly'].map((view) => _selectedView == view).toList(),
              onPressed: (index) {
                _onViewChanged(['weekly', 'monthly', 'yearly'][index]);
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Weekly')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Monthly')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yearly')),
              ],
            ),
            const SizedBox(height: 20),
            _incomeGroups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 600,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: (_incomeGroups.isNotEmpty ? _incomeGroups.map((group) => group.barRods.first.toY).reduce((a, b) => a > b ? a : b) : 0) + 100,
                      titlesData: FlTitlesData(
                        bottomTitles: _buildBottomTitles(),
                        leftTitles: _buildLeftTitles(),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xff37434d), width: 1),
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
            title = (value.toInt() >= 0 && value.toInt() < weekdays.length) ? weekdays[value.toInt()] : '';
          } else if (_selectedView == 'monthly') {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            title = (value.toInt() >= 0 && value.toInt() < months.length) ? months[value.toInt()] : '';
          } else if (_selectedView == 'yearly') {
            title = value.toInt().toString();
          } else {
            title = "";
          }
          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(title, style: const TextStyle(fontSize: 10)));
        },
      ),
    );
  }

  AxisTitles _buildLeftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          return Padding(padding: const EdgeInsets.only(right: 8.0), child: Text(value.toString(), style: const TextStyle(fontSize: 10)));
        },
      ),
    );
  }

  List<BarChartGroupData> _mergeGroups() {
    List<BarChartGroupData> mergedGroups = List.from(_allGroups);
    for (var group in _incomeGroups) {
      int index = mergedGroups.indexWhere((g) => g.x == group.x);
      if (index != -1) {
        mergedGroups[index] = group;
      }
    }
    return mergedGroups;
  }

  double _calculateMaxX() {
    double maxX = _incomeGroups.isNotEmpty
        ? _incomeGroups.map((group) => group.x.toDouble()).reduce((a, b) => a > b ? a : b)
        : 0;
    if (_selectedView == 'weekly') return 6;
    if (_selectedView == 'monthly') return 11;
    if (_selectedView == 'yearly') return (DateTime.now().year + 2).toDouble();
    return maxX;
  }
}