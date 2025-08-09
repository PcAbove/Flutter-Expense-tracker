import 'package:expense_tracker/Data_models/Expense_model.dart';
import 'package:expense_tracker/Database/database_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


Future<void> exportAndSendExpenses() async {
  final List<Expense> expenses = await DatabaseHelper.instance.getAllExpenses();

  // Convert to List<Map<String, dynamic>> (JSON-like)
  final List<Map<String, dynamic>> exportList = expenses.map((e) => e.toJson()).toList();

  final url = Uri.parse("http://192.168.1.6:5000/export"); // replace with your IP

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(exportList),
  );

  if (response.statusCode == 200) {
    print("✅ Data sent successfully: ${response.body}");
  } else {
    print("❌ Failed to send: ${response.statusCode} - ${response.body}");
  }
}


Future<void> syncExpensesFromServer() async {
  final url = Uri.parse("http://192.168.1.10:5000/sync");

  // 2. Fetch new data
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    for (var item in data) {
      final expense = Expense.fromJson(item);
      await DatabaseHelper.instance.insertExpense(expense);
    }

    print("✅ Sync complete!");
  } else {
    print("❌ Sync failed: ${response.statusCode} - ${response.body}");
  }
}
