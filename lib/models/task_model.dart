class Task {
  final String? id;
  final String name;
  final String role;
  final String status;

  Task({required this.status, this.id, required this.name, required this.role});

  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      name: map['Name'],
      role: map['Role'],
      status: map['Status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Role': role,
      'Status': status,
    };
  }
}
