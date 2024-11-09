import 'package:intl/intl.dart';

class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({required this.title,required this.amount, required this.date, required this.category});

  //Conver the expese data model to a map
  Map<String, dynamic> toMap(){

    //Formats the date to me DD/MM/YYYY
    String formated_date = DateFormat ("dd-mm-yyyy").format(date);

    return {
      'title': title,
      'amount': amount,
      'date': formated_date,
      'category': category,
    };
  }
  
} 







