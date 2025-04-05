import 'package:flutter/material.dart';
import 'package:expense_tracker/database/databasehelper.dart';

class AutoCompleteExample extends StatefulWidget {
  final ValueChanged<String> onExpenseSelected;
  // Parent's controller passed in for synchronization.
  final TextEditingController parentController; 

  const AutoCompleteExample({
    Key? key,
    required this.onExpenseSelected,
    required this.parentController,
  }) : super(key: key);

  @override
  _AutoCompleteExampleState createState() => _AutoCompleteExampleState();
}

class _AutoCompleteExampleState extends State<AutoCompleteExample> {
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future<void> _updateData() async {
    // Retrieve expense names from the database.
    final data = await DatabaseHelper.instance.getAllExpensesNames();
    setState(() {
      suggestions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        // When a suggestion is tapped, update parent's controller and trigger the callback.
        widget.parentController.text = selection;
        widget.onExpenseSelected(selection);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController controller,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        // Add a listener to update the parent's controller as the user types.
        controller.addListener(() {
          // Sync parent's controller with the autocomplete's controller.
          widget.parentController.text = controller.text;
        });

        return TextField(
          controller: controller, // Let Autocomplete use its internal controller.
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: "Enter expense name",
          ),
          onSubmitted: (value) {
            widget.onExpenseSelected(value);
          },
        );
      },
    );
  }
}
