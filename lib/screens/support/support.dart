import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/check_in_screen/components/check-in-header.dart';
import 'package:admin/screens/support/components/solved_support_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/screens/support/components/support_model.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SupportModel>> getIssues() {
    return _db
        .collection('Help')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportModel.fromFirestore(doc))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: CheckedInHeader(CheckedInHeaderName: "Support Issues"),
        ),
        // look at replied support issues
        Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding,
              top: defaultPadding,
              bottom: defaultPadding),
          child: TextButton(
              onPressed: () => repliedSupportIssuesPopUp(),
              child: Text(
                "Replied Support Issues",
                style: TextStyle(color: primaryColor),
              )),
        ),
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
              child: StreamBuilder<List<SupportModel>>(
                stream: getIssues(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  var issues = snapshot.data;

                  //the data table for users reservations
                  return Responsive.isMobile(context) ||
                          Responsive.isTablet(context)
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: defaultPadding,
                            columns: [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Issue')),
                              DataColumn(label: Text('Time')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: issues!
                                .map<DataRow>((issue) => DataRow(cells: [
                                      DataCell(Text(issue.name ?? "")),
                                      DataCell(Text(issue.email ?? "")),
                                      DataCell(Text(issue.issue ?? "")),
                                      DataCell(
                                          Text(issue.timestamp.toString())),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.reply),
                                            onPressed: () {
                                              replyDialogPopUp(issue.timestamp);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              // Implement delete functionality
                                              deleteDialogPopUp(
                                                  issue.timestamp);
                                            },
                                          ),
                                        ],
                                      )),
                                    ]))
                                .toList(),
                          ),
                        )
                      : DataTable(
                          columnSpacing: defaultPadding,
                          columns: [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Issue')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: issues!
                              .map<DataRow>((issue) => DataRow(cells: [
                                    DataCell(Text(issue.name ?? "")),
                                    DataCell(Text(issue.email ?? "")),
                                    DataCell(Text(issue.issue ?? "")),
                                    DataCell(Text(issue.timestamp.toString())),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.reply),
                                          onPressed: () {
                                            // Implement reply functionality
                                            replyDialogPopUp(issue.timestamp);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            // Implement delete functionality
                                            deleteDialogPopUp(issue.timestamp);
                                          },
                                        ),
                                      ],
                                    )),
                                  ]))
                              .toList(),
                        );
                },
              ),
            ),
          ),
        ),
      ],
    ));
  }

  replyDialogPopUp(DateTime? issueTimestamp) {
    TextEditingController _adminNameController = TextEditingController();
    TextEditingController _responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to Issue'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: [
                    TextField(
                      controller: _adminNameController,
                      decoration: InputDecoration(hintText: "Admin Name"),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _responseController,
                      decoration: InputDecoration(hintText: "Response"),
                    ),
                    SizedBox(height: 20),
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
              child: Text('Submit'),
              onPressed: () async {
                if (_adminNameController.text.isNotEmpty &&
                    _responseController.text.isNotEmpty) {
                  // Assuming you pass the issue's timestamp to replyDialogPopUp method, and it's available here as a variable named `issueTimestamp`
                  final querySnapshot = await _db
                      .collection('Help')
                      .where('timestamp', isEqualTo: issueTimestamp)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    var doc = querySnapshot.docs.first;
                    var newDocumentData = {
                      ...doc.data(), // Spread operator to include existing data
                      'adminName': _adminNameController.text, // Add admin name
                      'adminResponse':
                          _responseController.text, // Add admin response
                      'resolvedTimestamp': FieldValue
                          .serverTimestamp(), // Optional: Add a timestamp for when the issue was resolved
                    };
                    // Move the document to HelpSolved collection with new data
                    await _db.collection('HelpSolved').add(newDocumentData);
                    // Delete the document from Help collection
                    await doc.reference.delete();
                    // Delete the document from Help collection
                    await doc.reference.delete();

                    Navigator.of(context).pop();
                  } else {
                    // No document found with the given timestamp
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text(
                              "No issue found with the provided timestamp."),
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

  deleteDialogPopUp(DateTime? issueTimestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to Issue'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                final querySnapshot = await _db
                    .collection('Help')
                    .where('timestamp', isEqualTo: issueTimestamp)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  var doc = querySnapshot.docs.first;

                  await doc.reference.delete();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  repliedSupportIssuesPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Replied Support Issues'),
          content: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('HelpSolved').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap:
                      true, // Ensures the ListView only occupies needed space
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return SolvedSupportListTile(
                      issue: data['issue'] ?? 'No Issue Title',
                      adminResponse: data['adminResponse'] ?? 'No Response',
                      name: data['name'] ?? 'No Name',
                      adminName: data['adminName'] ?? 'No Admin Name',
                      email: data['email'] ?? 'No Email',
                      resolvedTimestamp:
                          (data['resolvedTimestamp'] as Timestamp).toDate(),
                      timestamp: (data['timestamp'] as Timestamp).toDate(),
                      // You can add more details here as needed
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
