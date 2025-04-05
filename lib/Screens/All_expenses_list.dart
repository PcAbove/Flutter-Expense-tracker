import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:intl/intl.dart';




class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onUpdate;

  const ExpenseList({super.key, required this.expenses, required this.onUpdate });//required this.onUpdate});

  ////////////////////  methods  ////////////////////////////
  void deleteExpense(expenseId) async {
    await expenseId;
    DatabaseHelper.instance.deleteExpense(expenseId); 
    print("$expenseId has been deleted successfully, the database now ${DatabaseHelper.instance.getAllExpenses()}");
    
  }


  //////////////////// Widget tree ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.all(1.0),
          child: Card(color:Colors.black12,elevation: 5, child:ListTile(
            isThreeLine: true,
            //leading: const Icon(Icons.money),
            title: Text(expense.expenseName),
            subtitle:  Text(
              "${expense.expensePrice.toStringAsFixed(2).replaceAll('.00', '')}\$ | ${DateFormat('MMMM-dd').format(expense.createDate)}\n${expense.expenseCategory}"
            ),
            trailing:  IconButton(onPressed: ()async{ try { deleteExpense(expense.expenseId);} catch (e){print(e);} finally{onUpdate();}}, icon: const Icon(Icons.delete)),
          )
        ));
      },
    );
  }
}


