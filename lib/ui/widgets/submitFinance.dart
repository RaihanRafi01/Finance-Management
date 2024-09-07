import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/screens/incomeExpenseDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubmitFinance extends StatefulWidget {
  final String type;
  const SubmitFinance({super.key, required this.type});

  @override
  State<SubmitFinance> createState() => _SubmitFinanceState();
}

class _SubmitFinanceState extends State<SubmitFinance> {
  final _formKey = GlobalKey<FormState>();
  var _enteredIncomeAmount = 0;
  var _enteredIncomeTitle = '';
  DateTime? _selectedDate;
  bool _isLoading = false;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(widget.type)
          .add({
        'title': _enteredIncomeTitle,
        'date': _selectedDate,
        'amount': _enteredIncomeAmount,
        'type': widget.type,
        'uId': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.type} successfully submitted!'),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DetailsScreen(),
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
          width: double.infinity, // Make sure the form takes the full width
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
                    _enteredIncomeTitle = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: widget.type),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ${widget.type} amount';
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
                    _enteredIncomeAmount = int.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_selectedDate == null
                      ? 'No date Selected'
                      : DateFormat.yMd().format(_selectedDate!)),
                  onPressed: _presentDatePicker,
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DetailsScreen(),
                      ),
                    );
                  },
                  child: const Text('View Details'),
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
