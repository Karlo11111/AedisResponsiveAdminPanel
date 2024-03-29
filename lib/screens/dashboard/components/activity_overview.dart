import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'activity_overview_card.dart';

class ActivityOverview extends StatelessWidget {
  const ActivityOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? secondaryColor
        : lightSecondaryColor;

    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;

    final eightHoursAgo = DateTime.now().subtract(Duration(hours: 8));
    final Timestamp eightHoursAgoTimestamp = Timestamp.fromDate(eightHoursAgo);

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('AllUsersBooked').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text("Waiting for a connection!"),
          );
        }

        List<Map<String, dynamic>> recentBookings = [];

        for (var userDoc in snapshot.data!.docs) {
          var data = userDoc.data() as Map<String, dynamic>;
          // Include KornatiAppointments in the list of booking types
          for (String bookingType in [
            'MassageAppointments',
            'SpaAppointments',
            'DivingSessionAppointments',
            'KornatiAppointments' // Added KornatiAppointments here
          ]) {
            if (data.containsKey(bookingType) &&
                data[bookingType] is List &&
                (data[bookingType] as List).isNotEmpty) {
              List<Map<String, dynamic>> bookings =
                  List.from(data[bookingType]);

              for (var booking in bookings) {
                Timestamp bookingTimestamp = booking['DateOfBooking'];
                if (bookingTimestamp.compareTo(eightHoursAgoTimestamp) >= 0) {
                  recentBookings.add({
                    'Type': bookingType,
                    'Name': booking['Name'] ?? 'No Booking',
                    'DateOfBooking': bookingTimestamp.toDate(),
                  });
                }
              }
            }
          }
        }

        recentBookings
            .sort((a, b) => b['DateOfBooking'].compareTo(a['DateOfBooking']));

        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recent Activity (Last 8 Hours)",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              ...recentBookings
                  .map((booking) => ActivityOverviewCard(
                        svgSrc: getIconPath(booking['Type']),
                        title:
                            "${getShortServiceName(booking['Type'])} booked by ${booking['Name']}",
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  String getIconPath(String type) {
    switch (type) {
      case 'MassageAppointments':
        return "assets/icons/massage.svg";
      case 'SpaAppointments':
        return "assets/icons/spa.svg";
      case 'DivingSessionAppointments':
        return "assets/icons/diving.svg";
      case 'KornatiAppointments':
        return "assets/icons/kornati.svg"; 
      default:
        return "assets/icons/unknown.svg";
    }
  }

  String getShortServiceName(String type) {
    switch (type) {
      case 'MassageAppointments':
        return "Massage";
      case 'SpaAppointments':
        return "Spa";
      case 'DivingSessionAppointments':
        return "Diving";
      case 'KornatiAppointments':
        return "Kornati trip"; 
      default:
        return "Unknown";
    }
  }
}
