


import 'package:expense_tracker/Widgets/home_screen/ExpenseList.dart';
import 'package:flutter/material.dart';


class ExpenseslistScreen extends StatelessWidget {

  final expense;
  final VoidCallback onUpdate;

  ExpenseslistScreen({required this.onUpdate, required this.expense,});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
      body:  Center(child: ExpenseList(expenses: expense, onUpdate: onUpdate),),
    ),
    );
  }
}