import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecurringFinanceManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Call this method when the app starts
  Future<void> checkAndAddRecurringFinance() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAddedMonth = prefs.getInt('lastAddedMonth') ?? DateTime.now().month;

    // If a new month, add recurring income/expense
    if (DateTime.now().month != lastAddedMonth) {
      await _addRecurringFinanceEntries();

      // Update last added month
      await prefs.setInt('lastAddedMonth', DateTime.now().month);
    }
  }

  Future<void> _addRecurringFinanceEntries() async {
    try {
      final uid = _auth.currentUser!.uid;

      // Query recurring income
      final incomeSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('Income')
          .where('isRecurring', isEqualTo: true)
          .get();

      // Add recurring income entries for the new month
      for (var doc in incomeSnapshot.docs) {
        final data = doc.data();
        await _firestore.collection('users').doc(uid).collection('Income').add({
          ...data,
          'date': DateTime.now(), // Add for current month
        });
      }

      // Query recurring expense
      final expenseSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('Expense')
          .where('isRecurring', isEqualTo: true)
          .get();

      // Add recurring expense entries for the new month
      for (var doc in expenseSnapshot.docs) {
        final data = doc.data();
        await _firestore.collection('users').doc(uid).collection('Expense').add({
          ...data,
          'date': DateTime.now(), // Add for current month
        });
      }
    } catch (e) {
      print('Error adding recurring finance entries: $e');
    }
  }

  // Method to set a recurring entry
  Future<void> setRecurringFinanceEntry({
    required String type,
    required String title,
    required int amount,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection(type).add({
        'title': title,
        'amount': amount,
        'date': DateTime.now(),
        'type': type,
        'isRecurring': true, // Mark this as a recurring entry
        'recurrenceType': 'monthly',
        'uId': uid,
      });
    } catch (e) {
      print('Error setting recurring finance entry: $e');
    }
  }
}
