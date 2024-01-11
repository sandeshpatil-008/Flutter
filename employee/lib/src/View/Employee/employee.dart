// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:sample/src/Model/employeModel.dart';
import 'package:sample/src/View/Employee/datBase.dart';

class Employee extends StatefulWidget {
  final DataBaseFile dataBaseFile;
  final List<Data> data;
  final Function() callBack;
  const Employee(
      {Key? key,
      required this.dataBaseFile,
      required this.data,
      required this.callBack})
      : super(key: key);

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  late TabController tabController;

  @override
  void initState() {
    tabController =
        TabController(length: widget.data.length, vsync: Navigator.of(context));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelStyle:
                        Theme.of(context).textTheme.titleSmall,
                    labelStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w700),
                    tabs: List.generate(
                        widget.dataBaseFile.employeeModel.data!.length,
                        (index) {
                      return Tab(
                          text: widget.dataBaseFile.employeeModel.data![index]
                                  .firstName! +
                              " " +
                              widget.dataBaseFile.employeeModel.data![index]
                                  .lastName!);
                    })),
              ),
              Expanded(
                child: Column(
                  children: [
                    widget.dataBaseFile.employeeModel.data!.isNotEmpty
                        ? Expanded(
                            child: TabBarView(
                                controller: tabController,
                                children: List.generate(
                                    widget.dataBaseFile.employeeModel.data!
                                        .length, (index) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                   widget.dataBaseFile
                                                      .updateEmployee(widget
                                                          .data[index].id!);
                                                  widget.callBack();
                                                },
                                                child: const Text('Edit'),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  YYDialog.init(context);
                                                  YYdeleteDialog(
                                                      widget.data[index].id!);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            height: 200,
                                            width: 200,
                                            padding: const EdgeInsets.all(10),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    widget.data[index].avatar!,
                                                cacheKey:
                                                    widget.data[index].avatar!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            widget.data[index].firstName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                          Text(
                                            widget.data[index].lastName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                          Text(
                                            widget.data[index].email!,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ],
                                      ));
                                })),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          );
        });
  }

  YYDialog YYdeleteDialog(int id) {
    return YYDialog().build()
      ..barrierColor = Colors.black.withOpacity(0.6)
      ..gravity = Gravity.center
      ..width = 300
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 15.0, right: 15, bottom: 50, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm Delete !!!",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Are You Sure You Want To Delete",
                style: Theme.of(context).textTheme.titleMedium!,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () async {
                  widget.dataBaseFile.deleteEmployee(id);
                  Navigator.pop(context);
                },
                child: const Text("Ok"))
          ],
        )
      ]))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..show();
  }
}
