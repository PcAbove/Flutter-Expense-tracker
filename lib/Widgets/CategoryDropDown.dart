import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  final ValueChanged<String> onCategoryChanged;

  const CategoryDropdown({Key? key, required this.onCategoryChanged}) : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String selectedCategory = 'Food';
  List<String> categories = [];

  @override
  void initState() {
    
    super.initState();
    _fetchCategories();
  }

 Future<void> _fetchCategories() async {
  final data = await DatabaseHelper.instance.getAllCategories();
  final mostUsedCategory = await DatabaseHelper.instance.getMostUsedCategory(); // Get the most used

  setState(() {
    categories = List.from(data);
    if (!categories.contains('Add New Category')) {
      categories.add('Add New Category');
    }

    // Use the most used category as default, else fallback to 'Food'
    selectedCategory = categories.contains(mostUsedCategory) ? mostUsedCategory : 'Food';
  });
}


  void _showAddCategoryDialog() {
    String newCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              newCategory = value.trim(); // Save input value properly
            },
            decoration: const InputDecoration(
              hintText: 'Enter new category',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  await DatabaseHelper.instance.insertCategory(newCategory);
                  await _fetchCategories(); // Refresh the list after insertion
                  setState(() {
                    selectedCategory = newCategory;
                    widget.onCategoryChanged(newCategory);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value == 'Add New Category') {
          _showAddCategoryDialog();
        } else {
          setState(() {
            selectedCategory = value!;
            widget.onCategoryChanged(selectedCategory);
          });
        }
      },
    );
  }
}
