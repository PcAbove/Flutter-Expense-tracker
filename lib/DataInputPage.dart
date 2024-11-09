import 'package:flutter/material.dart';
import 'package:justendmeplease/FireBaseDatabase.dart';

class InputPage extends StatefulWidget {
  final Function refreshData;

  InputPage({required this.refreshData});

  @override
  InputPageState createState() => InputPageState();
}

class InputPageState extends State<InputPage> {
  final titledata = TextEditingController();
  final amountdata = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial date to today's date
    final today = DateTime.now();
    dateController.text = "${today.toLocal()}".split(' ')[0]; // Format date as "yyyy-mm-dd"
  }

  @override
  void dispose() {
    titledata.dispose();
    amountdata.dispose();
    dateController.dispose();
    super.dispose();
  }

  // Submit data to Firebase and refresh the data
  void _submitData() async {
    final enteredTitle = titledata.text;
    final enteredAmount = amountdata.text;
    final enteredDate = dateController.text;

    if (enteredTitle.isEmpty || enteredAmount.isEmpty || enteredDate.isEmpty) {
      return;
    }

    // Insert new data to Firebase
    await insertData(enteredTitle, double.parse(enteredAmount), enteredDate);

    // Refresh data to reflect the new entry
    await widget.refreshData();

    // Clear inputs and go back to previous page
    titledata.clear();
    amountdata.clear();
    dateController.clear();
    Navigator.pop(context);
  }

  // Function to show date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format the date as "yyyy-mm-dd"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: titledata,
                maxLength: 50,
                decoration: const InputDecoration(label: Text("Title")),
              ),
              TextField(
                controller: amountdata,
                maxLength: 20,
                decoration: const InputDecoration(label: Text("Enter price"), prefixText: "\$ "),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              // Date Input with button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(label: Text("Select Date")),
                      readOnly: true, // Disable typing, only allow selection via the button
                    ),
                  ),
                  IconButton(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    tooltip: "Pick Date",
                  ),
                ],
              ),
              // Buttons at the bottom with padding
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        child: const Text("Submit"),
                      ),
                    ),
                    const SizedBox(width: 10), // Add space between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
