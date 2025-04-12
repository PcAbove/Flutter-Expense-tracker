import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expense_tracker/Data_models/Expense_model.dart';


class DatabaseHelper {
  static const _databaseName = 'mainDatabase1.db';
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // That stores the database connection
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
        CREATE TABLE IF NOT EXISTS expenses (
            expense_id TEXT NOT NULL,
            expense_name TEXT NOT NULL,
            expense_price REAL NOT NULL,
            expense_created_at TEXT NOT NULL,
            expense_category_name TEXT NOT NULL,
            
        )
    """);

    await db.execute("""
        CREATE TABLE IF NOT EXISTS categories (
            category_id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_name TEXT UNIQUE NOT NULL
        )
    """);
  }

  // Insert a new expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      "expenses",
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("expenses");

    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  // Delete an expense by ID
  Future<void> deleteExpense(final id) async {
    final db = await database;
    await db.delete("expenses", where: "expense_id = ?", whereArgs: [id]);
  }

  // Delete all expenses
  Future<int> deleteAllExpenses() async {
    final db = await database;
    return await db.delete("expenses");
  }

  // Drop all tables and reset database
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS expenses");
    await db.execute("DROP TABLE IF EXISTS categories");
    await _onCreate(db, _databaseVersion); // Recreate tables
  }


  Future<List<Expense>> todayExpenses() async {
  final db = await database;
  final today = DateTime.now().toIso8601String().split('T')[0]; // Format date correctly
  
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    "SELECT * FROM expenses WHERE DATE(expense_created_at) = ?",
    [today] // Pass as a List, not a tuple
  );

  return maps.map((map) => Expense.fromMap(map)).toList();
}



  // Insert a new expense
 Future<int> insertCategory(String category) async {
  final db = await database;
  return await db.insert(
    "categories",
    {"category_name": category},  // ✅ Pass the correct data as a Map
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}



  
  //We need a function to sum all the categories. 
  Future<Map<String, double>> getAllCategoriesSpending() async {
  Map<String, double> categorySpending = {};  // Create an empty map

  final db = await database;

  // Query to get all distinct expense categories from the database
  final results = await db.rawQuery("SELECT DISTINCT expense_category_name FROM expenses");

  // Loop through the results and calculate total spending for each category
  for (final category in results) {
    String categoryName = category['expense_category_name'] as String;  // Extract category name

    // Get the sum of expense_price for the current category
    final result = await db.rawQuery(
      "SELECT SUM(expense_price) AS total FROM expenses WHERE expense_category_name = ?", 
      [categoryName]
    );

    // Store category and total spending in the map
    final double totalSpending = result[0]["total"] != null ? result[0]["total"] as double : 0.0;
    categorySpending[categoryName] = totalSpending;  // Add key-value pair to the map
  }
  //print(categorySpending);
  return categorySpending;  // Return the map with all category totals
}


  Future<Map<String, double>> getMonthlyCategoriesSpending(int month, int year) async {
  Map<String, double> categorySpending = {};  // Create an empty map

  final db = await database;

  // Query to get all distinct expense categories for the given month and year
  final results = await db.rawQuery(
    "SELECT DISTINCT expense_category_name FROM expenses "
    "WHERE strftime('%m', expense_created_at) = ? AND strftime('%Y', expense_created_at) = ?",
    [month.toString().padLeft(2, '0'), year.toString()]
  );

  // Loop through the results and calculate total spending for each category
  for (final category in results) {
    String categoryName = category['expense_category_name'] as String;  // Extract category name

    // Get the sum of expense_price for the current category in the given month and year
    final result = await db.rawQuery(
      "SELECT SUM(expense_price) AS total FROM expenses "
      "WHERE expense_category_name = ? AND strftime('%m', expense_created_at) = ? AND strftime('%Y', expense_created_at) = ?",
      [categoryName, month.toString().padLeft(2, '0'), year.toString()]
    );

    // Store category and total spending in the map
    final double totalSpending = result[0]["total"] != null ? result[0]["total"] as double : 0.0;
    categorySpending[categoryName] = totalSpending;  // Add key-value pair to the map
  }

  return categorySpending;
 // Return the map with all category totals for the month
}





// Function to get all the names in the table. 
  Future<List<String>> getAllExpensesNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT expense_name FROM expenses');
    final x = maps.map((map)=>map['expense_name'] as String).toList();
    return x;
  }

  Future<List<double>> getLastExpensePrice(String expenseName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT expense_price FROM expenses WHERE expense_name = ? ORDER BY expense_created_at DESC LIMIT 1',[expenseName]);
    final data = maps.map((map)=>map["expense_price"] as double).toList();

    return data;
  }


  Future<List<String>> getAllCategories() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query("categories");

  return maps
      .map((map) => map['category_name']?.toString() ?? '') // Ensure non-null values
      .where((category) => category.isNotEmpty) // Remove empty strings
      .toList();
}



 Future<void> deleteCategory(String name) async {
  final db = await database;
  await db.delete(
    "categories",
    where: "category_name = ?",
    whereArgs: [name],
  );
}

Future<String> getMostUsedCategory() async {
  final db = await database;
  final result = await db.rawQuery(
    """
    SELECT expense_category_name, COUNT(expense_category_name) as count 
    FROM expenses 
    GROUP BY expense_category_name 
    ORDER BY count DESC 
    LIMIT 1
    """
  );

  if (result.isNotEmpty) {
    return result.first['expense_category_name'] as String; 
  } else {
    return 'Food'; // Default fallback
  }
}



//////////////////////////// Analysis part ////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

Future<String> totalSpentThisMonth() async {
  final db = await database;
  final result = await db.rawQuery(
    """
    SELECT SUM(expense_price) as totalSpent 
    FROM expenses 
    WHERE strftime('%Y-%m', expense_created_at) = strftime('%Y-%m', 'now')
    """
  );

  if (result.isNotEmpty && result.first['totalSpent'] != null) {
    return result[0]['totalSpent'].toString(); // Convert to string
  } else {
    return '0'; // Default to 0 if no expenses found
  }
}



 Future<Map<String, dynamic>> getAllCategoriesTotal() async {
  final db = await database;

  final results = await db.rawQuery('''
    SELECT expense_category_name, 
    SUM(expense_price) AS total_amount
    FROM expenses 
    WHERE strftime('%Y-%m', expense_created_at) = strftime('%Y-%m', 'now')
    GROUP BY expense_category_name
  ''');


  // Ensure correct type casting and prevent null values
  final Map<String, dynamic> x = {
    for (var element in results)
      if (element["expense_category_name"] != null)
        (element["expense_category_name"] as String): (element["total_amount"] as num).toDouble()
  };

  return x;
}


Future<List<String>> getExpenseSuggestions(String pattern) async {
  final db = await database;
  final result = await db.query(
    'expenses',
    distinct: true,
    columns: ['expense_name'],
    where: 'expense_name LIKE ?',
    whereArgs: ['%$pattern%'],
    limit: 10,
  );
  return result.map((e) => e['expense_name'] as String).toList();
}




// Add these to your DatabaseHelper class
Future<Map<String, dynamic>?> getLastExpenseDetails(String expenseName) async {
  final db = await database;
  final result = await db.query(
    'expenses',
    where: 'expense_name = ?',
    whereArgs: [expenseName],
    orderBy: 'expense_created_at DESC',
    limit: 1,
  );
  
  return result.isNotEmpty ? result.first : null;
}


Future<double> getTotalExpenses() async {
  final db = await database;

  final results = await db.rawQuery('''
  SELECT 
    expense_category_name,
    SUM(expense_price) AS total_amount
  FROM expenses 
  WHERE strftime('%Y-%m', expense_created_at) = strftime('%Y-%m', 'now')
  GROUP BY expense_category_name
  ORDER BY total_amount DESC
''');

  final x = results.map((maps)=>maps["total_amount"] as double).toList();
  final double  total= x.fold(0,(sum,value)=>sum+value);
  
  return total;
}

}






