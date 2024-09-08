import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceDetails extends StatefulWidget {
  final int itemCount;
  final List<QueryDocumentSnapshot> financeDocs;
  final List<Color>? colors; // List of colors for items
  final int selectedIndex;

  const FinanceDetails({
    super.key,
    required this.itemCount,
    required this.financeDocs,
    required this.selectedIndex,
    this.colors,
  });

  @override
  _FinanceDetailsState createState() => _FinanceDetailsState();
}

class _FinanceDetailsState extends State<FinanceDetails> {
  late List<QueryDocumentSnapshot> _financeDocs;
  late List<Color>? _colors;
  late int _selectedIndex;
  QueryDocumentSnapshot? _lastDeletedItem;
  int? _lastDeletedIndex;
  String? _lastItemType;

  @override
  void initState() {
    super.initState();
    _financeDocs = widget.financeDocs;
    _colors = widget.colors;
    _selectedIndex = widget.selectedIndex;
  }

  Future<void> _handleDelete(String docId, int index) async {
    final deletedItem = _financeDocs[index];
    final itemTitle = deletedItem['title'];
    final itemType = deletedItem['type'];
    final isRecurring = deletedItem['isRecurring'];
    final recurrenceType = deletedItem['recurrenceType'];
    final uId = deletedItem['uId'];
    final itemAmount = deletedItem['amount'];
    final itemDate = deletedItem['date'];

    setState(() {
      _lastDeletedItem = deletedItem;
      _lastItemType = itemType;
      _lastDeletedIndex = index;
      _financeDocs.removeAt(index); // Remove item from the list
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(itemType)
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted successfully'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              print("Type is:"+itemType);
              print("Type is 2nd check:"+_lastItemType!);
              if (_lastDeletedItem != null && _lastDeletedIndex != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection(_lastItemType!)
                    .doc(_lastDeletedItem!.id)
                    .set({
                  'amount': (itemAmount),
                  'date': itemDate,
                  'isRecurring': isRecurring,
                  'recurrenceType': recurrenceType,
                  'title': itemTitle,
                  'type': itemType,
                  'uId': uId
                });

                setState(() {
                  _financeDocs.insert(_lastDeletedIndex!, _lastDeletedItem!); // Restore item to the list
                });
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Show error if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete item.'),
        ),
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context, String docId, String currentTitle, double currentAmount, DateTime currentDate, String currentType) async {
    final titleController = TextEditingController(text: currentTitle);
    final amountController = TextEditingController(text: currentAmount.toString());
    DateTime selectedDate = currentDate; // Initialize selectedDate with currentDate

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    'Date: ${DateFormat.yMMMd().format(selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (newDate != null && newDate != selectedDate) {
                        setState(() {
                          selectedDate = newDate; // Update selectedDate
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newTitle = titleController.text;
                final newAmount = double.tryParse(amountController.text) ?? currentAmount;

                try {
                  // Determine the correct collection based on the document's type
                  final collectionPath = currentType == 'Income' ? 'Income' : 'Expense';

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection(collectionPath)
                      .doc(docId)
                      .update({
                    'title': newTitle,
                    'amount': newAmount,
                    'date': Timestamp.fromDate(selectedDate), // Update the date field
                  });

                  // F
                  setState(() {
                    _financeDocs = widget.financeDocs;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Item updated successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update item.'),
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _financeDocs.length,
      itemBuilder: (context, index) {
        final income = _financeDocs[index];
        final title = income['title'];
        final amount = (income['amount'] as num).toDouble();
        final date = (income['date'] as Timestamp).toDate();
        final itemColor = _colors != null ? _colors![index] : Colors.blueGrey;
        final docId = income.id; // Get the document ID
        final currentType = income['type']; // Get the type of the current item

        return Dismissible(
          key: Key(docId), // Unique key for each dismissible item
          direction: DismissDirection.endToStart, // Swipe direction
          onDismissed: (direction) async {
            await _handleDelete(docId, index);
          },
          background: Container(
            color: Colors.red, // Background color when swiped
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          child: InkWell(
            onLongPress: () async {
              await _showEditDialog(context, docId, title, amount, date, currentType);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundColor: itemColor,
                  child: Text(
                    '${index + 1}', // Display number
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  DateFormat.yMMMd().format(date),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '\$${amount.toString()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: itemColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
