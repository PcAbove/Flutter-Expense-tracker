import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:intl/intl.dart';


class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onUpdate;

  const ExpenseList({super.key, required this.expenses, required this.onUpdate});

  ////////////////////  methods  ////////////////////////////
  Future<void> deleteExpense(String expenseId) async { // Add proper type
    await DatabaseHelper.instance.deleteExpense(expenseId);
    print("$expenseId deleted");
    onUpdate(); // Move refresh here after deletion
  }

   void _showDeleteConfirmation(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(dialogContext);
                
                try {
                  await DatabaseHelper.instance.deleteExpense(expenseId);
                  onUpdate(); // Refresh the list
                } catch (e) {
                  print("Error deleting expense: $e");
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

    @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          //margin: const EdgeInsets.all(1.0),
          child: Card(
            color: Colors.black54,
            elevation: 5,
            child: ListTile(
              isThreeLine: true,
              title: Text(expense.expenseName),
              subtitle: Text(
                "${expense.expensePrice.toStringAsFixed(2).replaceAll('.00', '')}\$ | "
                "${DateFormat('MMMM-dd').format(expense.createDate)}\n"
                "${expense.expenseCategory}"
                "${expense.expenseType}"
              ),
              trailing: IconButton(
                onPressed: () => _showDeleteConfirmation(context, expense.expenseId),
                icon: const Icon(Icons.delete),
              ),
            ),
          ),
        );
      },
    );
  }
}