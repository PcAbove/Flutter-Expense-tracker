import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // 🔍 Needed for MediaType
import 'package:expense_tracker/Data_models/Expense_model.dart';


Future<void> exportAndSendCSV(List<Expense> expenses) async {
  List<List<dynamic>> csvData = [];

  if (expenses.isNotEmpty) {
    csvData.add(expenses.first.toMap().keys.toList()); // headers
    csvData.addAll(expenses.map((e) => e.toMap().values.toList()));
  }

  String csv = const ListToCsvConverter().convert(csvData);

  final uri = Uri.parse('http://192.168.1.6:5000/upload');

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['filename'] = 'expenses_export.csv'
      ..files.add(http.MultipartFile.fromString(
        'file',
        csv,
        filename: 'expenses_export.csv',
        contentType: MediaType('text', 'csv'),
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('✅ CSV sent successfully');
    } else {
      print('❌ Failed to send CSV: ${response.statusCode}');
    }
  } catch (e) {

  }
}
