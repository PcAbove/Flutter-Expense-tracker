import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:justendmeplease/FireBaseDatabase.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';  // Import the package

class InsightsPage extends StatefulWidget {
  @override
  State<InsightsPage> createState() {
    return InsightsPageState();
  }
}

class InsightsPageState extends State<InsightsPage> {
  DateTime _selectedMonth = DateTime.now();  // Initially set to current month
  double _totalSpent = 0;
  double _avgDailySpent = 0;
  double _predictedMonthlySpent = 0;

  // Function to update insights when a new month is selected
  Future<void> _updateInsights(DateTime selectedMonth) async {
    final insights = await getInsights(selectedMonth);
    setState(() {
      _totalSpent = insights['totalSpent']!;
      _avgDailySpent = insights['avgDailySpent']!;
      _predictedMonthlySpent = insights['predictedMonthlySpent']!;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateInsights(_selectedMonth);  // Initialize insights with current month
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date Picker to select a custom month
            ElevatedButton(
              onPressed: () async {
                final selected = await showMonthPicker(
                  context: context,
                  initialDate: _selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selected != null) {
                  setState(() {
                    _selectedMonth = selected;
                  });
                  await _updateInsights(selected);  // Update insights based on new month
                }
              },
              child: Text("Select Month: ${DateFormat('MMMM yyyy').format(_selectedMonth)}"),
            ),
            // Display insights
            Text("Total spent in ${DateFormat('MMMM yyyy').format(_selectedMonth)}: \$${_totalSpent.toStringAsFixed(2)}"),
            Text("Average daily spending: \$${_avgDailySpent.toStringAsFixed(2)}"),
            Text("Predicted spending for the month: \$${_predictedMonthlySpent.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}

// This function will return the total spent, average daily spending, and predicted monthly spending
Future<Map<String, double>> getInsights(DateTime selectedMonth) async {
  // Get the data
  final data = await getData();

  // Extract the month and year from the selected month
  final month = selectedMonth.month;
  final year = selectedMonth.year;

  double totalSpent = 0;
  Set<String> daysWithExpenses = Set();

  // Loop through the data to calculate total spent and track distinct days
  for (var expense in data) {
    final String dateString = expense['date'];
    final double amount = expense['amount'];

    // Convert the date string to DateTime
    final expenseDate = DateFormat("yyyy-MM-dd").parse(dateString);

    // Check if the expense is from the selected month and year
    if (expenseDate.month == month && expenseDate.year == year) {
      totalSpent += amount;

      // Add the date (only the date part, without time) to the set of days
      daysWithExpenses.add(expenseDate.toIso8601String().substring(0, 10)); // 'yyyy-MM-dd'
    }
  }

  // Calculate the number of distinct days with expenses
  int distinctDays = daysWithExpenses.length;

  // Avoid division by zero (if no expenses in the month)
  double avgDailySpent = distinctDays > 0 ? totalSpent / distinctDays : 0.0;

  // Predict the monthly spending based on average daily spending
  // Get the number of days in the selected month
  final daysInMonth = DateTime(year, month + 1, 0).day;
  double predictedMonthlySpent = avgDailySpent * daysInMonth;

  // Return a map with total spent, average daily spending, and predicted monthly spending
  return {
    'totalSpent': totalSpent,
    'avgDailySpent': avgDailySpent,
    'predictedMonthlySpent': predictedMonthlySpent,
  };
}
