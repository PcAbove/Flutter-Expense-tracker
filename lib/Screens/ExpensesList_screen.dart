


import 'package:expense_tracker/Widgets/ExpenseList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';




class TestPageState extends StatelessWidget {

  final expense;
  final VoidCallback onUpdate;

  TestPageState({required this.onUpdate, required this.expense,});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
      body:  Center(child:Container(child: ExpenseList(expenses: expense, onUpdate: onUpdate),)),
    ),
    );
  }
}