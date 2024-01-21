import 'package:admin/constants.dart';
import 'package:flutter/material.dart';

class TaskColumn extends StatelessWidget {
  final Widget column;

  const TaskColumn({Key? key, required this.column}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: column),
      ),
    );
  }
}

