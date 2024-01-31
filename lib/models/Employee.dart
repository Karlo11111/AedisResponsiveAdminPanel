class EmployeeModel {
  final String? email, password, employee, name, phoneNumber, salary;

  EmployeeModel(
      {this.email,
      this.password,
      this.employee,
      this.name,
      this.phoneNumber,
      this.salary});

  //getting all data from firebase
  factory EmployeeModel.fromMap(Map<String, dynamic> data) {
    return EmployeeModel(
      name: data['firstName'] + ' ' + data['lastName'] ?? "No Name",
      password: data['password'] ?? "No Password",
      employee: data['employee'] ?? "No Employee",
      email: data['email'] ?? "No Email",
      phoneNumber: data['phoneNumber'] ?? "No PhoneNumber",
      salary: data['salary'] ?? "No Salary",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'firstName':
          name?.split(' ').first, // Assuming the first name is the first part
      'lastName': name!.split(' ').length > 1
          ? name?.split(' ')[1]
          : "", // Assuming the last name is the second part
      'password': password, // WARNING: Store hashed passwords, not plain text
      'employee': employee,
      'email': email,
      'phoneNumber': phoneNumber,
      'salary': salary,
    };
  }
}
