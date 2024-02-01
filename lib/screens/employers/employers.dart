import 'package:admin/constants.dart';
import 'package:admin/models/Employee.dart';
import 'package:admin/models/all_jobs.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/employers/components/employee_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployersPage extends StatelessWidget {
  EmployersPage({Key? key}) : super(key: key);

  Stream<List<EmployeeModel>> streamReservations() {
    return FirebaseFirestore.instance.collection('Employees').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => EmployeeModel.fromMap(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: EmployeeHeader(
                headerName: "Employers",
                onTap: () {
                  showAddEmployeeDialog(context);
                },
              )),
          // Employee Grid
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: StreamBuilder<List<EmployeeModel>>(
                  stream: streamReservations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text("Waiting for connection!"),
                      );
                    }
                    if (snapshot.hasError) {
                      print(
                          "Error fetching data: ${snapshot.error}"); // Debugging line
                      return Text("Error: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No Data Available");
                    }
                    var employeeList = snapshot.data!;

                    //the data table for users reservations
                    return Responsive.isMobile(context) ||
                            Responsive.isTablet(context)
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                                columnSpacing: defaultPadding,
                                columns: [
                                  DataColumn(label: Text("Full Name")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Employee Type")),
                                  DataColumn(label: Text("Salary")),
                                  DataColumn(label: Text("Phone Number")),
                                  DataColumn(label: Text("Password")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                rows: employeeList
                                    .map((reservation) =>
                                        recentFileDataRow(context, reservation))
                                    .toList()),
                          )
                        : DataTable(
                            columnSpacing: defaultPadding,
                            columns: [
                              DataColumn(label: Text("Full Name")),
                              DataColumn(label: Text("Email")),
                              DataColumn(label: Text("Employee Type")),
                              DataColumn(label: Text("Salary")),
                              DataColumn(label: Text("Phone Number")),
                              DataColumn(label: Text("Password")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: employeeList
                                .map((reservation) =>
                                    recentFileDataRow(context, reservation))
                                .toList());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(BuildContext context, EmployeeModel model) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(model.name!),
            ),
          ],
        ),
      ),
      DataCell(Text(model.email ?? 'Unknown Password')),
      DataCell(Text(model.employee ?? 'Unknown Employee')),
      DataCell(Text(model.salary ?? 'Unknown Employee')),
      DataCell(Text(model.phoneNumber ?? 'Unknown Employee')),
      DataCell(Text(model.password ?? 'Unknown Employee')),
      DataCell(
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // Confirm dialog before deletion
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Delete'),
                  content:
                      Text('Are you sure you want to delete this employee?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Edit'),
                      onPressed: () {
                        editEmployeeDialog(context, model);
                      },
                    ),
                    TextButton(
                      child: Text('Delete'),
                      onPressed: () {
                        deleteEmployeeFromFirebase(model.email!);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

void deleteEmployeeFromFirebase(String email) {
  if (email.isEmpty) {
    print('Cannot delete employee without an email');
    return;
  }

  FirebaseFirestore.instance
      .collection('Employees')
      .doc(email)
      .delete()
      .then((_) => print('Employee deleted with email: $email'))
      .catchError((e) => print(e));
}

// Add employee dialog
void showAddEmployeeDialog(BuildContext context) {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? selectedEmployeeType;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Employee'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: "Full Name"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: "Email"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _salaryController,
                    decoration: InputDecoration(hintText: "Salary"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(hintText: "Phone Number"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedEmployeeType,
                    hint: Text('Employee Type'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedEmployeeType = newValue;
                      });
                    },
                    items:
                        jobRoles.map<DropdownMenuItem<String>>((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (selectedEmployeeType != null &&
                  _nameController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty &&
                  _salaryController.text.isNotEmpty &&
                  _phoneNumberController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty) {
                EmployeeModel newEmployee = EmployeeModel(
                  name: _nameController.text,
                  email: _emailController.text,
                  employee: selectedEmployeeType!,
                  salary: _salaryController.text,
                  phoneNumber: _phoneNumberController.text,
                  password: _passwordController.text,
                );
                addEmployeeToFirebase(newEmployee);
                Navigator.of(context).pop();
              } else {
                // Handle the case where not all fields are filled
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Please fill in all fields."),
                      actions: [
                        
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      );
    },
  );
}

void editEmployeeDialog(BuildContext context, EmployeeModel employee) {
  TextEditingController _nameController =
      TextEditingController(text: employee.name);
  TextEditingController _emailController =
      TextEditingController(text: employee.email);
  TextEditingController _salaryController =
      TextEditingController(text: employee.salary);
  TextEditingController _phoneNumberController =
      TextEditingController(text: employee.phoneNumber);
  TextEditingController _passwordController =
      TextEditingController(text: employee.password);
  String? selectedEmployeeType = employee.employee;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Employee'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: "Full Name"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: "Email"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _salaryController,
                    decoration: InputDecoration(hintText: "Salary"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(hintText: "Phone Number"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedEmployeeType,
                    hint: Text('Employee Type'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedEmployeeType = newValue;
                      });
                    },
                    items:
                        jobRoles.map<DropdownMenuItem<String>>((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Update'),
            onPressed: () {
              // Update logic goes here
              if (selectedEmployeeType != null &&
                  _nameController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty &&
                  _salaryController.text.isNotEmpty &&
                  _phoneNumberController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty) {
                EmployeeModel updatedEmployee = EmployeeModel(
                  name: _nameController.text,
                  email: _emailController
                      .text, // Email acts as a unique identifier
                  employee: selectedEmployeeType!,
                  salary: _salaryController.text,
                  phoneNumber: _phoneNumberController.text,
                  password: _passwordController.text,
                );
                updateEmployeeInFirebase(updatedEmployee);
                Navigator.of(context).pop();
              } else {
                // Handle the case where not all fields are filled
                // Similar error handling as in showAddEmployeeDialog
              }
            },
          ),
        ],
      );
    },
  );
}

void updateEmployeeInFirebase(EmployeeModel updatedEmployee) {
  if (updatedEmployee.email == null || updatedEmployee.email!.isEmpty) {
    print('Cannot update employee without an email');
    return;
  }

  String documentId = updatedEmployee.email!;

  FirebaseFirestore.instance
      .collection('Employees')
      .doc(documentId)
      .update(updatedEmployee.toMap())
      .then((_) => print('Employee updated with email: $documentId'))
      .catchError((e) => print(e));
}

void addEmployeeToFirebase(EmployeeModel newEmployee) {
  if (newEmployee.email == null || newEmployee.email!.isEmpty) {
    print('Cannot save employee without an email');
    return;
  }

  String documentId = newEmployee.email!;

  FirebaseFirestore.instance
      .collection('Employees')
      .doc(documentId)
      .set(newEmployee.toMap())
      .then((_) => print('Employee added with email: $documentId'))
      .catchError((e) => print(e));
}
