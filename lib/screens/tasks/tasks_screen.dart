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
      Expanded(child: _buildTaskColumn('Assigned', Colors.blue, context)),
      Expanded(child: _buildTaskColumn('In Work', Colors.orange, context)),
      Expanded(child: _buildTaskColumn('Finished', Colors.green, context)),
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

//widget for building tasks
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
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                );
                
                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text("Error"),
                  content: Text("Please fill in all fields."),
                  actions: [
                    okButton,
                  ],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
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

//widget that builds the task list
Widget buildTaskList(String status) {
  return StreamBuilder<DocumentSnapshot>(
    stream:
        FirebaseFirestore.instance.collection('Tasks').doc(status).snapshots(),
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
      print(snapshot.data!.data());
      Map<String, dynamic> tasksData =
          snapshot.data!.data() as Map<String, dynamic>;
      if (tasksData.isEmpty) {
        return Text('No tasks in $status');
      }
      List<Task> tasks = [];

      tasksData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          tasks.add(Task.fromMap(value, key));
        }
      });
      //list view for building the tiles
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return Draggable<Task>(
            data: task,
            child: TaskItem(task: task),
            //when the list tile is dragged
            feedback: Material(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 300,
                  maxWidth: 350,
                  minHeight: 48.0,
                ),
                //the item being dragged
                child: TaskItem(task: task), 
              ),
              //elevation to raise the feedback widget
              elevation: 4.0, 
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: TaskItem(task: task),
            ),
            onDragStarted: () => print("Dragging task: ${task.name}"),
          );
        },
      );
    },
  );
}

//function for taks transferring
Future<void> transferTask(Task task, {required String newStatus}) async {
  CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('Tasks');
  DocumentReference oldStatusDoc = tasksCollection.doc(task.status);
  DocumentReference newStatusDoc = tasksCollection.doc(newStatus);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    // Perform all reads first
    DocumentSnapshot oldStatusSnapshot = await transaction.get(oldStatusDoc);
    DocumentSnapshot newStatusSnapshot = await transaction.get(newStatusDoc);

    // Now perform all writes
    if (oldStatusSnapshot.exists) {
      transaction.update(oldStatusDoc, {
        '${task.name}':
            FieldValue.delete(), // Use the exact field name to delete
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
        '${task.name}':
            taskData, // Update the existing field with new task data
      });
    }
  }).then((result) {
    print("Task transferred to $newStatus for task: ${task.name}");
  }).catchError((error) {
    print("Failed to transfer task: $error");
  });
}