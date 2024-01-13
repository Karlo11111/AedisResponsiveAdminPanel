import 'package:admin/models/RecentReservations.dart';
import 'package:admin/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../../../constants.dart';

class RecentReservations extends StatefulWidget {
  const RecentReservations({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentReservations> createState() => _RecentReservationsState();
}

class _RecentReservationsState extends State<RecentReservations> {
  //funciton that fetches reservations from firebase
  Stream<List<UserReservation>> streamReservations() {
    return FirebaseFirestore.instance
        .collection('UsersReservation')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserReservation.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Reservations",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: StreamBuilder<List<UserReservation>>(
              stream: streamReservations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text("Waiting for connection!"),
                  );
                }
                if (snapshot.hasError) {
                  print(
                      "Error fetching data: ${snapshot.error}"); // Debugging line
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No Data Available");
                }
                var reservations = snapshot.data!;
                // Sorting the reservations by check-in date
                reservations.sort((a, b) {
                  // Handle null dates by placing them at the end
                  var dateA = a.checkInDate?.toDate() ?? DateTime(9999);
                  var dateB = b.checkInDate?.toDate() ?? DateTime(9999);
                  return dateA.compareTo(dateB);
                });
                //the data table for users reservations
                return Responsive.isMobile(context) ||
                        Responsive.isTablet(context)
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: defaultPadding,
                          columns: [
                            DataColumn(label: Text("Full Name")),
                            DataColumn(label: Text("Check-in Date")),
                            DataColumn(label: Text("Country")),
                            DataColumn(label: Text("Check-In")),
                            DataColumn(label: Text("More Info")),
                          ],
                          rows: reservations
                              .map((reservation) =>
                                  recentFileDataRow(context, reservation))
                              .toList(),
                        ),
                      )
                    : DataTable(
                        columnSpacing: defaultPadding,
                        columns: [
                          DataColumn(label: Text("Full Name")),
                          DataColumn(label: Text("Check-in Date")),
                          DataColumn(label: Text("Country")),
                          DataColumn(label: Text("Check-In")),
                          DataColumn(label: Text("More Info")),
                        ],
                        rows: reservations
                            .map(
                                (reservation) =>
                                recentFileDataRow(context, reservation))
                            .toList(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(BuildContext context, UserReservation reservation) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(reservation.title!),
            ),
          ],
        ),
      ),
      DataCell(Text(reservation.getFormattedCheckInDate())),
      DataCell(Text(reservation.size ?? 'Unknown Size')),
      DataCell(TextButton(
        onPressed: () {},
        child: Text(
          "Check-In",
          style: TextStyle(color: primaryColor),
        ),
      )),
      DataCell(IconButton(
        onPressed: () => showMoreInfoDialog(context, reservation),
        icon: Icon(Icons.more_horiz),
      )),
    ],
  );
}
//dialog box for more info button on the data table
void showMoreInfoDialog(BuildContext context, UserReservation reservation) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("User Information"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              //all of the user data, from RecentReservations.dart
              Text("Full name: ${reservation.title}"),
              SizedBox(height: defaultPadding),
              Text("Check-in Date: ${reservation.getFormattedCheckInDate()}"),
              SizedBox(height: defaultPadding),
              Text("Check-Out Date: ${reservation.getFormattedCheckOutDate()}"),
              SizedBox(height: defaultPadding),
              Text("Country: ${reservation.size}"),
              SizedBox(height: defaultPadding),
              Text("Number of adults in the stay: ${reservation.adults}"),
              SizedBox(height: defaultPadding),
              Text("Number of children in the stay: ${reservation.children}"),
              SizedBox(height: defaultPadding),
              Text("Phone number of the guest: ${reservation.phone}"),
              SizedBox(height: defaultPadding),
              Text("Guests account email: ${reservation.email}"),
              SizedBox(height: defaultPadding),
              Text("Guests account password: ${reservation.password}"),
              SizedBox(height: defaultPadding),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
