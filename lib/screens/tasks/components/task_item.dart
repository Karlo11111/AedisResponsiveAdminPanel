import 'package:admin/models/task_model.dart';
import 'package:flutter/material.dart';


class TaskItem extends StatelessWidget {
  final Task task;

  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.name),
        subtitle: Text('Assigned to: ${task.role}'),
        // Add more details or styling as needed
      ),
    );
  }
}
