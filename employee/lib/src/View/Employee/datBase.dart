import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:sample/src/Model/employeModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DataBaseFile with ChangeNotifier {
  EmployeeModel employeeModel = EmployeeModel();
  Data data = Data();
  late Database database;
  int index = 0;

  init() {
    initDatabase();
    fetchData();
  }

  final _employeeStreamController = StreamController<List<Data>>.broadcast();
  Stream<List<Data>> get employeeStreamController =>
      _employeeStreamController.stream;

  final _loadingStreamController = StreamController<bool>.broadcast();
  Stream<bool> get loadingStreamController => _loadingStreamController.stream;

  Future<void> resetDatabase() async {
    await database.delete('employees');
  }

  loading(bool value) {
    _loadingStreamController.sink.add(value);
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

// delete employee
  Future<void> deleteEmployee(int employeeId, String title) async {
    await database.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    Fluttertoast.showToast(
        msg: title + " Successfully Deleted", backgroundColor: Colors.green);
    _employeeStreamController.sink.add(employeeModel.data!);
  }

// upadte employee
  Future<void> updateEmployee(int employeeId, String title) async {
    // log(data.toJson().toString());
    await database.update(
      'employees',
      {
        "email": data.email,
        "firstName": data.firstName,
        "lastName": data.lastName,
        "avatar": data.avatar,
      },
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    final List<Map<String, dynamic>> updatedDataFromDb = await database.query(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    if (updatedDataFromDb.isNotEmpty) {
      final Data updatedEmployee = Data.fromJsonTo(updatedDataFromDb.first);
      final int index =
          employeeModel.data!.indexWhere((e) => e.id == employeeId);
      if (index != -1) {
        employeeModel.data![index] = updatedEmployee;
        _employeeStreamController.sink.add(employeeModel.data!);
        Fluttertoast.showToast(
            msg: title + " Successfully Edited", backgroundColor: Colors.green);
      }
    }
  }
}
