import 'package:admin/constants.dart';
import 'package:admin/models/service_reservations.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceReservationsScreeen extends StatefulWidget {
  const ServiceReservationsScreeen({Key? key}) : super(key: key);

  @override
  State<ServiceReservationsScreeen> createState() =>
      _ServiceReservationsScreeenState();
}

//enum for service type
enum ServiceType { DivingSession, Massage, Spa }

extension ServiceTypeExtension on ServiceType {
  String get typeName {
    switch (this) {
      case ServiceType.DivingSession:
        return 'Diving Session';
      case ServiceType.Massage:
        return 'Massage';
      case ServiceType.Spa:
        return 'Spa';
      default:
        return '';
    }
  }
}

//enum for dateRange
enum DateRange { Now, ThreeDaysBefore, AWeekBefore }

extension DateRangeExtension on DateRange {
  String get rangeName {
    switch (this) {
      case DateRange.Now:
        return 'Now';
      case DateRange.ThreeDaysBefore:
        return '3 Days Before';
      case DateRange.AWeekBefore:
        return 'A Week Before';
      default:
        return '';
    }
  }
}

class _ServiceReservationsScreeenState
    extends State<ServiceReservationsScreeen> {
  ServiceType? selectedServiceType;

  DateRange? selectedDateRange;

  //function for getting date from enum
  DateTime _getStartDateForRange(DateRange? range) {
    DateTime now = DateTime.now();
    switch (range) {
      case DateRange.Now:
        return now;
      case DateRange.ThreeDaysBefore:
        return now.subtract(Duration(days: 3));
      case DateRange.AWeekBefore:
        return now.subtract(Duration(days: 7));
      case null:
      default:
        // all time (past date such as 2000)
        return DateTime(2000);
    }
  }

  //function for fetching reservations (takes in account the enums for service and date choosing)
  Stream<List<ServiceReservationModel>> streamReservations(
      ServiceType? selectedServiceType, DateRange? selectedDateRange) {
    DateTime startDate = _getStartDateForRange(selectedDateRange);

    return FirebaseFirestore.instance
        .collection('AllUsersBooked')
        .snapshots()
        .map((snapshot) {
      List<ServiceReservationModel> reservations = [];
      for (var doc in snapshot.docs) {
        void addReservations(
            List<dynamic>? serviceAppointments, String typeOfService) {
          if (serviceAppointments != null) {
            for (var appointment in serviceAppointments) {
              var appointmentMap = Map<String, dynamic>.from(appointment);
              appointmentMap['TypeOfService'] =
                  typeOfService; // Set the type of service

              ServiceReservationModel reservation =
                  ServiceReservationModel.fromMap(appointmentMap);

              // Check for matching service type
              bool matchesServiceType = selectedServiceType == null ||
                  selectedServiceType.typeName == typeOfService;

              // Parse the booking date
              DateTime bookingDate =
                  DateTime.parse(reservation.dateOfBooking.toString());

              // Check if the booking date is after or equal to the start date for the range
              bool matchesDateRange = bookingDate.isAfter(startDate) ||
                  bookingDate.isAtSameMomentAs(startDate);

              // Add the reservation if it matches both service type and date range
              if (matchesServiceType && matchesDateRange) {
                reservations.add(reservation);
              }
            }
          }
        }

        // Add reservations based on the selected service type and date range
        addReservations(
            doc.data()['DivingSessionAppointments'] as List<dynamic>?,
            'Diving Session');
        addReservations(
            doc.data()['MassageAppointments'] as List<dynamic>?, 'Massage');
        addReservations(doc.data()['SpaAppointments'] as List<dynamic>?, 'Spa');
      }

      // Sort reservations by DateOfBooking and then by Time
      reservations.sort((a, b) {
        // Handle null dateOfBooking by treating nulls as "less than" any non-null date
        if (a.dateOfBooking == null && b.dateOfBooking == null) return 0;
        if (a.dateOfBooking == null) return 1;
        if (b.dateOfBooking == null) return -1;

        // At this point, we know both a.dateOfBooking and b.dateOfBooking are non-null due to the above checks
        int compareDate = a.dateOfBooking!.compareTo(b.dateOfBooking!);
        if (compareDate != 0) return compareDate;

        // Assuming the time is in HH:mm format, parse it to TimeOfDay for comparison
        TimeOfDay aTime = TimeOfDay(
          hour: int.parse(a.time!.split(":")[0]),
          minute: int.parse(a.time!.split(":")[1]),
        );
        TimeOfDay bTime = TimeOfDay(
          hour: int.parse(b.time!.split(":")[0]),
          minute: int.parse(b.time!.split(":")[1]),
        );

        // Compare TimeOfDay by converting to a double representing the time of day.
        double aTimeValue = aTime.hour + aTime.minute / 60.0;
        double bTimeValue = bTime.hour + bTime.minute / 60.0;
        return aTimeValue.compareTo(bTimeValue);
      });

      return reservations;
    });
  }

  //dropdown menu for service choosing
  Widget _buildServiceTypeDropdown() {
    List<DropdownMenuItem<ServiceType?>> dropdownItems = [
      DropdownMenuItem<ServiceType?>(
        // null value represents "All"
        value: null,
        child: Text("All"),
      ),
    ];

    dropdownItems.addAll(ServiceType.values.map((ServiceType value) {
      return DropdownMenuItem<ServiceType>(
        value: value,
        child: Text(value.typeName),
      );
    }).toList());

    return DropdownButton<ServiceType?>(
      value: selectedServiceType,
      hint: Text("Select Type"),
      icon: Icon(Icons.arrow_downward),
      underline: Container(
        height: 1.7,
        color: primaryColor,
      ),
      onChanged: (ServiceType? newValue) {
        setState(() {
          selectedServiceType = newValue;
        });
      },
      items: dropdownItems,
    );
  }

  //dropdown menu for date choosing
  Widget _buildDateRangeDropdown() {
    List<DropdownMenuItem<DateRange?>> dropdownItems = [
      DropdownMenuItem<DateRange?>(
        // null value represents "All Time"
        value: null,
        child: Text("All Time"),
      ),
    ];

    dropdownItems.addAll(DateRange.values.map((DateRange value) {
      return DropdownMenuItem<DateRange>(
        value: value,
        child: Text(value.rangeName),
      );
    }).toList());

    return DropdownButton<DateRange?>(
      value: selectedDateRange,
      hint: Text("Select Date Range"),
      icon: Icon(Icons.arrow_downward),
      underline: Container(
        height: 1.7,
        color: primaryColor,
      ),
      onChanged: (DateRange? newValue) {
        setState(() {
          selectedDateRange = newValue;
        });
      },
      items: dropdownItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Header(
                  headerName: "Service Reservations",
                )),

            // service reservations grid
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: StreamBuilder<List<ServiceReservationModel>>(
                    stream: streamReservations(
                        selectedServiceType, selectedDateRange),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text("Waiting for connection!"),
                        );
                      }
                      if (snapshot.hasError) {
                        // Debugging line
                        print("Error fetching data: ${snapshot.error}");
                        return Text("Error: ${snapshot.error}");
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No Data Available");
                      }
                      var employeeList = snapshot.data!;

                      //the data table for users reservations
                      return Responsive.isMobile(context) ||
                              Responsive.isTablet(context)
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: defaultPadding,
                                columns: [
                                  DataColumn(label: Text("Name")),
                                  DataColumn(
                                      label: Row(
                                    children: [
                                      Text("Type Of Service"),
                                      SizedBox(width: 15),
                                      //the function for dropdown choosing of service
                                      _buildServiceTypeDropdown(),
                                    ],
                                  )),
                                  DataColumn(
                                      label: Row(
                                    children: [
                                      Text("Date of Booking"),
                                      SizedBox(width: 15),
                                      //the function for dropdown choosing of service
                                      _buildDateRangeDropdown(),
                                    ],
                                  )),
                                  DataColumn(label: Text("Time of service")),
                                  DataColumn(label: Text("Service Price")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                rows: employeeList
                                    .map((reservation) =>
                                        recentFileDataRow(context, reservation))
                                    .toList(),
                              ))
                          : DataTable(
                              columnSpacing: defaultPadding,
                              columns: [
                                DataColumn(label: Text("Name")),
                                DataColumn(
                                    label: Row(
                                  children: [
                                    Text("Type Of Service"),
                                    SizedBox(width: 15),
                                    //the function for dropdown choosing of service
                                    _buildServiceTypeDropdown(),
                                  ],
                                )),
                                DataColumn(
                                    label: Row(
                                  children: [
                                    Text("Date of Booking"),
                                    SizedBox(width: 15),
                                    //the function for dropdown choosing of service
                                    _buildDateRangeDropdown(),
                                  ],
                                )),
                                DataColumn(label: Text("Time of service")),
                                DataColumn(label: Text("Service Price")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: employeeList
                                  .map((reservation) =>
                                      recentFileDataRow(context, reservation))
                                  .toList(),
                            );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DataRow recentFileDataRow(BuildContext context, ServiceReservationModel model) {
  return DataRow(
    cells: [
      DataCell(Text(model.name ?? 'No Name')),
      DataCell(Text(model.typeOfService ?? 'No Service Type')),
      DataCell(Text(model.dateOfBooking != null
          ? DateFormat('yyyy-MM-dd').format(model.dateOfBooking!)
          : 'No Date')),
      DataCell(Text(model.time ?? 'No Time')),
      DataCell(Text(model.servicePrice != null
          ? model.servicePrice!.toStringAsFixed(2)
          : 'No Price')),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Code to handle editing
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Code to handle deletion
              },
            ),
          ],
        ),
      ),
    ],
  );
}