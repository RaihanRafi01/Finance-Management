import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredIncomeAmount = 0;
  var _enteredIncomeTitle = '';
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
                  _enteredIncomeTitle = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Income'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an income amount';
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
                  _enteredIncomeAmount = int.parse(value!);
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
                        .doc(uid).collection('income')
                        .add({
                      'title' : _enteredIncomeTitle,
                      'date' : _selectedDate,
                      'amount' : _enteredIncomeAmount,
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
