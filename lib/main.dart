import 'package:expense_tracker/Screens/Grouped_by_categories.dart';
import 'package:expense_tracker/testing.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:expense_tracker/Screens/Input_screen.dart';
import 'package:expense_tracker/Screens/All_expenses_list.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Expense> expenses = [];
  Map<String,dynamic> categoriesData = {};
  double totalExpenses = 0;


  @override
  void initState() {
    super.initState();
    updateData();
    
  }

  //////////////////// Methods ////////////////////////////
  Future<void> updateData() async {
    final data = await DatabaseHelper.instance.getAllExpenses();
    final today = await DatabaseHelper.instance.todayExpenses();
    final categoryData = await DatabaseHelper.instance.getAllCategoriesTotal();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    print(categoryData);


    setState(() {
      expenses = data;
      categoriesData = categoryData;
      totalExpenses = total;
    });
  }



  
  //////////////////// Widget tree ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense tracker")),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const InputPage()),
          );
          if (shouldRefresh == true) {
            await updateData(); // Directly update data
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child:  Card(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
              child: Center(
                child: Text("Total expenses this month \n${totalExpenses}\$", textAlign: TextAlign.center,style: Theme.of(context).textTheme.titleMedium,),
              ),
            ),
          )
          ),
          Expanded(
            flex: 4,
            child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child:GroupedCategories(categoryTotals: categoriesData, onUpdate: updateData,)
            ),
          ),

          
          const SizedBox(height: 5),
          Expanded(
            flex: 5,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ExpenseList(expenses: expenses, onUpdate: updateData),
            ),
          ),

         
        ],
      ),
    );
  }
}

