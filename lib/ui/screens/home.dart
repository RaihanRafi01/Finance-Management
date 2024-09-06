import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/ui/widgets/customAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredIncomeAmount = 0;
  var _enteredExpenseAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (ctx, userSnapshots) {
              if (userSnapshots.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnapshots.hasData || userSnapshots.data!.data() == null) {
                return const Center(child: Text('No user found'));
              }
              if (userSnapshots.hasError) {
                return const Center(child: Text('Something went wrong, please try again...'));
              }
              Map<String, dynamic> data =
              userSnapshots.data!.data() as Map<String, dynamic>;
              var balance = data['balance'] ?? 0;

              return Column(
                children: [
                  Text('Current balance is: $balance'),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        IconButton(
                          iconSize: 100,
                          color: Colors.greenAccent,
                          onPressed: () async {
                            final isValid = _formKey.currentState!.validate();
                            if (!isValid) {
                              return;
                            }

                            _formKey.currentState!.save();

                            var totalAmount = balance + _enteredIncomeAmount;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'balance': totalAmount,
                            });
                          },
                          icon: const Icon(Icons.add_comment_rounded),
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
                              return 'Expense must be greater than zero';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredExpenseAmount = int.parse(value!);
                          },
                        ),
                        IconButton(
                          iconSize: 100,
                          color: Colors.redAccent,
                          onPressed: () async {
                            final isValid = _formKey.currentState!.validate();
                            if (!isValid) {
                              return;
                            }

                            _formKey.currentState!.save();

                            var totalAmount = balance - _enteredExpenseAmount;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'balance': totalAmount,
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
