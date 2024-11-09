import 'package:flutter/material.dart';
import 'package:justendmeplease/DataInputPage.dart';
import 'package:justendmeplease/FireBaseDatabase.dart';
import 'package:justendmeplease/Analysis.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Expense Tracker',
    theme: ThemeData.dark(),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpenses(); // Fetch initial expenses data
  }

  // Function to get data and update the state
  void fetchExpenses() async {
    final fetchData = await getData(); // Fetch data from Firebase
    setState(() {
      _expenses = fetchData; // Update the list with new data
    });
  }

  // Update data after removal
  Future<void> removeData() async {
    final fetchData = await getData(); // Fetch data from Firebase
    setState(() {
      _expenses = fetchData; // Update the list with new data
    });
  }

  // The widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Place FAB in center

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputPage(refreshData: fetchExpenses),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),

      // App bar
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Center(child: Text('Expenses')),
      ),

      // Bottom Navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_sharp), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.insights_sharp), label: "Insights"),
        ],
      ),

      // Body
      body: Column(
        children: [
          // Padding around the chart placeholder
          Padding(
            padding: const EdgeInsets.only(bottom: 7.5, left: 15, right: 15, top: 15), // Consistent padding
            child: Container(
              color: Colors.black45,
              width: double.infinity,
              height: 300,
              child: Center(
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsightsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.insights))),
            ),
          ),

          // Text Widget for "Today's Expenses" with updated position and styling
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10, right: 15), // Positioned to the top left
            child: Container(
              width: double.infinity,
              color: Colors.black54, // Same background color as the ListView
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Center(child:Text(
                "Today's Expenses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Slightly smaller font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ),

          // Expanded section for the ListView with background color
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 15, left: 15, right: 15, top: 0), // Same padding as the chart
              child: Container(
                color: Colors.black45, // Background color for the ListView area
                child: ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onLongPress: () {
                        // Implement long press action if needed
                      },
                      leading: const Icon(
                        Icons.attach_money_outlined,
                        size: 30,
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          var id = _expenses[index]["id"];
                          await deleteData(id); // Calls deleteData from FireBaseDatabase.dart
                          await removeData();
                        },
                        icon: Icon(
                          size: 30,
                          Icons.delete_forever_rounded,
                          color: Colors.red[300],
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(_expenses[index]['title'])],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${_expenses[index]['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                          Text(_expenses[index]['date']),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[350],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
