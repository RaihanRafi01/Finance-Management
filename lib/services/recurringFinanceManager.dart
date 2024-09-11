import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecurringFinanceManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAndAddRecurringFinance() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedMonth =
        prefs.getInt('lastCheckedMonth') ?? DateTime.now().month;
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    print('Last Checked Month: $lastCheckedMonth');
    print('Current Month: $currentMonth');

    if (currentMonth != lastCheckedMonth ||
        currentYear != DateTime.now().year) {
      await _checkAndAddRecurringEntries();

      await prefs.setInt('lastCheckedMonth', currentMonth);
    }
  }

  Future<void> _checkAndAddRecurringEntries() async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        throw Exception('User is not logged in.');
      }

      // Process recurring income
      await _processRecurringEntries('Income');

      // Process recurring expenses
      await _processRecurringEntries('Expense');
    } catch (e) {
      print('Error checking and adding recurring entries: $e');
    }
  }

  Future<void> _processRecurringEntries(String collection) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection(collection)
        .where('isRecurring', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final startDate = (data['date'] as Timestamp).toDate();
      DateTime nextDate = _getFirstDayOfNextMonth(startDate);

      while (_isDateInPast(nextDate)) {
        await _addNewEntry(collection, data, nextDate);

        // Update to the next occurrence date
        nextDate = _getFirstDayOfNextMonth(nextDate);
        await _firestore
            .collection('users')
            .doc(uid)
            .collection(collection)
            .doc(doc.id)
            .update({
          'date': nextDate, // Update to the next occurrence date
        });
      }
    }
  }

  Future<void> _addNewEntry(
      String collection, Map<String, dynamic> data, DateTime newDate) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore.collection('users').doc(uid).collection(collection).add({
      ...data,
      'date': newDate, // Set date for the new month
      'isRecurring': false, // Mark the new entry as non-recurring
    });
  }

  // Helper function to get the first day of the next month
  DateTime _getFirstDayOfNextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  // Helper function to check if a date is in the past
  bool _isDateInPast(DateTime date) {
    return DateTime.now().isAfter(date);
  }

  // Method to set a recurring entry
  Future<void> setRecurringFinanceEntry({
    required String type,
    required String title,
    required int amount,
    required DateTime? startDate,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        throw Exception('User is not logged in.');
      }

      await _firestore.collection('users').doc(uid).collection(type).add({
        'title': title,
        'amount': amount,
        'date': startDate,
        'type': type,
        'isRecurring': true, // Mark this as a recurring entry
        'recurrenceType': 'monthly', // Specify recurrence type
        'uId': uid,
      });
    } catch (e) {
      print('Error setting recurring finance entry: $e');
    }
  }
}