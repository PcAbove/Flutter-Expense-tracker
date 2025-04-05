import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For formatting DateTime

const uuid =  Uuid();

class Expense {
  final String expenseId;
  final String expenseName;
  final double expensePrice;
  final DateTime createDate;
  final String expenseCategory;

  // Default constructor with automatic ID and Date assignment
   Expense({
    String? expenseId, // Now it's optional and handled manually
    required this.expenseName,
    required this.expensePrice,
    required this.expenseCategory,
    DateTime? createDate,
  })  : expenseId = expenseId ?? uuid.v4(), // Assigns ID if not passed
        createDate = createDate ?? DateTime.now(); // Assigns current date if null


  // Factory constructor to convert a map into an Expense object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map["expense_id"] as String,
      expenseCategory: map["expense_category_name"] as String,
      expenseName: map['expense_name'] as String,
      expensePrice: (map['expense_price'] as num).toDouble(),
      createDate: map['expense_created_at'] != null
        ? DateTime.parse(map['expense_created_at'] as String)  // Parse the string date correctly
        : DateTime.now(),
      );
  }

  // Convert Expense object to a map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'expense_id': expenseId,
      'expense_name': expenseName,
      'expense_price': expensePrice,
      'expense_created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createDate), // Format DateTime
      'expense_category_name': expenseCategory,
    };
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'expense_name': expenseName,
      'expense_price': expensePrice,
      'expense_created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createDate), // Format DateTime
      'expense_category_name': expenseCategory,
    };
  }
}
