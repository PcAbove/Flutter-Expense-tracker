import 'package:expense_tracker/Widgets/ExpenseList.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Database/DatabaseHelper.dart';



class Cashflow extends StatelessWidget {
  double income = 1;
  double expense = 0;
  final VoidCallback onUpdate;

  Cashflow({required this.onUpdate, required this.income, required this.expense});

////////////////////// METHODS ///////////////////////////////////////////////////////






/////////////////// WIDGET TREE ////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final double netBalance = income - expense;
    final double total = income + expense;
    final double incomePercent = (income / total) * 100;
    final double expensePercent = (expense / total) * 100;

    return Scaffold(
      body: Column(
        children: [
           Container(
            
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 9, 13, 12), Color.fromARGB(255, 29, 31, 31)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Cashflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${netBalance.toStringAsFixed(0)}',
                  style:  TextStyle(
                    color: netBalance < 0 ? Colors.red : Colors.green,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'NET BALANCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAmountCard('\$${income.toStringAsFixed(0)}', 'GROSS INCOME', Colors.green),
              _buildAmountCard('-\$${expense.toStringAsFixed(0)}', 'EXPENSE', Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Income", style: TextStyle(fontSize: 16)),
                    Text("Expense", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: (incomePercent * 100).toInt(),
                          child: Container(
                            height: 16,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (expensePercent * 100).toInt(),
                          child: Container(
                            height: 16,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${incomePercent.toStringAsFixed(2)}%", style: const TextStyle(color: Colors.green)),
                    Text("- ${expensePercent.toStringAsFixed(2)}%", style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
  
        ],

      
      ),
    );
  }

Future<void> updateData() async {
    final data = await DatabaseHelper.instance.getAllExpenses();
    final today = await DatabaseHelper.instance.todayExpenses();
    final categoryData = await DatabaseHelper.instance.getAllCategoriesTotal();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    print(categoryData);
}

  Widget _buildAmountCard(String amount, String label, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [ const  BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
