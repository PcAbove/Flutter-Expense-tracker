import 'package:flutter/material.dart';

class GroupedCategories extends StatelessWidget {
  final Map<String, dynamic> categoryTotals;
  final VoidCallback onUpdate;

  const GroupedCategories({
    super.key, 
    required this.categoryTotals,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Convert to list and sort by amount (descending)
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryName = category.key;
        final totalAmount = category.value as double;

        return Card(
          color: Colors.black26,
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.green[800]),
              ),
            ),
            title: Text(
              categoryName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //color: const Color.fromARGB(255, 1, 14, 1),
              ),
            ),
            subtitle: Text(
              '${_getPercentage(categoryTotals.values, totalAmount)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  // Helper method to calculate and format percentage
String _getPercentage(Iterable<dynamic> allValues, double currentValue) {
  final total = allValues.fold<double>(0, (sum, value) => sum + (value as double));
  final percentage = total > 0 ? (currentValue / total * 100) : 0;
  return percentage.toStringAsFixed(2); // Formats to 2 decimal places
}
}