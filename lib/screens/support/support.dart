import 'package:admin/screens/support/components/help_tile.dart';
import 'package:admin/screens/support/components/support_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    return StreamBuilder<List<SupportModel>>(
      stream: getIssues(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var issues = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            itemCount: issues!.length,
            itemBuilder: (context, index) {
              var issue = issues[index];
              return SupportListTile(
                height: 100,
                name: issue.name ?? "",
                email: issue.email ?? "",
                issue: issue.issue ?? "",
                time: issue.timestamp,
                // Add a reply button or gesture detector to handle responses
              );
            },
          ),
        );
      },
    );
  }
}
