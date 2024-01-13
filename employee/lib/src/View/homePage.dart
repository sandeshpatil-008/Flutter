import 'package:flutter/material.dart';
import 'package:sample/src/Controller/employeeController.dart';
import 'package:sample/src/Model/employeModel.dart';
import 'package:sample/src/View/Employee/datBase.dart';
import 'package:sample/src/View/Employee/employee.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EmployeeController employeeController = EmployeeController();
  EmployeeModel employeeModel = EmployeeModel();
  bool isloading = false;
  int _currentIndex = 0;
  DataBaseFile dataBaseFile = DataBaseFile();

  @override
  void initState() {
    isloading = false;
    dataBaseFile.init();
    super.initState();
  }

  callBack() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () async {
                isloading = true;
                setState(() {});
                await Future.delayed(const Duration(seconds: 2));
                dataBaseFile.refreshData();
                isloading = false;
                setState(() {});
              },
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
        title: Text(heading(_currentIndex)),
      ),
      body: pages(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              dataBaseFile.loading(true);
              dataBaseFile.refreshData();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  pages(int index) {
    switch (index) {
      case 0:
        return StreamBuilder<List<Data>>(
            stream: dataBaseFile.employeeStreamController,
            builder: (context, snap) {
              if (snap.hasData) {
                return isloading == true
                    ? const Center(child: CircularProgressIndicator())
                    : Employee(
                        dataBaseFile: dataBaseFile,
                        data: snap.data!,
                        callBack: callBack,
                      );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            });
      case 1:
        break;
      case 2:
        break;
      default:
    }
    setState(() {});
  }

  heading(int index) {
    switch (index) {
      case 0:
        return "Home Page";

      case 1:
        return "Search";
      case 2:
        return "Profile";
      default:
    }
    setState(() {});
  }
}
