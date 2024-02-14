// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CheckedInModel {
  final String? adults,
      children,
      fullName,
      email,
      phoneNumber,
      reservationId,
      country,
      password,
      roomNumber;

  final Timestamp? checkInDate, checkOutDate;

  CheckedInModel({
    this.password,
    this.country,
    this.adults,
    this.children,
    this.checkInDate,
    this.checkOutDate,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.reservationId,
    this.roomNumber,
  });

  //getting all data from firebase
  factory CheckedInModel.fromMap(Map<String, dynamic> data) {
    

    return CheckedInModel(
      fullName: data['firstName'] + ' ' + data['lastName'] ?? "No Name",
      adults: data['adults'] ?? "No Adults",
      children: data['children'] ?? "No Children",
      email: data['email'] ?? "No Email",
      phoneNumber: data['phone'] ?? "No PhoneNumber",
      reservationId: data['reservationId'] ?? "No reservationId",
      checkInDate: data['checkInDate'] ?? "No checkInDate",
      checkOutDate: data['checkOutDate'] ?? "No checkOutDate",
      country: data['country'] ?? "No country",
      password: data['password'] ?? "No password",
      roomNumber: data['roomNumber'] ?? "No roomNumber",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'firstName':
          fullName?.split(' ').first, // Assuming the first name is the first part
      'lastName': fullName!.split(' ').length > 1
          ? fullName?.split(' ')[1]
          : "", // Assuming the last name is the second part
      'password': password, // WARNING: Store hashed passwords, not plain text
      'adults': adults,
      'email': email,
      'phone': phoneNumber,
      'children': children,
      'checkOutDate': checkOutDate,
      'checkInDate': checkInDate,
      'roomNumber': roomNumber,
      'reservationId': reservationId,
    };
  }
}
