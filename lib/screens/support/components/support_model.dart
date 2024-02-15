import 'package:cloud_firestore/cloud_firestore.dart';

class SupportModel {
  final String? email;
  final String? name;
  final String? issue;
  final DateTime? timestamp;

  SupportModel({this.email, this.name, this.issue, this.timestamp});

  factory SupportModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<dynamic, dynamic>;
    return SupportModel(
      email: data['email'],
      name: data['name'],
      issue: data['issue'],
      timestamp: data['timestamp'].toDate(),
    );
  }
}
