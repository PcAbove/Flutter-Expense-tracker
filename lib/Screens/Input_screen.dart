import 'package:flutter/material.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Widgets/AutoComplete.dart';
import 'package:expense_tracker/Widgets/CategoryDropDown.dart';
import 'package:sqflite/sqflite.dart';

class InputPage extends StatefulWidget {
  
  const InputPage({Key? key}) : super(key: key);

  @override
  InputPageState createState() => InputPageState();
}

class InputPageState extends State<InputPage> {
  final TextEditingController transactionName = TextEditingController();
  final TextEditingController transactionAmount = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'Food';
  int selectedType = 0; // 0 = Expense, 1 = Income
  bool _isLoadingDetails = false;




  @override
  void initState() {
    super.initState();
    dateController.text =
        "\${selectedDate.year}-\${selectedDate.month.toString().padLeft(2, '0')}-\${selectedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    transactionName.dispose();
    transactionAmount.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _updateSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

 Future<void> _handleTransactionSelection(String transaction) async {
  setState(() => _isLoadingDetails = true);
  
  try {
    final details = await DatabaseHelper.instance.getLastExpenseDetails(transaction);
    
    if (details != null) {
      setState(() {
        transactionName.text = transaction;
        transactionAmount.text = (details['expense_price'] as num).toString();
        selectedCategory = details['expense_category_name'] as String;
      });
    } else {
      setState(() {
        transactionName.text = transaction;
        transactionAmount.clear();
        // Keep current category selection.
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading details: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoadingDetails = false);
  }
}


  Future<void> _submitData() async {
    final enteredAmount = double.tryParse(transactionAmount.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final data = Expense(
        expenseName: transactionName.text,
        expensePrice: enteredAmount,
        createDate: selectedDate,
        expenseCategory: selectedCategory,
      );

      await DatabaseHelper.instance.insertExpense(data);
      transactionName.clear();
      transactionAmount.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: \${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
            "\${pickedDate.year}-\${pickedDate.month.toString().padLeft(2, '0')}-\${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Toggle Buttons for Expense and Income
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [selectedType == 0, selectedType == 1],
                children: const [
                  Padding(padding: EdgeInsets.all(12), child: Text('Expense')),
                  Padding(padding: EdgeInsets.all(12), child: Text('Income')),
                ],
                onPressed: (int index) {
                  setState(() {
                    selectedType = index;
                  });
                },
              ),
              const SizedBox(height: 20),
              AutoCompleteExample(
                onExpenseSelected: _handleTransactionSelection,
                parentController: transactionName,
              ),
              TextField(
                controller: transactionAmount,
                maxLength: 20,
                decoration: InputDecoration(
                  label: Text(selectedType == 0 ? "Enter expense amount" : "Enter income amount"),
                  prefixText: "\$ ",
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: [
                  Expanded(
                    child: CategoryDropdown(
                      selectedCategory: selectedCategory, // Pass the parent's current state
                      onCategoryChanged: _updateSelectedCategory,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteCategory(selectedCategory);
                    },
                    icon: const Icon(Icons.delete),
                    tooltip: "Delete Category",
                  ),
                  IconButton(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    tooltip: "Pick Date",
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        child: Text(selectedType == 0 ? "Add Expense" : "Add Income"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          
                         Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
