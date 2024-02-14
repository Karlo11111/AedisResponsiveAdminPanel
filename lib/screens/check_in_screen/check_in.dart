import 'dart:async';

import 'package:admin/constants.dart';
import 'package:admin/models/CheckedIn.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/check_in_screen/components/check-in-header.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckedInScreen extends StatefulWidget {
  const CheckedInScreen({Key? key}) : super(key: key);

  @override
  State<CheckedInScreen> createState() => _CheckedInScreenState();
}

class _CheckedInScreenState extends State<CheckedInScreen> {
  final StreamController<List<CheckedInModel>> _reservationsStreamController =
      StreamController.broadcast();
  List<CheckedInModel> allReservations = [];
  Map<String, bool> passwordVisibility = {};

  List<CheckedInModel> filteredReservations = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize stream
    streamReservations();
    // Setup listener for search controller
    searchController.addListener(_filterReservations);
  }

  @override
  void dispose() {
    _reservationsStreamController.close();
    searchController.dispose();
    super.dispose();
  }

  void _filterReservations() {
    String query = searchController.text.trim();
    List<CheckedInModel> tempFilteredReservations;

    if (query.isNotEmpty) {
      tempFilteredReservations = allReservations
          .where((reservation) =>
              reservation.fullName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempFilteredReservations =
          List.from(allReservations); // Ensure this creates a new list
    }

    // No need to call setState if you're updating the stream that StreamBuilder listens to
    filteredReservations = tempFilteredReservations;
    _reservationsStreamController
        .add(filteredReservations); // Always update the stream
  }

  void streamReservations() {
    FirebaseFirestore.instance
        .collection('UsersReservation')
        .where("checkedIn", isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      var reservations = snapshot.docs
          .map((doc) =>
              CheckedInModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        allReservations = reservations;
        filteredReservations =
            List.from(allReservations); // Reflects all reservations initially
      });
      _reservationsStreamController.add(filteredReservations); // Update stream
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: CheckedInHeader(
                CheckedInHeaderName: "Checked-in users",
              )),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: SearchField(
              onChanged: (value) {
                // No need to do anything here, listener on searchController handles it
              },
              controller: searchController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: StreamBuilder<List<CheckedInModel>>(
                  stream: _reservationsStreamController.stream,
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
                                  DataColumn(label: Text("Check-in Date")),
                                  DataColumn(label: Text("Check-out Date")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Phone Number")),
                                  DataColumn(label: Text("Country")),
                                  DataColumn(label: Text("Password")),
                                  DataColumn(label: Text("Number of children")),
                                  DataColumn(label: Text("Number of adults")),
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
                              DataColumn(label: Text("Check-in Date")),
                              DataColumn(label: Text("Check-out Date")),
                              DataColumn(label: Text("Email")),
                              DataColumn(label: Text("Phone Number")),
                              DataColumn(label: Text("Country")),
                              DataColumn(label: Text("Password")),
                              DataColumn(label: Text("Number of children")),
                              DataColumn(label: Text("Number of adults")),
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

  DataRow recentFileDataRow(BuildContext context, CheckedInModel model) {
    // Unique key for each password (for example, using the email)
    String key = model.email ?? 'default_key';

    // Ensure the key exists in the map, defaulting to obscured (false)
    passwordVisibility.putIfAbsent(key, () => false);

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(model.fullName!),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            model.checkInDate != null
                ? DateFormat('yyyy-MM-dd').format(model.checkInDate!.toDate())
                : 'Unknown Check-in Date',
          ),
        ),
        DataCell(
          Text(
            model.checkOutDate != null
                ? DateFormat('yyyy-MM-dd').format(model.checkOutDate!.toDate())
                : 'Unknown Check-out Date',
          ),
        ),
        DataCell(Text(model.email ?? 'Unknown email')),
        DataCell(Text(model.phoneNumber ?? 'Unknown phoneNumber')),
        DataCell(Text(model.country ?? 'Unknown country')),
        DataCell(
          Row(
            children: [
              Expanded(
                child: Text(
                  passwordVisibility[key]!
                      ? model.password ?? 'N/A'
                      : '•' * (model.password?.length ?? 8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    // Toggle the password visibility
                    passwordVisibility[key] = !passwordVisibility[key]!;
                  });
                },
                icon: Icon(
                  // Change the icon based on the password visibility
                  passwordVisibility[key]!
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(model.children ?? 'Unknown number of children')),
        DataCell(Text(model.adults ?? 'Unknown number of adults')),
      ],
    );
  }
}
