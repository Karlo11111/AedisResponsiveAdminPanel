import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserReservation {
  final String? icon, title, size;
  final Timestamp? checkInDate;
  final Timestamp? checkOutDate;
  final String? adults, children, email, phone, password;
  final String? roomNumber;
  final bool? isCheckedIn;

  UserReservation({
    this.isCheckedIn,
    this.roomNumber,
    this.adults,
    this.children,
    this.email,
    this.phone,
    this.password,
    this.icon,
    this.title,
    this.checkInDate,
    this.size,
    this.checkOutDate,
  });

  //getting all data from firebase
  factory UserReservation.fromMap(Map<String, dynamic> data) {
    return UserReservation(
      title: data['firstName'] + ' ' + data['lastName'] ?? "No Name",
      checkInDate: data['checkInDate'],
      checkOutDate: data['checkOutDate'],
      size: data['country'] ?? "No Country",
      password: data['password'] ?? "No Password",
      children: data['children'] ?? "No Children",
      adults: data['adults'] ?? "No Adults",
      email: data['email'] ?? "No Email",
      phone: data['phone'] ?? "No Phone",
      roomNumber: data['roomNumber'] ?? "",
      isCheckedIn: data['checkedIn'] ?? false,
    );
  }
  //check in date
  String getFormattedCheckInDate() {
    if (checkInDate != null) {
      return DateFormat('yyyy-MM-dd').format(checkInDate!.toDate());
    } else {
      return "No Date";
    }
  }

  //check out date
  String getFormattedCheckOutDate() {
    if (checkOutDate != null) {
      return DateFormat('yyyy-MM-dd').format(checkOutDate!.toDate());
    } else {
      return "No Date";
    }
  }
}
