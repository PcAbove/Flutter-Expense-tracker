import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AutoSuggestionDropdown(),
    );
  }
}

class AutoSuggestionDropdown extends StatefulWidget {
  @override
  _AutoSuggestionDropdownState createState() => _AutoSuggestionDropdownState();
}

class _AutoSuggestionDropdownState extends State<AutoSuggestionDropdown> {
  final TextEditingController _textController = TextEditingController();
  String? selectedCategory;

  // Initial category mappings
  final Map<String, String> categoryMap = {
    'apple': 'Fruit',
    'banana': 'Fruit',
    'carrot': 'Vegetable',
    'potato': 'Vegetable',
    'chicken': 'Meat',
  };

  final List<String> items = ['apple', 'banana', 'carrot', 'potato', 'chicken'];

  void _onItemSelected(String selectedItem) {
    setState(() {
      _textController.text = selectedItem;
      selectedCategory = categoryMap[selectedItem];
    });
  }

  void _saveNewCategory() {
    final String item = _textController.text.toLowerCase();
    if (item.isNotEmpty && selectedCategory != null) {
      setState(() {
        categoryMap[item] = selectedCategory!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated for "$item"!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auto-Suggestion with Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return items.where((item) => item
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selectedItem) {
                _onItemSelected(selectedItem);
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                _textController.text = textEditingController.text;
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Enter an item',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCategory,
              hint: Text('Select Category'),
              items: ['Fruit', 'Vegetable', 'Meat'].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){DatabaseHelper.instance.getAllCategoriesTotal();},
              child: Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }
}
