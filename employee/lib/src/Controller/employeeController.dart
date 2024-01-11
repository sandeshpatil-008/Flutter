import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sample/src/Model/employeModel.dart';

class EmployeeController {
  Future loadEmployee() async {
    try {
      var url = Uri.parse("https://reqres.in/api/users?page=1");
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
          },
         );
      if (response.statusCode == 201) {
        return EmployeeModel.fromJson(jsonDecode(response.body));
      } else {
        return EmployeeModel();
      }
    } on Exception catch (_) {
      return EmployeeModel();
    }
  }
}