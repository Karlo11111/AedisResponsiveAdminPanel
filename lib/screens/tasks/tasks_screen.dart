import 'package:admin/models/all_jobs.dart';
import 'package:admin/models/task_model.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/tasks/components/header.dart';
import 'package:admin/screens/tasks/components/task_column.dart';
import 'package:admin/screens/tasks/components/task_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive.isDesktop(context)
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }
}

//mobile layout
Widget _buildMobileLayout(BuildContext context) {
  return Column(
    children: [
      TasksHeader(),
      Expanded(
        child: _buildTaskColumn('Assigned', Colors.blue, context),
      ),
      Expanded(
        child: _buildTaskColumn('In Work', Colors.orange, context),
      ),
      Expanded(
        child: _buildTaskColumn('Finished', Colors.green, context),
      ),
    ],
  );
}

//desktop layout
Widget _buildDesktopLayout(BuildContext context) {
  return Row(
    children: [
      TaskColumn(column: _buildTaskColumn('Assigned', Colors.blue, context)),
      TaskColumn(column: _buildTaskColumn('In Work', Colors.orange, context)),
      TaskColumn(column: _buildTaskColumn('Finished', Colors.green, context)),
    ],
  );
}

Widget _buildTaskColumn(String title, Color color, BuildContext context) {
  bool isAssignedColumn = title == 'Assigned';
  return Container(
    padding: EdgeInsets.all(8.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            // Add a plus icon only for the Assigned column
            if (isAssignedColumn)
              IconButton(
                icon: Icon(Icons.add, color: color),
                onPressed: () {
                  _showAddTaskDialog(context);
                },
              ),
          ],
        ),
        // Here you would use a ListView.builder or similar to populate the tasks
        if (isAssignedColumn) Expanded(child: buildAssignedTasks()),
        Expanded(
          child: DragTarget<Task>(
            onWillAccept: (task) {
              print("Will accept task: ${task?.name}");
              return true;
            },
            onAccept: (task) {
              print("Task accepted: ${task.name}");
              transferTask(task, newStatus: title);
            },
            builder: (context, candidateData, rejectedData) {
              return buildTaskList(title);
            },
          ),
        ),
      ],
    ),
  );
}

//add task dialog
void _showAddTaskDialog(BuildContext context) {
  TextEditingController _taskNameController = TextEditingController();
  String? selectedRole;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Task'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(hintText: "Task Name"),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedRole,
                    hint: Text('Assign to role'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    },
                    //all job roles from all_jobs.dart
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
              if (selectedRole != null && _taskNameController.text.isNotEmpty) {
                Task newTask = Task(
                    name: _taskNameController.text,
                    role: selectedRole!,
                    status: "Assigned");
                addTaskToFirebase(newTask);
                Navigator.of(context).pop();
              } else {
                // Handle the case where not all fields are filled
                print('Please fill in all fields');
              }
            },
          ),
        ],
      );
    },
  );
}

//function that adds tasks to firebase
Future<void> addTaskToFirebase(Task task) async {
  DocumentReference taskDoc =
      FirebaseFirestore.instance.collection('Tasks').doc('Assigned');

  return taskDoc
      .set({task.name: task.toMap()},
          SetOptions(merge: true)) // Merging with existing data
      .then((value) => print("Task Added"))
      .catchError((error) => print("Failed to add task: $error"));
}

//stream for getting the tasks
Stream<DocumentSnapshot> getAssignedTasksStream() {
  return FirebaseFirestore.instance
      .collection('Tasks')
      .doc('Assigned')
      .snapshots();
}

Widget buildAssignedTasks() {
  return StreamBuilder<DocumentSnapshot>(
    stream: getAssignedTasksStream(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Text('Loading...');
        default:
          if (!snapshot.data!.exists) {
            return Text('No tasks assigned');
          }
          Map<String, dynamic> tasks =
              snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            children: tasks.entries.map((entry) {
              String taskName = entry.key;
              Map<String, dynamic> taskDetails = entry.value;
              return ListTile(
                title: Text(taskName),
                subtitle: Text('Assigned to: ${taskDetails['Role']}'),
              );
            }).toList(),
          );
      }
    },
  );
}

Widget buildTaskList(String status) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Tasks')
        .doc(status) // Using 'status' here to fetch the correct document
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading");
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Text('No tasks in $status');
      }

      Map<String, dynamic> tasksData =
          snapshot.data!.data() as Map<String, dynamic>;
print(tasksData);
      List<Task> tasks = [];
      tasksData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          tasks.add(
              Task.fromMap(value, key));
               // Assuming 'key' can be used as an ID
        }
      });

      return ListView(
        children: tasks.map((Task task) {
          return Draggable<Task>(
            data: task,
            child: TaskItem(task: task),
            feedback: Material(
              child: Container(
                width: 100,
                color: Colors.blue,
                child: Text(task.name, style: TextStyle(color: Colors.white)),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: TaskItem(task: task),
            ),
            onDragStarted: () => print("Dragging task: ${task.name}"),
          );
        }).toList(),
      );
    },
  );
}

Future<void> transferTask(Task task, {required String newStatus}) async {
  CollectionReference tasksCollection = FirebaseFirestore.instance.collection('Tasks');
  DocumentReference oldStatusDoc = tasksCollection.doc(task.status);
  DocumentReference newStatusDoc = tasksCollection.doc(newStatus);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    // Perform all reads first
    DocumentSnapshot oldStatusSnapshot = await transaction.get(oldStatusDoc);
    DocumentSnapshot newStatusSnapshot = await transaction.get(newStatusDoc);

    // Now perform all writes
    if (oldStatusSnapshot.exists) {
      transaction.update(oldStatusDoc, {
        '${task.name}': FieldValue.delete(), // Use the exact field name to delete
      });
    }

    Map<String, dynamic> taskData = task.toMap();
    taskData['Status'] = newStatus; // Update the status in the task data

    if (!newStatusSnapshot.exists) {
      transaction.set(newStatusDoc, {
        '${task.name}': taskData, // Create the new field with task data
      });
    } else {
      transaction.update(newStatusDoc, {
        '${task.name}': taskData, // Update the existing field with new task data
      });
    }
  }).then((result) {
    print("Task transferred to $newStatus for task: ${task.name}");
  }).catchError((error) {
    print("Failed to transfer task: $error");
  });
}
