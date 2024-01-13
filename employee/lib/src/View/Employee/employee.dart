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
  int _currentIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    tabController = TabController(
        length: widget.data.length,
        vsync: Navigator.of(context),
        initialIndex: 0);
    super.initState();
  }

  void _onDelete(int id, String name) {
    widget.dataBaseFile.deleteEmployee(id, name);

    tabController = TabController(
      length: widget.dataBaseFile.employeeModel.data!.length,
      vsync: Navigator.of(context),
      initialIndex: _currentIndex,
    );

    if (_currentIndex >= widget.dataBaseFile.employeeModel.data!.length) {
      _currentIndex = widget.dataBaseFile.employeeModel.data!.length - 1;
    }
    widget.callBack();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
              labelStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w700),
              tabs: List.generate(
                  widget.dataBaseFile.employeeModel.data!.length, (index) {
                return Tab(
                    text: widget.dataBaseFile.employeeModel.data![index]
                            .firstName! +
                        " " +
                        widget
                            .dataBaseFile.employeeModel.data![index].lastName!);
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
                              widget.dataBaseFile.employeeModel.data!.length,
                              (index) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            YYDialog.init(context);
                                            YYEditDialog(
                                                widget.data[index].id!,
                                                widget.data[index].firstName! +
                                                    " " +
                                                    widget
                                                        .data[index].lastName!);
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
                                                widget.data[index].id!,
                                                widget.data[index].firstName! +
                                                    " " +
                                                    widget
                                                        .data[index].lastName!);
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
                                          imageUrl: widget.data[index].avatar!,
                                          cacheKey: widget.data[index].avatar!,
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
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      widget.data[index].lastName!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      widget.data[index].email!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
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
  }

  YYDialog YYdeleteDialog(int id, String name) {
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
                  // widget.dataBaseFile.deleteEmployee(id);
                  _onDelete(id, name);
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

  // edit form
  YYDialog YYEditDialog(int id, String name) {
    return YYDialog().build()
      ..barrierColor = Colors.black.withOpacity(0.6)
      ..gravity = Gravity.center
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(StatefulBuilder(builder: (context, statSetter) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Edit $name Details",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15, bottom: 50, top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        onChanged: (value) {
                          widget.dataBaseFile.data.avatar =
                              value.replaceAll(' ', '');
                          statSetter(() {});
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Profile Url";
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.only(left: 0),
                            labelText: "Profile Url",
                            labelStyle: Theme.of(context).textTheme.titleMedium,
                            floatingLabelStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                highlightColor:
                                    Theme.of(context).primaryColorLight,
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                icon: const Icon(
                                  Icons.image,
                                )))),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        onChanged: (value) {
                          widget.dataBaseFile.data.firstName =
                              value.replaceAll(' ', '');
                          statSetter(() {});
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter First Name";
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.only(left: 0),
                            labelText: "First Name",
                            labelStyle: Theme.of(context).textTheme.titleMedium,
                            floatingLabelStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                highlightColor:
                                    Theme.of(context).primaryColorLight,
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                icon: const Icon(
                                  Icons.person,
                                )))),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        onChanged: (value) {
                          widget.dataBaseFile.data.lastName =
                              value.replaceAll(' ', '');
                          statSetter(() {});
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Last Name";
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.only(left: 0),
                            labelText: "Last Name",
                            labelStyle: Theme.of(context).textTheme.titleMedium,
                            floatingLabelStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                highlightColor:
                                    Theme.of(context).primaryColorLight,
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                icon: const Icon(
                                  Icons.person,
                                )))),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        onChanged: (value) {
                          widget.dataBaseFile.data.email =
                              value.replaceAll(' ', '');
                          statSetter(() {});
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Email";
                          }
                          final emailRegex = RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,})$');

                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.only(left: 0),
                            labelText: "Email",
                            labelStyle: Theme.of(context).textTheme.titleMedium,
                            floatingLabelStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                highlightColor:
                                    Theme.of(context).primaryColorLight,
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                icon: const Icon(
                                  Icons.email,
                                )))),
                    const SizedBox(
                      height: 10,
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
                        if (_formKey.currentState!.validate()) {
                          widget.dataBaseFile.updateEmployee(id, name);
                          widget.callBack();
                          Navigator.pop(context);
                        } else {
                          statSetter(() {});
                        }
                      },
                      child: const Text("Ok"))
                ],
              )
            ]),
          ),
        );
      }))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..show();
  }
}
