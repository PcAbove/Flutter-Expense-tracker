import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


//URL expense table
final url = Uri.https(
  "expensetrackerapp-a6ad4-default-rtdb.europe-west1.firebasedatabase.app",
  "expense_list.json",
);

//URL category table
final urlCategory =  Uri.https(
     "expensetrackerapp-a6ad4-default-rtdb.europe-west1.firebasedatabase.app",
    'Category_list.json');

// Insert data into Firebase

// Insert data into Firebase
Future<void> insertData(String title, double amount, String date) async {
  // If no date is provided, use the current date (fall-back behavior)
  String formatedDate = date.isEmpty ? DateFormat("MM-dd-yyyy").format(DateTime.now()) : date;

  try {
    await http.post(
      url, // The path and the connection to the database
      headers: {'Content-Type': 'application/json'}, // This helps the Firebase API
      body: json.encode({
        'title': title,
        'amount': amount,
        'date': formatedDate,
        'category': "category",
        'steve': 'FUCK YOU', // Replace with the appropriate data field
      }),
    );
  } catch (error) {
    print("$error"); // Print the error if something goes wrong
  }
}


// Get data from the database
Future<List<Map<String, dynamic>>> getData() async {
  try {
    final response = await http.get(url);

    // Decode the JSON data from response.body
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Convert the Map data to a List of Maps for easier handling in Flutter
    List<Map<String, dynamic>> filteredData = data.entries.map((entry) {
      return {
        'id': entry.key, // Each Firebase item has a unique key
        ...entry.value as Map<String, dynamic>,
        // Cast entry.value to Map<String, dynamic>
      };
    }).toList();

    return filteredData; // Return the list of expenses
  } catch (error) {
    print("Error fetching data: $error");
    return []; // Return an empty list if there's an error
  }
}

  
//Function to delete, the selected nod. 
Future <void> deleteData(itemId) async{

  //connect to the path of the nod which will be deleted
  final deleteUrl = Uri.https(
  "expensetrackerapp-a6ad4-default-rtdb.europe-west1.firebasedatabase.app",
  "expense_list/$itemId.json"
  );

 try {
    // Send a DELETE request to Firebase
    final response = await http.delete(deleteUrl);

    if (response.statusCode == 200) {
      print("Data deleted successfully.");
    } else {
      print("Failed to delete data: ${response.statusCode}");
    }
  } catch (error) {
    print("Error deleting data: $error");
  }

}


//Update the database

Future<void> updateData(String title, double amount, itemId) async {
  final updateUrl = Uri.https(
  "expensetrackerapp-a6ad4-default-rtdb.europe-west1.firebasedatabase.app",
  "expense_list/$itemId.json");

  try {
    await http.put(
      updateUrl, // The path and the connection to the database
      headers: {'Content-Type': 'application/json'}, // This helps the Firebase API
      body: json.encode({
        'title': title,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'category': 'Sample Category',
        'steve': 'FUCK YOU',
      }),
    );
  } catch (error) {
    print("$error"); // Print the error if something goes wrong
  }
}


//Adding into the categories table 
Future <void> insertCategory (Category) async {
  

  await http.post(
    urlCategory,
    headers: {'Content-Type' : 'application/json'},
    body: json.encode({
      'Category' : Category
      }),
  );
    
  

} 



//Geting the data from category table 
Future<List<Map<String, dynamic>>> getCategory () async {

  //Change data from json to list
  try {
    final response = await http.get(urlCategory);

    //Decode the data and convert it to map
    final Map <String,dynamic> data = jsonDecode(response.body);

    //convert the map to list
    List <Map<String, dynamic>> finalData = data.entries.map((entry){
      return {
        'id': entry.key,
        ...entry.value as Map<String, dynamic>
      };
    }).toList(); 
    return finalData;

  }  catch(error) {
    print ("error: $error");
    return [];
  }
  
}



