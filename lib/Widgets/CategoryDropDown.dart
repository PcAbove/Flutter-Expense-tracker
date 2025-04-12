import 'package:expense_tracker/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  final ValueChanged<String> onCategoryChanged;
  final String selectedCategory; // Added property for the current category

  const CategoryDropdown({
    Key? key,
    required this.onCategoryChanged,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  late String _currentCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
    _fetchCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state if the parent's selectedCategory changes
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      setState(() {
        _currentCategory = widget.selectedCategory;
      });
    }
  }

  Future<void> _fetchCategories() async {
    final data = await DatabaseHelper.instance.getAllCategories();
    setState(() {
      categories = List.from(data);
      if (!categories.contains('Add New Category')) {
        categories.add('Add New Category');
      }
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
              newCategory = value.trim();
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
                  await _fetchCategories();
                  setState(() {
                    _currentCategory = newCategory;
                  });
                  widget.onCategoryChanged(newCategory);
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
      value: _currentCategory,
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
            _currentCategory = value!;
          });
          widget.onCategoryChanged(value!);
        }
      },
    );
  }
}
