import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'activity_overview_card.dart';

class ActivityOverview extends StatelessWidget {
  const ActivityOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the time 8 hours ago from now
    final eightHoursAgo = DateTime.now().subtract(Duration(hours: 8));
    // Convert this DateTime to a Timestamp
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
          for (String bookingType in [
            'MassageAppointments',
            'SpaAppointments',
            'DivingSessionAppointments'
          ]) {
            if (data.containsKey(bookingType) &&
                data[bookingType] is List &&
                (data[bookingType] as List).isNotEmpty) {
              List<Map<String, dynamic>> bookings =
                  List.from(data[bookingType]);

              for (var booking in bookings) {
                Timestamp bookingTimestamp = booking['DateOfBooking'];
                // If the booking timestamp is after eight hours ago, it's recent
                if (bookingTimestamp.compareTo(eightHoursAgoTimestamp) >= 0) {
                  recentBookings.add({
                    'Type': bookingType,
                    'Name': booking['Name'] ?? 'No Booking',
                    'DateOfBooking': bookingTimestamp
                        .toDate(), // Convert to DateTime for display
                  });
                }
              }
            }
          }
        }

        // Sort the recent bookings by date, most recent first
        recentBookings
            .sort((a, b) => b['DateOfBooking'].compareTo(a['DateOfBooking']));

        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recent Activity (Last 8 Hours)",
                  style: Theme.of(context).textTheme.titleMedium),
                  
              SizedBox(height: defaultPadding),
              ...recentBookings
                  .map((booking) => ActivityOverviewCard(
                        svgSrc: getIconPath(booking[
                            'Type']), // Implement this function based on type
                        title:
                            "${booking['Type']} Booking by ${booking['Name']}",
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
      default:
        return "assets/icons/unknown.svg";
    }
  }
}
