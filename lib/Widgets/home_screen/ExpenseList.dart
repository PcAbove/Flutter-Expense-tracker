import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/database_helper.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final VoidCallback onUpdate;

  const ExpenseList({super.key, required this.expenses, required this.onUpdate});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  String _searchQuery = '';
  DateTime? _selectedMonth;

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      selectableDayPredicate: (day) => true,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _clearMonth() {
    setState(() {
      _selectedMonth = null;
    });
  }

  List<Expense> get filteredExpenses {
    return widget.expenses.where((expense) {
      final matchesSearch = expense.expenseName.toLowerCase().contains(_searchQuery);
      final matchesMonth = _selectedMonth == null
          ? true
          : (expense.createDate.year == _selectedMonth!.year &&
              expense.createDate.month == _selectedMonth!.month);
      return matchesSearch && matchesMonth;
    }).toList();
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
                Navigator.pop(dialogContext);
                try {
                  await DatabaseHelper.instance.deleteExpense(expenseId);
                  widget.onUpdate();
                } catch (e) {
                  debugPrint("Error deleting expense: $e");
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = filteredExpenses;

    return Column(
      children: [
        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search expenses',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // DATE FILTER BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedMonth != null) ...[
              Text('Filtered Month: ${DateFormat.yMMMM().format(_selectedMonth!)}'),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearMonth,
              )
            ] else
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text("Filter by Month"),
                onPressed: () => _pickMonth(context),
              ),
          ],
        ),

        // LIST
        Expanded(
          child: ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final expense = filteredList[index];
              return Card(
                color: Colors.black54,
                elevation: 5,
                child: ListTile(
                  isThreeLine: true,
                  title: Text(expense.expenseName),
                  subtitle: Text(
                    "${expense.expensePrice.toStringAsFixed(2).replaceAll('.00', '')}\$ | "
                    "${DateFormat('MMMM-dd').format(expense.createDate)}\n"
                    "${expense.expenseCategory} ${expense.expenseType}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(context, expense.expenseId),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
