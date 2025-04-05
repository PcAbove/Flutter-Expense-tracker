
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';



void main(){ 
  runApp(
    MaterialApp(
      home: Homepage()
    )
    );
}

class Homepage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
  
}


class _HomePageState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  Column(
        children: [
          Expanded(child: ExpenseDashboard()),

        ],
      ),
    ); 
  }

}


class ExpenseDashboard extends StatefulWidget {

  final  income = 100;
  final expense = 100;


  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();

}

class _ExpenseDashboardState extends State<ExpenseDashboard> {

  
 


  @override
  void initState(){
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() async {
     //widget.expense = DatabaseHelper.instance.getLastExpensePrice("Nigga");
    });
  } 


  @override
  Widget build(BuildContext context) {
    print("${widget.expense} ${widget.income}");
    double progress = (widget.expense / (widget.income + widget.expense));
    
    return Center(child:Stack(
            alignment: Alignment.center, // Centers the content
            children: [
              // Circular Progress Indicator
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 10,
                ),
              ),

    // Centered Content (Icon + Text)
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 28, color: Colors.green),
        SizedBox(height: 5),
        Text("Expense Total in July", style: TextStyle(color: Colors.grey, fontSize: 14)),
        Text("\$${widget.expense}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    ),
  ],
    ));

  }}