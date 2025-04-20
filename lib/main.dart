import 'package:expense_tracker/Screens/Cashflow_screen.dart';
import 'package:expense_tracker/Screens/ExpensesList_screen.dart';
import 'package:expense_tracker/Screens/Grouped_by_categories.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:expense_tracker/Screens/Input_screen.dart';

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
  double totalIncome = 1;


  @override
  void initState() {
    super.initState();
    updateData();
    
  }

  //////////////////// Methods ////////////////////////////
  Future<void> updateData() async {
    final data = await DatabaseHelper.instance.getAllExpenses();
    //final today = await DatabaseHelper.instance.todayExpenses();
    final categoryData = await DatabaseHelper.instance.getAllCategoriesTotal();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    final income = await DatabaseHelper.instance.getTotalIncome();

    


    setState(() {
      expenses = data;
      categoriesData = categoryData;
      totalExpenses = total;
      totalIncome = income;
    });
  }



  
  //////////////////// Widget tree ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Expense tracker")),

      bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.monetization_on),
        label: 'Cashflow',
      ),
     
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

          Expanded(flex:6, child: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(100))), child: Cashflow(expense: totalExpenses, income: totalIncome, onUpdate: updateData,),),),
          Expanded(
            flex: 4,
            child: Card(
              
              //color: Colors.red,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
                top: Radius.circular(24)
              )),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                
                    children: [
                      const Text("Top expense categories"),

                      TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>TestPageState(expense: expenses,onUpdate: updateData,)));}, child: const Text("View all expenses"))



                    ],
                  ),
                  ),

                  Expanded(child:GroupedCategories(categoryTotals: categoriesData, onUpdate: updateData,)),

                ],
              )
            ),
          ),
          //Expanded(flex: 1,child: Container(color: Colors.red)),
          

       

         
        ],
      ),
    );
  }
}

