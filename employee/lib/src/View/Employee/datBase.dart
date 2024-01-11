import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sample/src/Model/employeModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DataBaseFile with ChangeNotifier {
  EmployeeModel employeeModel = EmployeeModel();
  late Database database;

  init() {
    initDatabase();
    fetchData();
  }

  final _employeeStreamController = StreamController<List<Data>>.broadcast();
  Stream<List<Data>> get employeeStreamController =>
      _employeeStreamController.stream;

  Future<void> resetDatabase() async {
    await database.delete('employees');
  }

// init dataBase
  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'employee_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE employees(id INTEGER PRIMARY KEY, email TEXT, firstName TEXT , lastName TEXT , avatar TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> fetchData() async {
    var url = Uri.parse("https://reqres.in/api/users?page=1");
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      employeeModel = EmployeeModel.fromJson(jsonDecode(response.body));
      final List<Data> data = employeeModel.data!;
      for (var employeeData in data) {
        final data = {
          "id": employeeData.id,
          "email": employeeData.email,
          "firstName": employeeData.firstName,
          "lastName": employeeData.lastName,
          "avatar": employeeData.avatar,
        };
        await database.insert(
          'employees',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      refreshData();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future refreshData() async {
    final List<Map<String, dynamic>> queryResult =
        await database.query('employees');
    employeeModel.data = queryResult.map((e) => Data.fromJsonTo(e)).toList();
    if (employeeModel.data != null) {
      _employeeStreamController.sink.add(employeeModel.data!);
    }
    return employeeModel.data;
  }

  Future<void> deleteEmployee(int employeeId) async {
    await database.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    _employeeStreamController.sink.add(employeeModel.data!);
  }

  Future<void> updateEmployee(int employeeId) async {
    await database.update(
      'employees',
      {
        "email": "test@gmail.com",
        "firstName": "Test",
        "lastName": "Testing",
      },
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    _employeeStreamController.sink.add(employeeModel.data!);
  }
}
