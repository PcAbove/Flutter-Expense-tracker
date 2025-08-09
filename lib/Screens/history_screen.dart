import 'package:expense_tracker/Database/Get_data.dart';
import 'package:expense_tracker/Widgets/home_screen/cash_flow.dart';
import 'package:expense_tracker/Screens/expenses_list.dart';
import 'package:expense_tracker/Screens/grouped_by_categories.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/database_helper.dart';
import 'package:expense_tracker/Screens/Input_screen.dart';


class HistoryScreen extends StatefulWidget {
  HistoryScreenState createState() => HistoryScreenState(); 

}

class HistoryScreenState extends State<HistoryScreen>{
  List<Expense> expenses = [];
  Map<String,dynamic> categoriesData = {};
  double totalExpenses = 0;
  double totalIncome = 1;


  @override
  void initState() {
    super.initState();
    updateData();
    
  }
void showMyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Are you sure you want to restore backup?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
            },
          ),
          ElevatedButton(
            child: const Text("Yes"),
            onPressed: () async {
              try {
                // Close the confirmation dialog first
                Navigator.of(dialogContext).pop();

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text("Restoring backup..."),
                      ],
                    ),
                  ),
                );

                // Perform sync
                await syncExpensesFromServer();
                updateData();

                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                // Show snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Backup restored successfully!"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                print("Restore error: $e");

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close any open dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Failed to restore backup."),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}



  Future<void> updateData() async {
    //Expense x = Expense(expenseName: "expenseName", expenseType: 0, expensePrice: 1, expenseCategory: "cv");
    
    final data = await DatabaseHelper.instance.getAllExpenses();
    final categoryData = await DatabaseHelper.instance.getAllCategoriesTotal();
    final total = await DatabaseHelper.instance.getAllTotalExpenses();
    final income = await DatabaseHelper.instance.getAllTotalIncome();

    


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
      appBar: AppBar(
        title: const Text("Expense tracker"),
        actions: [
          Row(
            children: [
              IconButton(onPressed:()async{await exportAndSendExpenses();}, icon: const Icon(Icons.cloud)),
              IconButton(onPressed:()async{showMyDialog(context);}, icon: const Icon(Icons.save_alt))
            ],
          )
        ],
      ),

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
            flex: 3,
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
                      TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpenseslistScreen(expense: expenses,onUpdate: updateData,)));}, child: const Text("View all expenses"))

                    ],
                  ),
                  ),

                  Expanded(flex:1,child:GroupedCategories(categoryTotals: categoriesData, onUpdate: updateData,)),

                ],
              )
            ),
          ),
          

       

         
        ],
      ),
    );
  }
}

