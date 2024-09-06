import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredAmount = 0;
  var _enteredTitle = '';
  DateTime? _selectedDate;

  void _presentDatePicker () async{
    final now = DateTime.now();
    final firstDate = DateTime(now.year-1,now.month,now.day);
    final pickedDate = await showDatePicker(context: context, firstDate: firstDate, lastDate: now,initialDate: now);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
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
                decoration: const InputDecoration(labelText: 'Expense'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expense amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Income must be greater than zero';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredAmount = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(icon: Icon(Icons.calendar_month),
                label: Text(_selectedDate == null? 'No date Selected' : DateFormat.yMd().format(_selectedDate!)),
                onPressed: _presentDatePicker,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance.collection('users')
                        .doc(uid).collection('expense')
                        .add({
                      'title' : _enteredTitle,
                      'date' : _selectedDate,
                      'amount' : _enteredAmount,
                      'uId' : uid,
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
