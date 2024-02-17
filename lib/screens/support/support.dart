import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/check_in_screen/components/check-in-header.dart';
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
      children: [
        CheckedInHeader(CheckedInHeaderName: "Support Issues"),
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
                                              // Implement reply functionality
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              // Implement delete functionality
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
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            // Implement delete functionality
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
}
