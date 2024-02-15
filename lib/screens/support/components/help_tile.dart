import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupportListTile extends StatelessWidget {
  const SupportListTile(
      {Key? key,
      required this.height,
      required this.name,
      required this.email,
      required this.issue,
      required this.time})
      : super(key: key);

  final double height;
  final String name, email, issue;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final String formattedTime = time != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(time!)
        : 'No time provided';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 16),
              child: Column(
                children: [
                  Text("Name: " + name),
                  SizedBox(
                    height: defaultPadding,
                  ),
                  Text("Email: " + email),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50, top: 16),
              child: Column(
                children: [
                  Text("Issue: " + issue),
                  SizedBox(
                    height: defaultPadding,
                  ),
                  Text(formattedTime),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
