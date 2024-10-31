import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          Container(
            height: 300, // Placeholder height for bar chart
            color: Colors.blue[100],
            child: Center(
              child: Text(
                'Bar Chart Placeholder',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: RecentExpenses(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Action for home button
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Action for settings button
              },
            ),
            SizedBox(width: 48), // Space for the "+" button
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Action for add button
                // You can add functionality to navigate to a new page or show a dialog to add expenses
                print('Add Expense');
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Action for list button
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RecentExpenses extends StatelessWidget {
  // Sample list of expense data
  final List<Map<String, String>> expenses = [
    {"title": "Dining Out", "subtitle": "Food and Beverages", "date": "March 7"},
    {"title": "Groceries", "subtitle": "Household Supplies", "date": "March 5"},
    {"title": "Electricity Bill", "subtitle": "Utilities", "date": "March 3"},
    {"title": "Dining Out", "subtitle": "Food and Beverages", "date": "March 7"},
    {"title": "Groceries", "subtitle": "Household Supplies", "date": "March 5"},
    {"title": "Electricity Bill", "subtitle": "Utilities", "date": "March 3"},
    {"title": "Dining Out", "subtitle": "Food and Beverages", "date": "March 7"},
    {"title": "Groceries", "subtitle": "Household Supplies", "date": "March 5"},
    {"title": "Electricity Bill", "subtitle": "Utilities", "date": "March 3"},
    {"title": "Dining Out", "subtitle": "Food and Beverages", "date": "March 7"},
    {"title": "Groceries", "subtitle": "Household Supplies", "date": "March 5"},
    {"title": "Electricity Bill", "subtitle": "Utilities", "date": "March 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 24,
                          child: Icon(
                            Icons.receipt, // Generic icon for expenses
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense["title"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                expense["subtitle"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Expense:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              expense["date"]!,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
