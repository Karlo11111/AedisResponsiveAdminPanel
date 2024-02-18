import 'package:admin/constants.dart';
import 'package:flutter/material.dart';

class SolvedSupportListTile extends StatelessWidget {
  const SolvedSupportListTile(
      {super.key,
      required this.name,
      required this.issue,
      required this.adminName,
      required this.email,
      required this.adminResponse,
      required this.resolvedTimestamp,
      required this.timestamp});

  final String name, issue, adminName, email, adminResponse;
  final DateTime timestamp, resolvedTimestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 81, 118, 219),
            borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Guest name: " + name + ": "),
                        Text("Issue: " + issue)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Admin name: " + adminName + ": "),
                        Text("Admin response: " + adminResponse)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Guest issue time: " + timestamp.toString()),
                        Text("Admin response time: " +
                            resolvedTimestamp.toString())
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
