import 'package:expense_tracker/Database/database_helper.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  final ValueChanged<String> onCategoryChanged;
  final String selectedCategory;

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
  List<String> _dbCategories = [];

  bool isHidden = false; // 🔹 Hide/reveal toggle

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
    _fetchCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      if (_dbCategories.contains(widget.selectedCategory)) {
        setState(() {
          _currentCategory = widget.selectedCategory;
        });
      } else if (_dbCategories.isNotEmpty) {
        setState(() {
          _currentCategory = _dbCategories.first;
        });
        widget.onCategoryChanged(_currentCategory);
      }
    }
  }

  Future<void> _fetchCategories() async {
    _dbCategories = await DatabaseHelper.instance.getAllCategories();
    if (_dbCategories.isEmpty) {
      await DatabaseHelper.instance.insertCategory('General');
      _dbCategories = await DatabaseHelper.instance.getAllCategories();
    }
    setState(() {
      categories = List.from(_dbCategories);
      if (!categories.contains('Add New Category')) {
        categories.add('Add New Category');
      }
      if (!_dbCategories.contains(_currentCategory)) {
        _currentCategory = _dbCategories.first;
        widget.onCategoryChanged(_currentCategory);
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
            onChanged: (value) => newCategory = value.trim(),
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
                if (newCategory.isNotEmpty && !_dbCategories.contains(newCategory)) {
                  await DatabaseHelper.instance.insertCategory(newCategory);
                  await _fetchCategories();
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
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _currentCategory,
            decoration: InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  isHidden && category != 'Add New Category'
                      ? '***'
                      : category,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == 'Add New Category') {
                _showAddCategoryDialog();
              } else if (value != null && _dbCategories.contains(value)) {
                setState(() => _currentCategory = value);
                widget.onCategoryChanged(value);
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[700],
          ),
          onPressed: () {
            setState(() {
              isHidden = !isHidden;
            });
          },
        )
      ],
    );
  }
}
