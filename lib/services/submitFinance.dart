import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/services/recurringFinanceManager.dart';
import 'package:finance_management/ui/screens/home.dart';
import 'package:finance_management/ui/screens/financeDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubmitFinance extends StatefulWidget {
  final String type;
  final bool isRecurring; // 'income' or 'expense'
  const SubmitFinance({super.key, required this.type, required this.isRecurring});

  @override
  State<SubmitFinance> createState() => _SubmitFinanceState();
}

class _SubmitFinanceState extends State<SubmitFinance> {
  final _formKey = GlobalKey<FormState>();
  var _enteredAmount = 0;
  var _enteredTitle = '';
  DateTime? _selectedDate;
  bool _isLoading = false;

  final RecurringFinanceManager _recurringFinanceManager = RecurringFinanceManager();

  void _datePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year, now.month + 1, now.day),
      initialDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields correctly.'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isRecurring) {
        // Set recurring finance entry
        await _recurringFinanceManager.setRecurringFinanceEntry(
          type: widget.type,
          title: _enteredTitle,
          amount: _enteredAmount,
          startDate: _selectedDate,
        );
      } else {
        // Normal submission without recurring
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection(widget.type)
            .add({
          'title': _enteredTitle,
          'date': _selectedDate,
          'amount': _enteredAmount,
          'type': widget.type,
          'isRecurring': false,
          'recurrenceType': 'monthly',
          'uId': uid,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.type} successfully submitted!'),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: () {
              // Navigate to details screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(index: 3),
                ),
              );
            },
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit ${widget.type}. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredTitle = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: widget.type),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return '${widget.type.capitalize()} must be greater than zero';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredAmount = int.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_selectedDate == null
                      ? 'No date Selected'
                      : DateFormat.yMd().format(_selectedDate!)),
                  onPressed: _datePicker,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
extension Capitalize on String {
  String capitalize() {
    if (this == null) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
