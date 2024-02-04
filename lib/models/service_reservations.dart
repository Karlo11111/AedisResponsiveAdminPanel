import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceReservationModel {
  final String? name;
  final String? typeOfService;
  final DateTime? dateOfBooking;
  final String? time;
  final double? servicePrice;

  ServiceReservationModel({
    this.name,
    this.typeOfService,
    this.dateOfBooking,
    this.time,
    this.servicePrice,
  });

  // Getting all data from firebase
  factory ServiceReservationModel.fromMap(Map<String, dynamic> data) {
    // Convert the Timestamp to a DateTime
    DateTime? bookingDate;
    if (data['DateOfBooking'] is Timestamp) {
      bookingDate = (data['DateOfBooking'] as Timestamp).toDate();
    }

    return ServiceReservationModel(
      name: data['Name'] ?? "No Name",
      typeOfService: data['TypeOfService'] ?? "No TypeOfService",
      dateOfBooking: bookingDate,
      time: data['Time'] ?? "No Time",
      servicePrice: data['ServicePrice'] != null
          ? double.tryParse(data['ServicePrice'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'TypeOfService': typeOfService,
      'DateOfBooking': dateOfBooking?.toIso8601String(),
      'Time': time,
      'ServicePrice': servicePrice,
    };
  }
}
